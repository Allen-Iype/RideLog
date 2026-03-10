package routes

import (
	"github.com/allen/ridelog-backend/internal/api/handlers"
	"github.com/gin-gonic/gin"
)

// RouteConfig holds dependencies for route setup
type RouteConfig struct {
	RideHandler *handlers.RideHandler
	AuthHandler *handlers.AuthHandler
	AuthMiddleware gin.HandlerFunc
}

// SetupRoutes configures all API routes
func SetupRoutes(router *gin.Engine, config *RouteConfig) {
	// Health check
	router.GET("/health", healthCheck)

	// API v1
	v1 := router.Group("/api/v1")
	{
		// Public routes (no authentication required)
		setupAuthRoutes(v1, config.AuthHandler)

		// Protected routes (authentication required)
		setupProtectedRoutes(v1, config)
	}
}

func healthCheck(c *gin.Context) {
	c.JSON(200, gin.H{
		"status":    "healthy",
		"version":   "1.0.0",
		"database":  "connected",
	})
}

// setupAuthRoutes sets up authentication routes (public)
func setupAuthRoutes(rg *gin.RouterGroup, authHandler *handlers.AuthHandler) {
	auth := rg.Group("/auth")
	{
		auth.POST("/register", authHandler.Register)
		auth.POST("/login", authHandler.Login)
	}
}

// setupProtectedRoutes sets up routes that require authentication
func setupProtectedRoutes(rg *gin.RouterGroup, config *RouteConfig) {
	protected := rg.Group("")
	protected.Use(config.AuthMiddleware)
	{
		// User routes
		protected.GET("/user/me", config.AuthHandler.GetCurrentUser)

		// Ride routes
		setupRideRoutes(protected, config.RideHandler)
	}
}

func setupRideRoutes(rg *gin.RouterGroup, rideHandler *handlers.RideHandler) {
	rides := rg.Group("/rides")
	{
		rides.POST("", rideHandler.CreateRide)
		rides.GET("", rideHandler.ListRides)
		rides.GET("/:id", rideHandler.GetRide)
		rides.DELETE("/:id", rideHandler.DeleteRide)
	}
}
