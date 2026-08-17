package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/alyelalwany/medimap/backend/internal/models"
)

type SavedHandler struct {
	Pool *pgxpool.Pool
}

type savedAddReq struct {
	MedicineID int64 `json:"medicine_id" binding:"required"`
}

// List returns the consumer's saved medicines, joined against the catalog.
func (h *SavedHandler) List(c *gin.Context) {
	uid := userID(c)
	ctx, cancel := timeout(c)
	defer cancel()

	rows, err := h.Pool.Query(ctx, `
		SELECT m.id, m.name, m.active_ingredient, m.strength, m.form, m.created_at, m.updated_at
		FROM saved_medicines s
		JOIN medicines m ON m.id = s.medicine_id
		WHERE s.user_id = $1
		ORDER BY s.created_at DESC
	`, uid)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "load saved failed"})
		return
	}
	defer rows.Close()

	out := make([]models.Medicine, 0)
	for rows.Next() {
		var m models.Medicine
		if err := rows.Scan(&m.ID, &m.Name, &m.ActiveIngredient, &m.Strength, &m.Form, &m.CreatedAt, &m.UpdatedAt); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "scan failed"})
			return
		}
		out = append(out, m)
	}
	c.JSON(http.StatusOK, out)
}

// Add appends a medicine to the consumer's saved list (idempotent).
func (h *SavedHandler) Add(c *gin.Context) {
	uid := userID(c)
	var req savedAddReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	ctx, cancel := timeout(c)
	defer cancel()

	// Ensure medicine exists (produces a nicer 404 than the FK error).
	var exists bool
	if err := h.Pool.QueryRow(ctx, `SELECT EXISTS(SELECT 1 FROM medicines WHERE id=$1)`, req.MedicineID).Scan(&exists); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "lookup failed"})
		return
	}
	if !exists {
		c.JSON(http.StatusNotFound, gin.H{"error": "medicine not found"})
		return
	}

	_, err := h.Pool.Exec(ctx, `
		INSERT INTO saved_medicines (user_id, medicine_id) VALUES ($1, $2)
		ON CONFLICT DO NOTHING
	`, uid, req.MedicineID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "save failed"})
		return
	}
	c.Status(http.StatusNoContent)
}

// Remove deletes a medicine from the consumer's saved list.
func (h *SavedHandler) Remove(c *gin.Context) {
	uid := userID(c)
	medicineID, ok := paramInt64(c, "medicine_id")
	if !ok {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid medicine_id"})
		return
	}
	ctx, cancel := timeout(c)
	defer cancel()

	if _, err := h.Pool.Exec(ctx, `DELETE FROM saved_medicines WHERE user_id=$1 AND medicine_id=$2`, uid, medicineID); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "remove failed"})
		return
	}
	c.Status(http.StatusNoContent)
}
