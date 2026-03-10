package main

import (
	"github.com/allen/ridelog-backend/internal/api/handlers"
	"github.com/allen/ridelog-backend/internal/api/middleware"
	"github.com/allen/ridelog-backend/internal/api/routes"
	"github.com/allen/ridelog-backend/internal/config"
	"github.com/allen/ridelog-backend/internal/database"
	"github.com/allen/ridelog-backend/internal/repository"
	"github.com/allen/ridelog-backend/pkg/auth"
	"github.com/allen/ridelog-backend/pkg/logger"
	"github.com/gin-gonic/gin"
)

func main() {
	// Load configuration
	cfg := config.Load()

	// Initialize database
	logger.Info("Initializing database connection...")
	if err := database.Initialize(&cfg.Database); err != nil {
		logger.Fatal("Failed to initialize database: %v", err)
	}
	defer database.Close()

	// Run migrations
	logger.Info("Running database migrations...")
	if err := database.RunMigrations(&cfg.Database); err != nil {
		logger.Fatal("Failed to run migrations: %v", err)
	}

	// Initialize JWT manager
	jwtManager := auth.NewJWTManager(cfg.JWT.Secret, cfg.JWT.Duration)
	logger.Info("JWT manager initialized")

	// Get database connection
	db := database.GetDB()

	// Initialize repositories
	userRepo := repository.NewUserRepository(db)
	rideRepo := repository.NewRideRepository(db)

	// Initialize handlers
	authHandler := handlers.NewAuthHandler(userRepo, jwtManager)
	rideHandler := handlers.NewRideHandler(rideRepo)

	// Initialize middleware
	authMiddleware := middleware.AuthMiddleware(jwtManager)

	// Initialize Gin router
	// Set Gin mode based on environment
	gin.SetMode(gin.ReleaseMode)
	router := gin.Default()

	// Setup all routes
	routeConfig := &routes.RouteConfig{
		RideHandler:    rideHandler,
		AuthHandler:    authHandler,
		AuthMiddleware: authMiddleware,
	}
	routes.SetupRoutes(router, routeConfig)

	// Start server
	logger.Info("╔════════════════════════════════════════╗")
	logger.Info("║         RideLog Backend API            ║")
	logger.Info("╚════════════════════════════════════════╝")
	logger.Info("Server starting on %s:%s", cfg.Server.Host, cfg.Server.Port)
	logger.Info("Health check: http://%s:%s/health", cfg.Server.Host, cfg.Server.Port)
	logger.Info("API v1: http://%s:%s/api/v1", cfg.Server.Host, cfg.Server.Port)
	logger.Info("Authentication: http://%s:%s/api/v1/auth/register", cfg.Server.Host, cfg.Server.Port)
	logger.Info("Authentication: http://%s:%s/api/v1/auth/login", cfg.Server.Host, cfg.Server.Port)
	logger.Info("Press Ctrl+C to stop")

	if err := router.Run(":" + cfg.Server.Port); err != nil {
		logger.Fatal("Server failed to start: %v", err)
	}
}
