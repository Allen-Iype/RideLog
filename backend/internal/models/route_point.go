package models

import (
	"time"

	"github.com/google/uuid"
)

// RoutePoint represents a GPS point in a ride's route
type RoutePoint struct {
	ID             int64     `json:"id" db:"id"`
	RideID         uuid.UUID `json:"ride_id" db:"ride_id"`
	Latitude       float64   `json:"latitude" db:"latitude"`
	Longitude      float64   `json:"longitude" db:"longitude"`
	Altitude       *float64  `json:"altitude,omitempty" db:"altitude"`
	Speed          *float64  `json:"speed,omitempty" db:"speed"`
	Heading        *float64  `json:"heading,omitempty" db:"heading"`
	Accuracy       *float64  `json:"accuracy,omitempty" db:"accuracy"`
	Timestamp      int64     `json:"timestamp" db:"timestamp"`
	SequenceNumber int       `json:"sequence_number" db:"sequence_number"`
	CreatedAt      time.Time `json:"created_at" db:"created_at"`
}

// CreateRoutePoint represents a route point in a create ride request
type CreateRoutePoint struct {
	Latitude       float64  `json:"latitude" binding:"required,min=-90,max=90"`
	Longitude      float64  `json:"longitude" binding:"required,min=-180,max=180"`
	Altitude       *float64 `json:"altitude"`
	Speed          *float64 `json:"speed"`
	Heading        *float64 `json:"heading" binding:"omitempty,min=0,max=360"`
	Accuracy       *float64 `json:"accuracy" binding:"omitempty,gte=0"`
	Timestamp      int64    `json:"timestamp" binding:"required"`
	SequenceNumber int      `json:"sequence_number" binding:"required,gte=0"`
}
