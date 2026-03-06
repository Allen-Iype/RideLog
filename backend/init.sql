-- Initialize RideLog Database
-- This script runs automatically when the PostgreSQL container starts

-- Enable PostGIS extension
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;

-- Verify PostGIS installation
SELECT PostGIS_Version();

-- Create initial schema (tables will be created via migrations later)
-- This is just to verify the database is ready
