package main

import (
	"log"

	"github.com/allen/ridelog-backend/internal/api/routes"
	"github.com/allen/ridelog-backend/internal/config"
	"github.com/allen/ridelog-backend/internal/database"
	"github.com/gin-gonic/gin"
)

func main() {
	// Load configuration
	cfg := config.Load()

	// Initialize database
	log.Println("Initializing database connection...")
	if err := database.Initialize(&cfg.Database); err != nil {
		log.Fatalf("Failed to initialize database: %v", err)
	}
	defer database.Close()

	// Run migrations
	log.Println("Running database migrations...")
	if err := database.RunMigrations(&cfg.Database); err != nil {
		log.Fatalf("Failed to run migrations: %v", err)
	}

	// Initialize Gin router
	router := gin.Default()

	// Setup all routes
	routes.SetupRoutes(router)

	// Start server
	log.Println("╔════════════════════════════════════════╗")
	log.Println("║         RideLog Backend API            ║")
	log.Println("╚════════════════════════════════════════╝")
	log.Printf("Server starting on %s:%s", cfg.Server.Host, cfg.Server.Port)
	log.Printf("Health check: http://%s:%s/health", cfg.Server.Host, cfg.Server.Port)
	log.Printf("API v1: http://%s:%s/api/v1", cfg.Server.Host, cfg.Server.Port)
	log.Println("Press Ctrl+C to stop")

	if err := router.Run(":" + cfg.Server.Port); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}
