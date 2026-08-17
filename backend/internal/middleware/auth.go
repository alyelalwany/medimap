package middleware

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"

	"github.com/alyelalwany/medimap/backend/internal/auth"
	"github.com/alyelalwany/medimap/backend/internal/models"
)

const (
	CookieName   = "medimap_token"
	ContextUID   = "user_id"
	ContextRole  = "role"
	ContextEmail = "email"
)

// Auth verifies the JWT (from cookie or Authorization: Bearer header) and injects claims into the context.
func Auth(secret string) gin.HandlerFunc {
	return func(c *gin.Context) {
		token := extractToken(c)
		if token == "" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "missing token"})
			return
		}
		claims, err := auth.ParseToken(secret, token)
		if err != nil {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "invalid token"})
			return
		}
		c.Set(ContextUID, claims.UserID)
		c.Set(ContextRole, claims.Role)
		c.Next()
	}
}

// RequireRole aborts if the authenticated user doesn't have one of the given roles.
// Must be used after Auth.
func RequireRole(roles ...models.Role) gin.HandlerFunc {
	return func(c *gin.Context) {
		v, ok := c.Get(ContextRole)
		if !ok {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "unauthenticated"})
			return
		}
		userRole, _ := v.(models.Role)
		for _, r := range roles {
			if userRole == r {
				c.Next()
				return
			}
		}
		c.AbortWithStatusJSON(http.StatusForbidden, gin.H{"error": "forbidden"})
	}
}

func extractToken(c *gin.Context) string {
	if h := c.GetHeader("Authorization"); strings.HasPrefix(h, "Bearer ") {
		return strings.TrimPrefix(h, "Bearer ")
	}
	if v, err := c.Cookie(CookieName); err == nil {
		return v
	}
	return ""
}
