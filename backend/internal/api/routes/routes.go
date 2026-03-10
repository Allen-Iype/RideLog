package routes

import (
	"github.com/allen/ridelog-backend/internal/api/handlers"
	"github.com/gin-gonic/gin"
)

// SetupRoutes configures all API routes
func SetupRoutes(router *gin.Engine) {
	// Health check
	router.GET("/health", healthCheck)

	// API v1
	v1 := router.Group("/api/v1")
	{
		setupRideRoutes(v1)
	}
}

func healthCheck(c *gin.Context) {
	c.JSON(200, gin.H{
		"status":    "healthy",
		"version":   "1.0.0",
		"database":  "connected",
	})
}

func setupRideRoutes(rg *gin.RouterGroup) {
	rideHandler := handlers.NewRideHandler()

	rides := rg.Group("/rides")
	{
		rides.POST("", rideHandler.CreateRide)
		rides.GET("", rideHandler.ListRides)
		rides.GET("/:id", rideHandler.GetRide)
		rides.DELETE("/:id", rideHandler.DeleteRide)
	}
}
