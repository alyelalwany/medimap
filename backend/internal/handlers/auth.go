package handlers

import (
	"context"
	"errors"
	"net/http"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/alyelalwany/medimap/backend/internal/auth"
	"github.com/alyelalwany/medimap/backend/internal/middleware"
	"github.com/alyelalwany/medimap/backend/internal/models"
)

type AuthHandler struct {
	Pool      *pgxpool.Pool
	JWTSecret string
	JWTTTL    time.Duration
	Secure    bool // set the cookie's Secure flag (true in prod, false in dev)
}

type registerReq struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=8"`
	Role     string `json:"role" binding:"required"`
}

type loginReq struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required"`
}

type authResp struct {
	User  models.User `json:"user"`
	Token string      `json:"token"`
}

func (h *AuthHandler) Register(c *gin.Context) {
	var req registerReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	role := models.Role(strings.ToLower(req.Role))
	if !role.Valid() {
		c.JSON(http.StatusBadRequest, gin.H{"error": "role must be consumer or pharmacy"})
		return
	}

	hash, err := auth.HashPassword(req.Password)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "hash failed"})
		return
	}

	ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
	defer cancel()

	var u models.User
	err = h.Pool.QueryRow(ctx, `
		INSERT INTO users (email, password_hash, role)
		VALUES ($1, $2, $3)
		RETURNING id, email, role, created_at, updated_at
	`, strings.ToLower(req.Email), hash, role).Scan(&u.ID, &u.Email, &u.Role, &u.CreatedAt, &u.UpdatedAt)
	if err != nil {
		if strings.Contains(err.Error(), "duplicate key") {
			c.JSON(http.StatusConflict, gin.H{"error": "email already registered"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "could not create user"})
		return
	}

	h.issue(c, u)
}

func (h *AuthHandler) Login(c *gin.Context) {
	var req loginReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
	defer cancel()

	var u models.User
	err := h.Pool.QueryRow(ctx, `
		SELECT id, email, password_hash, role, created_at, updated_at
		FROM users
		WHERE email = $1
	`, strings.ToLower(req.Email)).Scan(&u.ID, &u.Email, &u.PasswordHash, &u.Role, &u.CreatedAt, &u.UpdatedAt)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid credentials"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "login failed"})
		return
	}

	if !auth.VerifyPassword(u.PasswordHash, req.Password) {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid credentials"})
		return
	}

	h.issue(c, u)
}

// Me returns the current user based on the JWT.
func (h *AuthHandler) Me(c *gin.Context) {
	uid, _ := c.Get(middleware.ContextUID)
	id, _ := uid.(int64)

	ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
	defer cancel()

	var u models.User
	err := h.Pool.QueryRow(ctx, `
		SELECT id, email, role, created_at, updated_at
		FROM users WHERE id = $1
	`, id).Scan(&u.ID, &u.Email, &u.Role, &u.CreatedAt, &u.UpdatedAt)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
		return
	}
	c.JSON(http.StatusOK, u)
}

func (h *AuthHandler) Logout(c *gin.Context) {
	c.SetCookie(middleware.CookieName, "", -1, "/", "", h.Secure, true)
	c.JSON(http.StatusOK, gin.H{"ok": true})
}

func (h *AuthHandler) issue(c *gin.Context, u models.User) {
	token, expires, err := auth.IssueToken(h.JWTSecret, h.JWTTTL, u.ID, u.Role)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "token issue failed"})
		return
	}
	maxAge := int(time.Until(expires).Seconds())
	c.SetSameSite(http.SameSiteLaxMode)
	c.SetCookie(middleware.CookieName, token, maxAge, "/", "", h.Secure, true)
	c.JSON(http.StatusOK, authResp{User: u, Token: token})
}
