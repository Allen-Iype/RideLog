package repository

import (
	"database/sql"
	"fmt"

	"github.com/allen/ridelog-backend/internal/models"
	"github.com/google/uuid"
)

// RideRepository handles all database operations for rides
type RideRepository struct {
	db *sql.DB
}

// NewRideRepository creates a new ride repository
func NewRideRepository(db *sql.DB) *RideRepository {
	return &RideRepository{
		db: db,
	}
}

// Create creates a new ride with route points
func (r *RideRepository) Create(userID uuid.UUID, req *models.CreateRideRequest) (*models.Ride, error) {
	// Start a transaction
	tx, err := r.db.Begin()
	if err != nil {
		return nil, fmt.Errorf("failed to begin transaction: %w", err)
	}
	defer tx.Rollback()

	// Generate UUID for the ride
	rideID := uuid.New()

	// Insert ride
	ride := &models.Ride{
		ID:              rideID,
		UserID:          userID,
		StartTime:       req.StartTime,
		EndTime:         req.EndTime,
		DistanceMeters:  req.DistanceMeters,
		AvgSpeedKmh:     req.AvgSpeedKmh,
		MaxSpeedKmh:     req.MaxSpeedKmh,
		DurationSeconds: req.DurationSeconds,
		PointCount:      len(req.RoutePoints),
	}

	query := `
		INSERT INTO rides (id, user_id, start_time, end_time, distance_meters, avg_speed_kmh,
			max_speed_kmh, duration_seconds, point_count)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
		RETURNING created_at, updated_at
	`

	err = tx.QueryRow(
		query,
		ride.ID,
		ride.UserID,
		ride.StartTime,
		ride.EndTime,
		ride.DistanceMeters,
		ride.AvgSpeedKmh,
		ride.MaxSpeedKmh,
		ride.DurationSeconds,
		ride.PointCount,
	).Scan(&ride.CreatedAt, &ride.UpdatedAt)

	if err != nil {
		return nil, fmt.Errorf("failed to insert ride: %w", err)
	}

	// Insert route points
	pointQuery := `
		INSERT INTO route_points (ride_id, latitude, longitude, altitude, speed, heading,
			accuracy, timestamp, sequence_number)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
	`

	stmt, err := tx.Prepare(pointQuery)
	if err != nil {
		return nil, fmt.Errorf("failed to prepare route point insert: %w", err)
	}
	defer stmt.Close()

	for _, point := range req.RoutePoints {
		_, err := stmt.Exec(
			rideID,
			point.Latitude,
			point.Longitude,
			point.Altitude,
			point.Speed,
			point.Heading,
			point.Accuracy,
			point.Timestamp,
			point.SequenceNumber,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to insert route point: %w", err)
		}
	}

	// Commit transaction
	if err := tx.Commit(); err != nil {
		return nil, fmt.Errorf("failed to commit transaction: %w", err)
	}

	return ride, nil
}

// GetByID retrieves a ride by ID
func (r *RideRepository) GetByID(rideID, userID uuid.UUID) (*models.RideWithPoints, error) {
	// Get ride
	ride := &models.Ride{}
	query := `
		SELECT id, user_id, start_time, end_time, distance_meters, avg_speed_kmh,
			max_speed_kmh, duration_seconds, point_count, created_at, updated_at
		FROM rides
		WHERE id = $1 AND user_id = $2
	`

	err := r.db.QueryRow(query, rideID, userID).Scan(
		&ride.ID,
		&ride.UserID,
		&ride.StartTime,
		&ride.EndTime,
		&ride.DistanceMeters,
		&ride.AvgSpeedKmh,
		&ride.MaxSpeedKmh,
		&ride.DurationSeconds,
		&ride.PointCount,
		&ride.CreatedAt,
		&ride.UpdatedAt,
	)

	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("ride not found")
	}
	if err != nil {
		return nil, fmt.Errorf("failed to get ride: %w", err)
	}

	// Get route points
	pointsQuery := `
		SELECT id, ride_id, latitude, longitude, altitude, speed, heading, accuracy,
			timestamp, sequence_number, created_at
		FROM route_points
		WHERE ride_id = $1
		ORDER BY sequence_number ASC
	`

	rows, err := r.db.Query(pointsQuery, rideID)
	if err != nil {
		return nil, fmt.Errorf("failed to get route points: %w", err)
	}
	defer rows.Close()

	var points []models.RoutePoint
	for rows.Next() {
		var point models.RoutePoint
		err := rows.Scan(
			&point.ID,
			&point.RideID,
			&point.Latitude,
			&point.Longitude,
			&point.Altitude,
			&point.Speed,
			&point.Heading,
			&point.Accuracy,
			&point.Timestamp,
			&point.SequenceNumber,
			&point.CreatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan route point: %w", err)
		}
		points = append(points, point)
	}

	return &models.RideWithPoints{
		Ride:        *ride,
		RoutePoints: points,
	}, nil
}

// List retrieves all rides for a user with pagination
func (r *RideRepository) List(userID uuid.UUID, limit, offset int) ([]models.Ride, int, error) {
	// Get total count
	var totalCount int
	countQuery := "SELECT COUNT(*) FROM rides WHERE user_id = $1"
	err := r.db.QueryRow(countQuery, userID).Scan(&totalCount)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to get ride count: %w", err)
	}

	// Get rides
	query := `
		SELECT id, user_id, start_time, end_time, distance_meters, avg_speed_kmh,
			max_speed_kmh, duration_seconds, point_count, created_at, updated_at
		FROM rides
		WHERE user_id = $1
		ORDER BY start_time DESC
		LIMIT $2 OFFSET $3
	`

	rows, err := r.db.Query(query, userID, limit, offset)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to list rides: %w", err)
	}
	defer rows.Close()

	var rides []models.Ride
	for rows.Next() {
		var ride models.Ride
		err := rows.Scan(
			&ride.ID,
			&ride.UserID,
			&ride.StartTime,
			&ride.EndTime,
			&ride.DistanceMeters,
			&ride.AvgSpeedKmh,
			&ride.MaxSpeedKmh,
			&ride.DurationSeconds,
			&ride.PointCount,
			&ride.CreatedAt,
			&ride.UpdatedAt,
		)
		if err != nil {
			return nil, 0, fmt.Errorf("failed to scan ride: %w", err)
		}
		rides = append(rides, ride)
	}

	return rides, totalCount, nil
}

// Delete deletes a ride and its route points (cascade)
func (r *RideRepository) Delete(rideID, userID uuid.UUID) error {
	query := "DELETE FROM rides WHERE id = $1 AND user_id = $2"
	result, err := r.db.Exec(query, rideID, userID)
	if err != nil {
		return fmt.Errorf("failed to delete ride: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}

	if rowsAffected == 0 {
		return fmt.Errorf("ride not found")
	}

	return nil
}
