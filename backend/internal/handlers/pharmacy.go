package handlers

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/alyelalwany/medimap/backend/internal/middleware"
	"github.com/alyelalwany/medimap/backend/internal/models"
)

type PharmacyHandler struct {
	Pool *pgxpool.Pool
}

type pharmacyUpsertReq struct {
	Name         string          `json:"name" binding:"required"`
	Address      string          `json:"address" binding:"required"`
	Lat          float64         `json:"lat" binding:"required,latitude"`
	Lng          float64         `json:"lng" binding:"required,longitude"`
	Phone        *string         `json:"phone"`
	Email        *string         `json:"email"`
	Website      *string         `json:"website"`
	OpeningHours json.RawMessage `json:"opening_hours"`
}

// GetMe returns the pharmacy profile owned by the authenticated user.
func (h *PharmacyHandler) GetMe(c *gin.Context) {
	uid := userID(c)
	ctx, cancel := timeout(c)
	defer cancel()

	p, err := selectPharmacyByUser(ctx, h.Pool, uid)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			c.JSON(http.StatusNotFound, gin.H{"error": "pharmacy profile not set"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "load pharmacy failed"})
		return
	}
	c.JSON(http.StatusOK, p)
}

// UpsertMe creates or replaces the pharmacy profile for the authenticated user.
func (h *PharmacyHandler) UpsertMe(c *gin.Context) {
	uid := userID(c)

	var req pharmacyUpsertReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if len(req.OpeningHours) == 0 {
		req.OpeningHours = json.RawMessage(`{}`)
	}

	ctx, cancel := timeout(c)
	defer cancel()

	// ST_MakePoint(lng, lat) — note the order.
	_, err := h.Pool.Exec(ctx, `
		INSERT INTO pharmacies (user_id, name, address, location, phone, email, website, opening_hours)
		VALUES ($1, $2, $3, ST_SetSRID(ST_MakePoint($4, $5), 4326)::geography, $6, $7, $8, $9)
		ON CONFLICT (user_id) DO UPDATE SET
			name          = EXCLUDED.name,
			address       = EXCLUDED.address,
			location      = EXCLUDED.location,
			phone         = EXCLUDED.phone,
			email         = EXCLUDED.email,
			website       = EXCLUDED.website,
			opening_hours = EXCLUDED.opening_hours
	`, uid, req.Name, req.Address, req.Lng, req.Lat, req.Phone, req.Email, req.Website, req.OpeningHours)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "save pharmacy failed"})
		return
	}

	p, err := selectPharmacyByUser(ctx, h.Pool, uid)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "reload pharmacy failed"})
		return
	}
	c.JSON(http.StatusOK, p)
}

type stockUpsertReq struct {
	MedicineID int64 `json:"medicine_id" binding:"required"`
	Quantity   *int  `json:"quantity"    binding:"required"`
}

// ListMyStock returns the authenticated pharmacy's full inventory.
func (h *PharmacyHandler) ListMyStock(c *gin.Context) {
	uid := userID(c)
	ctx, cancel := timeout(c)
	defer cancel()

	pharmacyID, err := pharmacyIDForUser(ctx, h.Pool, uid)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "set pharmacy profile first"})
		return
	}

	rows, err := h.Pool.Query(ctx, `
		SELECT s.pharmacy_id, s.medicine_id, s.quantity, s.updated_at,
		       m.id, m.name, m.active_ingredient, m.strength, m.form, m.created_at, m.updated_at
		FROM pharmacy_stock s
		JOIN medicines m ON m.id = s.medicine_id
		WHERE s.pharmacy_id = $1
		ORDER BY m.name
	`, pharmacyID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "load stock failed"})
		return
	}
	defer rows.Close()

	items := make([]models.StockItem, 0, 32)
	for rows.Next() {
		var s models.StockItem
		var m models.Medicine
		if err := rows.Scan(&s.PharmacyID, &s.MedicineID, &s.Quantity, &s.UpdatedAt,
			&m.ID, &m.Name, &m.ActiveIngredient, &m.Strength, &m.Form, &m.CreatedAt, &m.UpdatedAt); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "scan stock failed"})
			return
		}
		s.Medicine = &m
		items = append(items, s)
	}
	c.JSON(http.StatusOK, items)
}

// UpsertStock sets the quantity for a (pharmacy, medicine) pair.
func (h *PharmacyHandler) UpsertStock(c *gin.Context) {
	uid := userID(c)
	var req stockUpsertReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if *req.Quantity < 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "quantity must be >= 0"})
		return
	}

	ctx, cancel := timeout(c)
	defer cancel()

	pharmacyID, err := pharmacyIDForUser(ctx, h.Pool, uid)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "set pharmacy profile first"})
		return
	}

	_, err = h.Pool.Exec(ctx, `
		INSERT INTO pharmacy_stock (pharmacy_id, medicine_id, quantity)
		VALUES ($1, $2, $3)
		ON CONFLICT (pharmacy_id, medicine_id) DO UPDATE SET quantity = EXCLUDED.quantity
	`, pharmacyID, req.MedicineID, *req.Quantity)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "save stock failed"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"pharmacy_id": pharmacyID, "medicine_id": req.MedicineID, "quantity": *req.Quantity})
}

// DeleteStock removes the (pharmacy, medicine) row entirely (pharmacy no longer carries it).
func (h *PharmacyHandler) DeleteStock(c *gin.Context) {
	uid := userID(c)
	medicineID, ok := paramInt64(c, "medicine_id")
	if !ok {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid medicine_id"})
		return
	}

	ctx, cancel := timeout(c)
	defer cancel()

	pharmacyID, err := pharmacyIDForUser(ctx, h.Pool, uid)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "set pharmacy profile first"})
		return
	}
	tag, err := h.Pool.Exec(ctx, `DELETE FROM pharmacy_stock WHERE pharmacy_id=$1 AND medicine_id=$2`, pharmacyID, medicineID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "delete stock failed"})
		return
	}
	if tag.RowsAffected() == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "stock row not found"})
		return
	}
	c.Status(http.StatusNoContent)
}

// --- helpers ---

func userID(c *gin.Context) int64 {
	v, _ := c.Get(middleware.ContextUID)
	id, _ := v.(int64)
	return id
}

func timeout(c *gin.Context) (context.Context, context.CancelFunc) {
	return context.WithTimeout(c.Request.Context(), 5*time.Second)
}

func selectPharmacyByUser(ctx context.Context, pool *pgxpool.Pool, uid int64) (*models.Pharmacy, error) {
	var p models.Pharmacy
	err := pool.QueryRow(ctx, `
		SELECT id, user_id, name, address,
		       ST_Y(location::geometry) AS lat, ST_X(location::geometry) AS lng,
		       phone, email, website, opening_hours, created_at, updated_at
		FROM pharmacies WHERE user_id = $1
	`, uid).Scan(&p.ID, &p.UserID, &p.Name, &p.Address, &p.Lat, &p.Lng,
		&p.Phone, &p.Email, &p.Website, &p.OpeningHours, &p.CreatedAt, &p.UpdatedAt)
	if err != nil {
		return nil, err
	}
	return &p, nil
}

func pharmacyIDForUser(ctx context.Context, pool *pgxpool.Pool, uid int64) (int64, error) {
	var id int64
	err := pool.QueryRow(ctx, `SELECT id FROM pharmacies WHERE user_id = $1`, uid).Scan(&id)
	return id, err
}
