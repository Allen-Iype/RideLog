# RideLog - System Architecture

**Version:** 1.0
**Last Updated:** 2026-03-05

---

## Table of Contents

1. [System Overview](#system-overview)
2. [Technology Stack](#technology-stack)
3. [Architecture Diagram](#architecture-diagram)
4. [Mobile App Architecture](#mobile-app-architecture)
5. [Backend Architecture](#backend-architecture)
6. [Database Schema](#database-schema)
7. [Data Flow](#data-flow)
8. [GPS Data Strategy](#gps-data-strategy)
9. [Offline Architecture](#offline-architecture)
10. [Security Architecture](#security-architecture)
11. [Deployment Architecture](#deployment-architecture)

---

## System Overview

RideLog is a three-tier application:

1. **Presentation Layer** – Flutter mobile application
2. **Application Layer** – Go REST API backend
3. **Data Layer** – PostgreSQL database with PostGIS

The architecture follows a **simple monolithic pattern** suitable for MVP development by a solo developer, with clear separation of concerns for future scalability.

---

## Technology Stack

### Mobile Application
- **Framework:** Flutter 3.x
- **Language:** Dart 3.x
- **State Management:** Riverpod or Provider
- **Local Database:** SQLite (via sqflite)
- **HTTP Client:** Dio
- **Maps:** flutter_map (OpenStreetMap) or Mapbox GL
- **GPS Tracking:** geolocator, background_location
- **Secure Storage:** flutter_secure_storage

### Backend API
- **Language:** Go 1.21+
- **Web Framework:** Gin or Fiber
- **ORM:** GORM
- **Authentication:** JWT (golang-jwt)
- **Validation:** go-playground/validator
- **Database Driver:** lib/pq

### Database
- **RDBMS:** PostgreSQL 15+
- **Extension:** PostGIS 3.4+ (for geospatial data)
- **Migration Tool:** golang-migrate

### DevOps
- **Containerization:** Docker & Docker Compose
- **Version Control:** Git
- **Deployment:** Cloud VM (DigitalOcean, AWS, etc.)
- **Reverse Proxy:** Nginx
- **SSL:** Let's Encrypt

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                     MOBILE APPLICATION (Flutter)                 │
│                                                                  │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌───────────┐│
│  │ Presentation│  │  Business  │  │   Data     │  │  Local    ││
│  │   Layer    │  │   Logic    │  │ Repository │  │  Storage  ││
│  │            │  │            │  │            │  │ (SQLite)  ││
│  │  - Screens │  │  - State   │  │  - API     │  │           ││
│  │  - Widgets │  │    Mgmt    │  │    Client  │  │  - Rides  ││
│  │  - UI      │  │  - Use     │  │  - Local   │  │  - Points ││
│  │            │  │    Cases   │  │    DAO     │  │           ││
│  └────────────┘  └────────────┘  └────────────┘  └───────────┘│
│         │                │                │                     │
│         └────────────────┴────────────────┘                     │
│                          │                                      │
│                    ┌─────▼─────┐                                │
│                    │  Services  │                                │
│                    │            │                                │
│                    │  - GPS     │                                │
│                    │  - Sync    │                                │
│                    │  - Auth    │                                │
│                    └─────┬──────┘                                │
└──────────────────────────┼───────────────────────────────────────┘
                           │
                           │ HTTPS REST API
                           │
┌──────────────────────────▼───────────────────────────────────────┐
│                     BACKEND API (Go)                             │
│                                                                  │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐                │
│  │   HTTP     │  │  Business  │  │    Data    │                │
│  │  Handlers  │  │   Logic    │  │  Access    │                │
│  │            │  │            │  │            │                │
│  │  - Auth    │  │  - Ride    │  │  - Models  │                │
│  │  - Rides   │  │    Service │  │  - Repos   │                │
│  │  - User    │  │  - User    │  │  - DB      │                │
│  │            │  │    Service │  │    Client  │                │
│  └────────────┘  └────────────┘  └─────┬──────┘                │
│         │                │               │                       │
│         └────────────────┴───────────────┘                       │
│                          │                                       │
│                    ┌─────▼─────┐                                 │
│                    │ Middleware │                                 │
│                    │            │                                 │
│                    │  - JWT     │                                 │
│                    │  - CORS    │                                 │
│                    │  - Logger  │                                 │
│                    └────────────┘                                 │
└──────────────────────────┬───────────────────────────────────────┘
                           │
                           │ SQL
                           │
┌──────────────────────────▼───────────────────────────────────────┐
│                  DATABASE (PostgreSQL + PostGIS)                 │
│                                                                  │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │    users    │  │    rides     │  │ ride_points  │           │
│  │             │  │              │  │              │           │
│  │  - id       │  │  - id        │  │  - id        │           │
│  │  - email    │  │  - user_id   │  │  - ride_id   │           │
│  │  - password │  │  - polyline  │  │  - lat/lng   │           │
│  │  - created  │  │  - distance  │  │  - timestamp │           │
│  └─────────────┘  │  - duration  │  └──────────────┘           │
│                   │  - avg_speed │                               │
│                   │  - created   │                               │
│                   └──────────────┘                               │
└──────────────────────────────────────────────────────────────────┘
```

---

## Mobile App Architecture

### Folder Structure

```
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── config/
│   │   ├── app_config.dart
│   │   └── api_config.dart
│   ├── constants/
│   │   └── app_constants.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       ├── logger.dart
│       └── validators.dart
│
├── data/
│   ├── models/
│   │   ├── user.dart
│   │   ├── ride.dart
│   │   └── gps_point.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   └── ride_repository.dart
│   ├── data_sources/
│   │   ├── local/
│   │   │   ├── database_helper.dart
│   │   │   ├── ride_dao.dart
│   │   │   └── gps_point_dao.dart
│   │   └── remote/
│   │       ├── api_client.dart
│   │       ├── auth_api.dart
│   │       └── ride_api.dart
│   └── providers/
│       ├── auth_provider.dart
│       └── ride_provider.dart
│
├── domain/
│   └── use_cases/
│       ├── start_ride.dart
│       ├── stop_ride.dart
│       └── sync_rides.dart
│
├── presentation/
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── recording/
│   │   │   └── recording_screen.dart
│   │   ├── history/
│   │   │   └── ride_history_screen.dart
│   │   └── detail/
│   │       └── ride_detail_screen.dart
│   └── widgets/
│       ├── ride_map.dart
│       ├── ride_stats_card.dart
│       └── loading_indicator.dart
│
└── services/
    ├── gps_service.dart
    ├── sync_service.dart
    └── auth_service.dart
```

### Layer Responsibilities

**Presentation Layer:**
- UI screens and widgets
- User interactions
- State rendering

**Domain Layer:**
- Business logic
- Use cases
- Independent of frameworks

**Data Layer:**
- API communication
- Local database operations
- Data transformation

**Services:**
- GPS tracking
- Background sync
- Authentication management

### State Management Strategy

**Using Riverpod:**

```dart
// Provider for authentication state
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(...);

// Provider for ride recording
final rideRecordingProvider = StateNotifierProvider<RideRecordingNotifier, RideRecordingState>(...);

// Provider for ride history
final rideHistoryProvider = FutureProvider<List<Ride>>(...);
```

---

## Backend Architecture

### Folder Structure

```
backend/
├── cmd/
│   └── server/
│       └── main.go
│
├── internal/
│   ├── api/
│   │   ├── handlers/
│   │   │   ├── auth_handler.go
│   │   │   ├── ride_handler.go
│   │   │   └── health_handler.go
│   │   ├── middleware/
│   │   │   ├── auth_middleware.go
│   │   │   ├── cors_middleware.go
│   │   │   └── logger_middleware.go
│   │   └── routes/
│   │       └── routes.go
│   │
│   ├── models/
│   │   ├── user.go
│   │   ├── ride.go
│   │   └── gps_point.go
│   │
│   ├── repository/
│   │   ├── user_repository.go
│   │   └── ride_repository.go
│   │
│   ├── service/
│   │   ├── auth_service.go
│   │   └── ride_service.go
│   │
│   ├── database/
│   │   └── postgres.go
│   │
│   └── config/
│       └── config.go
│
├── pkg/
│   ├── auth/
│   │   └── jwt.go
│   └── utils/
│       └── password.go
│
├── migrations/
│   ├── 001_create_users_table.up.sql
│   ├── 001_create_users_table.down.sql
│   ├── 002_create_rides_table.up.sql
│   └── 002_create_rides_table.down.sql
│
├── go.mod
├── go.sum
├── Dockerfile
└── docker-compose.yml
```

### API Endpoints

```
Public Endpoints:
POST   /api/v1/auth/register
POST   /api/v1/auth/login

Protected Endpoints (require JWT):
GET    /api/v1/rides
POST   /api/v1/rides
GET    /api/v1/rides/:id
DELETE /api/v1/rides/:id

Health Check:
GET    /health
```

---

## Database Schema

### Users Table

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);
```

### Rides Table

```sql
CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE rides (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Ride metadata
    title VARCHAR(255),
    started_at TIMESTAMP WITH TIME ZONE NOT NULL,
    ended_at TIMESTAMP WITH TIME ZONE,

    -- Statistics
    distance_meters NUMERIC(10, 2),
    duration_seconds INTEGER,
    avg_speed_kmh NUMERIC(5, 2),
    max_speed_kmh NUMERIC(5, 2),

    -- Compressed route (encoded polyline)
    polyline TEXT,

    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_rides_user_id ON rides(user_id);
CREATE INDEX idx_rides_started_at ON rides(started_at DESC);
```

### GPS Points Table (Optional for detailed storage)

```sql
CREATE TABLE gps_points (
    id BIGSERIAL PRIMARY KEY,
    ride_id UUID NOT NULL REFERENCES rides(id) ON DELETE CASCADE,

    -- Location
    location GEOGRAPHY(POINT, 4326) NOT NULL,
    latitude NUMERIC(10, 8) NOT NULL,
    longitude NUMERIC(11, 8) NOT NULL,

    -- Metadata
    altitude NUMERIC(8, 2),
    speed_kmh NUMERIC(5, 2),
    accuracy_meters NUMERIC(6, 2),

    -- Timestamp
    recorded_at TIMESTAMP WITH TIME ZONE NOT NULL,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_gps_points_ride_id ON gps_points(ride_id);
CREATE INDEX idx_gps_points_location ON gps_points USING GIST(location);
```

---

## Data Flow

### Ride Recording Flow

```
1. User taps "Start Ride"
   ↓
2. Flutter initiates GPS tracking
   ↓
3. GPS points captured every 5-10s
   ↓
4. Points stored in local SQLite database
   ↓
5. Route drawn on map in real-time
   ↓
6. User taps "Stop Ride"
   ↓
7. Calculate statistics (distance, duration, avg speed)
   ↓
8. Compress GPS points to polyline
   ↓
9. Save ride metadata locally
   ↓
10. Mark ride as "pending sync"
    ↓
11. Sync service detects unsync'd ride
    ↓
12. POST ride to backend API
    ↓
13. Backend validates and stores in PostgreSQL
    ↓
14. Return ride ID to mobile
    ↓
15. Update local ride as "synced"
```

### Authentication Flow

```
1. User enters email/password
   ↓
2. Flutter sends POST /api/v1/auth/login
   ↓
3. Backend validates credentials
   ↓
4. Backend generates JWT token
   ↓
5. Return JWT to mobile
   ↓
6. Flutter stores JWT in secure storage
   ↓
7. Subsequent API requests include JWT in Authorization header
   ↓
8. Backend middleware validates JWT
   ↓
9. Extract user ID from token
   ↓
10. Process request
```

---

## GPS Data Strategy

### Data Collection

**Recording Frequency:**
- Time-based: Every 5-10 seconds
- Distance-based: Every 10 meters
- Use whichever threshold is met first

**Data Points Captured:**
```dart
{
  "latitude": 37.7749,
  "longitude": -122.4194,
  "altitude": 15.5,
  "speed": 65.3,
  "accuracy": 8.0,
  "heading": 275.0,
  "timestamp": "2024-06-15T14:23:45Z"
}
```

### Data Compression

**Polyline Encoding:**
- Use Google's Encoded Polyline Algorithm Format
- Reduces payload size by ~80%
- Example: `_p~iF~ps|U_ulLnnqC_mqNvxq`@

**Compression Process:**
1. Collect raw GPS points during ride
2. Apply Douglas-Peucker simplification (epsilon ~0.00001)
3. Encode to polyline string
4. Store polyline in database
5. Decode on mobile for display

**Storage Efficiency:**
- Raw points: ~50 bytes per point
- Polyline: ~1 byte per point
- Target: <1KB per km of riding

### Accuracy Filtering

Filter out low-quality GPS points:
- Accuracy threshold: >50 meters rejected
- Speed threshold: >200 km/h rejected (likely GPS error)
- Movement threshold: Skip points if distance <1 meter from last

---

## Offline Architecture

### Offline-First Design

**Principles:**
1. All rides recorded locally first
2. Sync to backend is secondary operation
3. App functions fully without internet
4. Sync happens automatically when online

### Local Storage Strategy

**SQLite Tables:**

```sql
-- Local rides table
CREATE TABLE local_rides (
    id TEXT PRIMARY KEY,
    user_id TEXT,
    polyline TEXT,
    distance_meters REAL,
    duration_seconds INTEGER,
    avg_speed_kmh REAL,
    started_at TEXT,
    ended_at TEXT,
    synced INTEGER DEFAULT 0,  -- 0 = not synced, 1 = synced
    created_at TEXT
);

-- Local GPS points
CREATE TABLE local_gps_points (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ride_id TEXT,
    latitude REAL,
    longitude REAL,
    speed_kmh REAL,
    recorded_at TEXT,
    FOREIGN KEY(ride_id) REFERENCES local_rides(id)
);
```

### Sync Strategy

**Sync Queue:**
1. Rides marked as `synced = 0` are in sync queue
2. Background sync service checks connectivity
3. When online, iterate through unsync'd rides
4. POST each ride to backend
5. On success, mark `synced = 1`
6. On failure, retry with exponential backoff

**Conflict Resolution:**
- Client-side timestamp is source of truth
- No conflicts expected (rides are append-only)
- Duplicate prevention via UUID

**Sync Status Indicators:**
```
🔄 Syncing...
✅ Synced
❌ Sync failed (retry pending)
📴 Offline (will sync when online)
```

---

## Security Architecture

### Authentication

**JWT Token Structure:**
```json
{
  "sub": "user-uuid",
  "email": "rider@example.com",
  "exp": 1717504800,
  "iat": 1717418400
}
```

**Token Lifecycle:**
- Expiration: 7 days
- Storage: Flutter secure storage (encrypted)
- Transmission: Authorization header: `Bearer <token>`

### Password Security

- Hashing algorithm: bcrypt
- Salt rounds: 10
- Never store plain text passwords

### API Security

**Middleware Stack:**
1. CORS middleware (restrict origins)
2. Rate limiting (prevent abuse)
3. JWT validation (protected routes)
4. Request logging

**HTTPS Only:**
- All production traffic over TLS
- SSL certificate via Let's Encrypt
- Redirect HTTP to HTTPS

### Data Privacy

- Rides are private by default
- User can only access their own rides
- Backend enforces user_id filtering

---

## Deployment Architecture

### Development Environment

```
Docker Compose Setup:
┌─────────────────┐
│  PostgreSQL     │
│  Port: 5432     │
└─────────────────┘

┌─────────────────┐
│  Go Backend     │
│  Port: 8080     │
└─────────────────┘

┌─────────────────┐
│  Flutter App    │
│  iOS/Android    │
└─────────────────┘
```

### Production Deployment

```
┌──────────────────────────────────────┐
│          Cloud VM (DigitalOcean)      │
│                                       │
│  ┌────────────────────────────────┐  │
│  │  Nginx (Reverse Proxy)         │  │
│  │  - SSL Termination             │  │
│  │  - Port 80/443                 │  │
│  └─────────────┬──────────────────┘  │
│                │                      │
│  ┌─────────────▼──────────────────┐  │
│  │  Go Backend (Docker)           │  │
│  │  - Port 8080 (internal)        │  │
│  └─────────────┬──────────────────┘  │
│                │                      │
│  ┌─────────────▼──────────────────┐  │
│  │  PostgreSQL (Docker)           │  │
│  │  - Port 5432 (internal)        │  │
│  │  - Persistent volume           │  │
│  └────────────────────────────────┘  │
└──────────────────────────────────────┘
```

**Deployment Steps:**
1. Provision cloud VM
2. Install Docker & Docker Compose
3. Clone repository
4. Configure environment variables
5. Run `docker-compose up -d`
6. Configure Nginx reverse proxy
7. Set up SSL with Certbot
8. Configure firewall (UFW)

---

## Scalability Considerations

**Current Architecture (MVP):**
- Single server monolith
- Suitable for 0-10,000 users

**Future Scaling Options:**
1. **Horizontal Scaling:**
   - Multiple backend instances behind load balancer
   - Stateless API design enables easy scaling

2. **Database Optimization:**
   - Read replicas for query performance
   - Connection pooling
   - Index optimization

3. **Caching:**
   - Redis for session/auth caching
   - CDN for static assets

4. **Service Decomposition:**
   - Separate ride processing service
   - Async job queue for polyline encoding
   - Dedicated sync service

**Note:** Defer optimization until needed. MVP architecture is sufficient for initial launch.

---

## Performance Targets

| Metric | Target |
|--------|--------|
| API Response Time (p95) | <200ms |
| Ride Sync Time | <5 seconds |
| App Launch Time | <2 seconds |
| GPS Point Collection | Every 5-10s |
| Battery Drain | <5% per hour of tracking |
| Offline Storage | Support 100+ unsynced rides |

---

**End of Architecture Document**
