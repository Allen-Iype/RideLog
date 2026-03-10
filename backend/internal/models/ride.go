package models

import (
	"time"

	"github.com/google/uuid"
)

// Ride represents a motorcycle ride
type Ride struct {
	ID             uuid.UUID `json:"id" db:"id"`
	UserID         uuid.UUID `json:"user_id" db:"user_id"`
	StartTime      time.Time `json:"start_time" db:"start_time"`
	EndTime        time.Time `json:"end_time" db:"end_time"`
	DistanceMeters float64   `json:"distance_meters" db:"distance_meters"`
	AvgSpeedKmh    float64   `json:"avg_speed_kmh" db:"avg_speed_kmh"`
	MaxSpeedKmh    float64   `json:"max_speed_kmh" db:"max_speed_kmh"`
	DurationSeconds int      `json:"duration_seconds" db:"duration_seconds"`
	PointCount     int       `json:"point_count" db:"point_count"`
	CreatedAt      time.Time `json:"created_at" db:"created_at"`
	UpdatedAt      time.Time `json:"updated_at" db:"updated_at"`
}

// RideWithPoints represents a ride with its GPS route points
type RideWithPoints struct {
	Ride
	RoutePoints []RoutePoint `json:"route_points"`
}

// CreateRideRequest represents a request to create a new ride
type CreateRideRequest struct {
	StartTime       time.Time           `json:"start_time" binding:"required"`
	EndTime         time.Time           `json:"end_time" binding:"required"`
	DistanceMeters  float64             `json:"distance_meters" binding:"required,gte=0"`
	AvgSpeedKmh     float64             `json:"avg_speed_kmh" binding:"required,gte=0"`
	MaxSpeedKmh     float64             `json:"max_speed_kmh" binding:"required,gte=0"`
	DurationSeconds int                 `json:"duration_seconds" binding:"required,gte=0"`
	RoutePoints     []CreateRoutePoint  `json:"route_points" binding:"required,min=2"`
}

// RideListResponse represents paginated list of rides
type RideListResponse struct {
	Rides      []Ride `json:"rides"`
	TotalCount int    `json:"total_count"`
	Page       int    `json:"page"`
	PageSize   int    `json:"page_size"`
}
