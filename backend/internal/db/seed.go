package db

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"

	"github.com/jackc/pgx/v5/pgxpool"
)

// Seed applies every *.sql file in seedsDir once. Tracked in seed_history
// so re-runs are no-ops. Seed files should be idempotent themselves, but
// history keeps startup fast.
func Seed(ctx context.Context, pool *pgxpool.Pool, seedsDir string) error {
	if _, err := os.Stat(seedsDir); os.IsNotExist(err) {
		return nil
	}

	if _, err := pool.Exec(ctx, `
		CREATE TABLE IF NOT EXISTS seed_history (
			name       TEXT PRIMARY KEY,
			applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
		)`); err != nil {
		return fmt.Errorf("create seed_history: %w", err)
	}

	entries, err := os.ReadDir(seedsDir)
	if err != nil {
		return fmt.Errorf("read seeds dir: %w", err)
	}
	var files []string
	for _, e := range entries {
		if !e.IsDir() && strings.HasSuffix(e.Name(), ".sql") {
			files = append(files, e.Name())
		}
	}
	sort.Strings(files)

	for _, f := range files {
		var applied bool
		if err := pool.QueryRow(ctx,
			`SELECT EXISTS (SELECT 1 FROM seed_history WHERE name = $1)`, f,
		).Scan(&applied); err != nil {
			return fmt.Errorf("check seed %s: %w", f, err)
		}
		if applied {
			continue
		}

		body, err := os.ReadFile(filepath.Join(seedsDir, f))
		if err != nil {
			return fmt.Errorf("read seed %s: %w", f, err)
		}
		if _, err := pool.Exec(ctx, string(body)); err != nil {
			return fmt.Errorf("apply seed %s: %w", f, err)
		}
		if _, err := pool.Exec(ctx,
			`INSERT INTO seed_history (name) VALUES ($1)`, f,
		); err != nil {
			return fmt.Errorf("record seed %s: %w", f, err)
		}
		fmt.Printf("seeded: %s\n", f)
	}
	return nil
}
