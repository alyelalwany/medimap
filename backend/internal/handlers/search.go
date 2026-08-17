package handlers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/alyelalwany/medimap/backend/internal/models"
)

type SearchHandler struct {
	Pool *pgxpool.Pool
}

// SearchMedicines is a fuzzy autocomplete over name + active_ingredient.
// Query: /api/medicines/search?q=aspir&limit=10
func (h *SearchHandler) SearchMedicines(c *gin.Context) {
	q := c.Query("q")
	if len(q) < 2 {
		c.JSON(http.StatusOK, []models.Medicine{})
		return
	}
	limit := parseLimit(c.Query("limit"), 10, 50)

	ctx, cancel := timeout(c)
	defer cancel()

	rows, err := h.Pool.Query(ctx, `
		SELECT id, name, active_ingredient, strength, form, created_at, updated_at
		FROM medicines
		WHERE name ILIKE '%' || $1 || '%'
		   OR active_ingredient ILIKE '%' || $1 || '%'
		ORDER BY
		    GREATEST(similarity(name, $1), similarity(active_ingredient, $1)) DESC,
		    name
		LIMIT $2
	`, q, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "search failed"})
		return
	}
	defer rows.Close()

	out := make([]models.Medicine, 0, limit)
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

// SearchPharmacies returns pharmacies within radius_km of (lat,lng) that have
// quantity>0 of the requested medicine, ordered by distance ascending.
// Query: /api/pharmacies/search?medicine_id=1&lat=52.52&lng=13.405&radius_km=5
func (h *SearchHandler) SearchPharmacies(c *gin.Context) {
	medicineID, err := strconv.ParseInt(c.Query("medicine_id"), 10, 64)
	if err != nil || medicineID <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "medicine_id required"})
		return
	}
	lat, errLat := strconv.ParseFloat(c.Query("lat"), 64)
	lng, errLng := strconv.ParseFloat(c.Query("lng"), 64)
	if errLat != nil || errLng != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "lat and lng required"})
		return
	}
	radiusKm, _ := strconv.ParseFloat(c.Query("radius_km"), 64)
	if radiusKm <= 0 {
		radiusKm = 5
	}
	if radiusKm > 50 {
		radiusKm = 50
	}
	radiusM := radiusKm * 1000

	ctx, cancel := timeout(c)
	defer cancel()

	rows, err := h.Pool.Query(ctx, `
		SELECT p.id, p.user_id, p.name, p.address,
		       ST_Y(p.location::geometry) AS lat, ST_X(p.location::geometry) AS lng,
		       p.phone, p.email, p.website, p.opening_hours, p.created_at, p.updated_at,
		       ST_Distance(p.location, ST_SetSRID(ST_MakePoint($2, $1), 4326)::geography) AS distance_m,
		       s.quantity
		FROM pharmacies p
		JOIN pharmacy_stock s ON s.pharmacy_id = p.id
		WHERE s.medicine_id = $3
		  AND s.quantity > 0
		  AND ST_DWithin(p.location, ST_SetSRID(ST_MakePoint($2, $1), 4326)::geography, $4)
		ORDER BY distance_m
		LIMIT 50
	`, lat, lng, medicineID, radiusM)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "search failed"})
		return
	}
	defer rows.Close()

	out := make([]models.PharmacySearchResult, 0, 16)
	for rows.Next() {
		var r models.PharmacySearchResult
		if err := rows.Scan(&r.ID, &r.UserID, &r.Name, &r.Address, &r.Lat, &r.Lng,
			&r.Phone, &r.Email, &r.Website, &r.OpeningHours, &r.CreatedAt, &r.UpdatedAt,
			&r.DistanceMeters, &r.Quantity); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "scan failed"})
			return
		}
		out = append(out, r)
	}
	c.JSON(http.StatusOK, out)
}

func parseLimit(raw string, def, max int) int {
	if raw == "" {
		return def
	}
	n, err := strconv.Atoi(raw)
	if err != nil || n <= 0 {
		return def
	}
	if n > max {
		return max
	}
	return n
}

func paramInt64(c *gin.Context, key string) (int64, bool) {
	v, err := strconv.ParseInt(c.Param(key), 10, 64)
	return v, err == nil
}
