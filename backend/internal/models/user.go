package models

import "time"

type Role string

const (
	RoleConsumer Role = "consumer"
	RolePharmacy Role = "pharmacy"
)

func (r Role) Valid() bool {
	return r == RoleConsumer || r == RolePharmacy
}

type User struct {
	ID           int64     `json:"id"`
	Email        string    `json:"email"`
	PasswordHash string    `json:"-"`
	Role         Role      `json:"role"`
	CreatedAt    time.Time `json:"created_at"`
	UpdatedAt    time.Time `json:"updated_at"`
}
