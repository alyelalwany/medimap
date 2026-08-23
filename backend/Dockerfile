# syntax=docker/dockerfile:1.7
# Build from the repo root so the build context includes both backend/ and db/.
# Example: docker build -f backend/Dockerfile -t medimap-backend:v1 .

FROM golang:1.25-alpine AS builder
WORKDIR /src

COPY backend/go.mod backend/go.sum ./backend/
WORKDIR /src/backend
RUN go mod download

COPY backend/ ./
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /out/server ./cmd/server

FROM gcr.io/distroless/static-debian12:nonroot
WORKDIR /app

COPY --from=builder /out/server /app/server
COPY db/migrations /app/db/migrations
COPY db/seeds /app/db/seeds

ENV MIGRATIONS_DIR=/app/db/migrations \
    SEEDS_DIR=/app/db/seeds \
    PORT=8081

EXPOSE 8081
USER nonroot:nonroot
ENTRYPOINT ["/app/server"]
