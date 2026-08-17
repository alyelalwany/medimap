package models

import (
	"encoding/json"
	"time"
)

type Pharmacy struct {
	ID           int64           `json:"id"`
	UserID       int64           `json:"user_id"`
	Name         string          `json:"name"`
	Address      string          `json:"address"`
	Lat          float64         `json:"lat"`
	Lng          float64         `json:"lng"`
	Phone        *string         `json:"phone,omitempty"`
	Email        *string         `json:"email,omitempty"`
	Website      *string         `json:"website,omitempty"`
	OpeningHours json.RawMessage `json:"opening_hours"`
	CreatedAt    time.Time       `json:"created_at"`
	UpdatedAt    time.Time       `json:"updated_at"`
}

type Medicine struct {
	ID               int64     `json:"id"`
	Name             string    `json:"name"`
	ActiveIngredient string    `json:"active_ingredient"`
	Strength         string    `json:"strength"`
	Form             string    `json:"form"`
	CreatedAt        time.Time `json:"created_at"`
	UpdatedAt        time.Time `json:"updated_at"`
}

type StockItem struct {
	PharmacyID int64     `json:"pharmacy_id"`
	MedicineID int64     `json:"medicine_id"`
	Medicine   *Medicine `json:"medicine,omitempty"`
	Quantity   int       `json:"quantity"`
	UpdatedAt  time.Time `json:"updated_at"`
}

// PharmacySearchResult is a pharmacy row plus its distance from the query point
// and the stock quantity for the searched medicine.
type PharmacySearchResult struct {
	Pharmacy
	DistanceMeters float64 `json:"distance_meters"`
	Quantity       int     `json:"quantity"`
}
