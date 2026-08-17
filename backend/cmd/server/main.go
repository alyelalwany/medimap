package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"path/filepath"
	"syscall"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"

	"github.com/alyelalwany/medimap/backend/internal/config"
	"github.com/alyelalwany/medimap/backend/internal/db"
	"github.com/alyelalwany/medimap/backend/internal/handlers"
	"github.com/alyelalwany/medimap/backend/internal/middleware"
)

func main() {
	// Load .env if present (dev convenience).
	_ = godotenv.Load()

	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("config: %v", err)
	}

	ctx := context.Background()
	pool, err := db.NewPool(ctx, cfg.DatabaseURL)
	if err != nil {
		log.Fatalf("db: %v", err)
	}
	defer pool.Close()

	// Run migrations from repo-root ../db/migrations relative to backend/.
	migDir := filepath.Join("..", "db", "migrations")
	if v := os.Getenv("MIGRATIONS_DIR"); v != "" {
		migDir = v
	}
	if err := db.Migrate(ctx, pool, migDir); err != nil {
		log.Fatalf("migrate: %v", err)
	}

	if cfg.Env == "production" {
		gin.SetMode(gin.ReleaseMode)
	}
	r := gin.Default()
	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{cfg.CORSOrigin},
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))

	authH := &handlers.AuthHandler{
		Pool:      pool,
		JWTSecret: cfg.JWTSecret,
		JWTTTL:    cfg.JWTTTL,
		Secure:    cfg.Env == "production",
	}

	r.GET("/healthz", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"ok": true})
	})

	api := r.Group("/api")
	{
		api.POST("/auth/register", authH.Register)
		api.POST("/auth/login", authH.Login)

		authed := api.Group("")
		authed.Use(middleware.Auth(cfg.JWTSecret))
		{
			authed.GET("/me", authH.Me)
			authed.POST("/auth/logout", authH.Logout)
		}
	}

	srv := &http.Server{
		Addr:              ":" + cfg.Port,
		Handler:           r,
		ReadHeaderTimeout: 5 * time.Second,
	}

	go func() {
		log.Printf("medimap-backend listening on :%s", cfg.Port)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("listen: %v", err)
		}
	}()

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	log.Println("shutting down")
	shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	_ = srv.Shutdown(shutdownCtx)
}
