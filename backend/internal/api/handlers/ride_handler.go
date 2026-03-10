package handlers

import (
	"net/http"
	"strconv"

	"github.com/allen/ridelog-backend/internal/models"
	"github.com/allen/ridelog-backend/internal/repository"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// RideHandler handles ride-related HTTP requests
type RideHandler struct {
	rideRepo *repository.RideRepository
}

// NewRideHandler creates a new ride handler
func NewRideHandler(rideRepo *repository.RideRepository) *RideHandler {
	return &RideHandler{
		rideRepo: rideRepo,
	}
}

// CreateRide handles POST /api/v1/rides
func (h *RideHandler) CreateRide(c *gin.Context) {
	var req models.CreateRideRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request body",
			"details": err.Error(),
		})
		return
	}

	// Get user ID from context (set by auth middleware)
	userIDStr, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	userID, err := uuid.Parse(userIDStr.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user ID"})
		return
	}

	ride, err := h.rideRepo.Create(userID, &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to create ride",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, ride)
}

// GetRide handles GET /api/v1/rides/:id
func (h *RideHandler) GetRide(c *gin.Context) {
	rideID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid ride ID",
		})
		return
	}

	// Get user ID from context (set by auth middleware)
	userIDStr, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	userID, err := uuid.Parse(userIDStr.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user ID"})
		return
	}

	ride, err := h.rideRepo.GetByID(rideID, userID)
	if err != nil {
		if err.Error() == "ride not found" {
			c.JSON(http.StatusNotFound, gin.H{
				"error": "Ride not found",
			})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to get ride",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, ride)
}

// ListRides handles GET /api/v1/rides
func (h *RideHandler) ListRides(c *gin.Context) {
	// Parse pagination parameters
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "20"))

	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 20
	}

	offset := (page - 1) * pageSize

	// Get user ID from context (set by auth middleware)
	userIDStr, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	userID, err := uuid.Parse(userIDStr.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user ID"})
		return
	}

	rides, totalCount, err := h.rideRepo.List(userID, pageSize, offset)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to list rides",
			"details": err.Error(),
		})
		return
	}

	// Handle empty results
	if rides == nil {
		rides = []models.Ride{}
	}

	response := models.RideListResponse{
		Rides:      rides,
		TotalCount: totalCount,
		Page:       page,
		PageSize:   pageSize,
	}

	c.JSON(http.StatusOK, response)
}

// DeleteRide handles DELETE /api/v1/rides/:id
func (h *RideHandler) DeleteRide(c *gin.Context) {
	rideID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid ride ID",
		})
		return
	}

	// Get user ID from context (set by auth middleware)
	userIDStr, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	userID, err := uuid.Parse(userIDStr.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user ID"})
		return
	}

	err = h.rideRepo.Delete(rideID, userID)
	if err != nil {
		if err.Error() == "ride not found" {
			c.JSON(http.StatusNotFound, gin.H{
				"error": "Ride not found",
			})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to delete ride",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Ride deleted successfully",
	})
}
