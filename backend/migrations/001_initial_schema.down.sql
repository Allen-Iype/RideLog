-- Drop triggers
DROP TRIGGER IF EXISTS update_route_points_location ON route_points;
DROP TRIGGER IF EXISTS update_rides_updated_at ON rides;
DROP TRIGGER IF EXISTS update_users_updated_at ON users;

-- Drop functions
DROP FUNCTION IF EXISTS update_route_point_location();
DROP FUNCTION IF EXISTS update_updated_at_column();

-- Drop tables (cascade will drop foreign key constraints)
DROP TABLE IF EXISTS route_points CASCADE;
DROP TABLE IF EXISTS rides CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Optionally drop PostGIS extension (commented out to preserve if used elsewhere)
-- DROP EXTENSION IF EXISTS postgis;
