.PHONY: help build run test clean docker-build docker-up docker-down docker-logs migrate

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build the application
	go build -o bin/server ./cmd/server

run: ## Run the application locally
	go run ./cmd/server/main.go

test: ## Run tests
	go test -v ./...

clean: ## Clean build artifacts
	rm -rf bin/
	rm -f server main

docker-build: ## Build Docker image
	docker build -t ridelog-backend:latest .

docker-up: ## Start all services with Docker Compose
	docker-compose -f docker-compose.prod.yml up -d

docker-down: ## Stop all services
	docker-compose -f docker-compose.prod.yml down

docker-logs: ## View Docker logs
	docker-compose -f docker-compose.prod.yml logs -f

docker-restart: ## Restart all services
	docker-compose -f docker-compose.prod.yml restart

migrate-up: ## Run database migrations
	go run ./cmd/migrate/main.go up

migrate-down: ## Rollback database migrations
	go run ./cmd/migrate/main.go down

dev: ## Run in development mode
	docker-compose up -d
	go run ./cmd/server/main.go

prod: ## Deploy to production
	docker-compose -f docker-compose.prod.yml up -d --build

health: ## Check API health
	curl http://localhost:8080/health

install: ## Install dependencies
	go mod download
	go mod tidy
