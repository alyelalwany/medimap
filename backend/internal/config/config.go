package config

import (
	"fmt"
	"os"
	"strconv"
	"time"
)

type Config struct {
	Port        string
	Env         string
	DatabaseURL string
	JWTSecret   string
	JWTTTL      time.Duration
	CORSOrigin  string
}

func Load() (*Config, error) {
	cfg := &Config{
		Port:        getEnv("PORT", "8080"),
		Env:         getEnv("ENV", "development"),
		DatabaseURL: os.Getenv("DATABASE_URL"),
		JWTSecret:   os.Getenv("JWT_SECRET"),
		CORSOrigin:  getEnv("CORS_ORIGIN", "http://localhost:3000"),
	}

	if cfg.DatabaseURL == "" {
		return nil, fmt.Errorf("DATABASE_URL is required")
	}
	if cfg.JWTSecret == "" {
		return nil, fmt.Errorf("JWT_SECRET is required")
	}

	ttlHours, _ := strconv.Atoi(getEnv("JWT_TTL_HOURS", "24"))
	cfg.JWTTTL = time.Duration(ttlHours) * time.Hour

	return cfg, nil
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
