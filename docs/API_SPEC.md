# RideLog - API Specification

**Version:** 1.0
**Last Updated:** 2026-03-05
**Base URL:** `https://api.ridelog.app/api/v1`

---

## Table of Contents

1. [Overview](#overview)
2. [Authentication](#authentication)
3. [Error Handling](#error-handling)
4. [Endpoints](#endpoints)
   - [Health Check](#health-check)
   - [Authentication](#authentication-endpoints)
   - [Rides](#rides-endpoints)
5. [Data Models](#data-models)
6. [Status Codes](#status-codes)

---

## Overview

### API Principles

- **RESTful Design:** Resource-based URLs, HTTP methods for actions
- **JSON Format:** All requests and responses use JSON
- **Versioning:** API version in URL path (`/api/v1`)
- **Authentication:** JWT-based bearer token authentication
- **HTTPS Only:** All requests must use HTTPS in production

### Common Headers

**Request Headers:**
```
Content-Type: application/json
Authorization: Bearer <jwt_token>  (for protected routes)
```

**Response Headers:**
```
Content-Type: application/json
```

---

## Authentication

### JWT Token

Protected endpoints require a JWT token in the Authorization header:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Token Payload:**
```json
{
  "sub": "user-uuid",
  "email": "user@example.com",
  "exp": 1717504800,
  "iat": 1717418400
}
```

**Token Expiration:** 7 days

**How to Obtain Token:** Use `/auth/login` endpoint

---

## Error Handling

### Error Response Format

All errors return a consistent JSON structure:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": {}
  }
}
```

### Common Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `INVALID_REQUEST` | 400 | Request validation failed |
| `UNAUTHORIZED` | 401 | Missing or invalid token |
| `FORBIDDEN` | 403 | Insufficient permissions |
| `NOT_FOUND` | 404 | Resource not found |
| `CONFLICT` | 409 | Resource already exists |
| `VALIDATION_ERROR` | 422 | Input validation failed |
| `INTERNAL_ERROR` | 500 | Server error |

### Example Error Response

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email is required",
    "details": {
      "field": "email",
      "reason": "missing_field"
    }
  }
}
```

---

## Endpoints

## Health Check

### GET /health

Check API health status (public endpoint).

**Authentication:** None required

**Response:** `200 OK`

```json
{
  "status": "healthy",
  "timestamp": "2024-06-15T14:23:45Z",
  "version": "1.0.0"
}
```

---

## Authentication Endpoints

### POST /api/v1/auth/register

Register a new user account.

**Authentication:** None required

**Request Body:**

```json
{
  "email": "rider@example.com",
  "password": "SecurePassword123!",
  "full_name": "John Rider"
}
```

**Validation Rules:**
- `email`: Required, valid email format, unique
- `password`: Required, min 8 characters
- `full_name`: Optional, max 255 characters

**Response:** `201 Created`

```json
{
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "rider@example.com",
    "full_name": "John Rider",
    "created_at": "2024-06-15T14:23:45Z"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_at": "2024-06-22T14:23:45Z"
}
```

**Error Responses:**

`400 Bad Request` - Invalid input
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid email format"
  }
}
```

`409 Conflict` - Email already exists
```json
{
  "error": {
    "code": "CONFLICT",
    "message": "Email already registered"
  }
}
```

---

### POST /api/v1/auth/login

Authenticate user and receive JWT token.

**Authentication:** None required

**Request Body:**

```json
{
  "email": "rider@example.com",
  "password": "SecurePassword123!"
}
```

**Response:** `200 OK`

```json
{
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "rider@example.com",
    "full_name": "John Rider"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_at": "2024-06-22T14:23:45Z"
}
```

**Error Responses:**

`401 Unauthorized` - Invalid credentials
```json
{
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Invalid email or password"
  }
}
```

---

## Rides Endpoints

### GET /api/v1/rides

Retrieve list of rides for authenticated user.

**Authentication:** Required (JWT)

**Query Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `limit` | integer | No | 20 | Number of rides to return |
| `offset` | integer | No | 0 | Pagination offset |
| `sort` | string | No | `started_at` | Sort field |
| `order` | string | No | `desc` | Sort order (`asc` or `desc`) |

**Example Request:**

```
GET /api/v1/rides?limit=10&offset=0&sort=started_at&order=desc
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response:** `200 OK`

```json
{
  "rides": [
    {
      "id": "650e8400-e29b-41d4-a716-446655440001",
      "user_id": "550e8400-e29b-41d4-a716-446655440000",
      "title": "Sunday Morning Ride",
      "started_at": "2024-06-15T08:30:00Z",
      "ended_at": "2024-06-15T11:45:00Z",
      "distance_meters": 125430.50,
      "duration_seconds": 11700,
      "avg_speed_kmh": 38.56,
      "max_speed_kmh": 95.2,
      "polyline": "_p~iF~ps|U_ulLnnqC_mqNvxq`@",
      "created_at": "2024-06-15T11:45:30Z"
    },
    {
      "id": "750e8400-e29b-41d4-a716-446655440002",
      "user_id": "550e8400-e29b-41d4-a716-446655440000",
      "title": "Evening Commute",
      "started_at": "2024-06-14T17:00:00Z",
      "ended_at": "2024-06-14T17:35:00Z",
      "distance_meters": 18250.20,
      "duration_seconds": 2100,
      "avg_speed_kmh": 31.29,
      "max_speed_kmh": 65.5,
      "polyline": "abcdEfghiJ...",
      "created_at": "2024-06-14T17:36:00Z"
    }
  ],
  "pagination": {
    "total": 47,
    "limit": 10,
    "offset": 0,
    "has_more": true
  }
}
```

**Error Responses:**

`401 Unauthorized` - Missing or invalid token

---

### GET /api/v1/rides/:id

Retrieve details of a specific ride.

**Authentication:** Required (JWT)

**URL Parameters:**
- `id` (UUID) - Ride ID

**Example Request:**

```
GET /api/v1/rides/650e8400-e29b-41d4-a716-446655440001
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response:** `200 OK`

```json
{
  "id": "650e8400-e29b-41d4-a716-446655440001",
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "title": "Sunday Morning Ride",
  "started_at": "2024-06-15T08:30:00Z",
  "ended_at": "2024-06-15T11:45:00Z",
  "distance_meters": 125430.50,
  "duration_seconds": 11700,
  "avg_speed_kmh": 38.56,
  "max_speed_kmh": 95.2,
  "polyline": "_p~iF~ps|U_ulLnnqC_mqNvxq`@",
  "created_at": "2024-06-15T11:45:30Z",
  "updated_at": "2024-06-15T11:45:30Z"
}
```

**Error Responses:**

`404 Not Found` - Ride doesn't exist or doesn't belong to user
```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "Ride not found"
  }
}
```

---

### POST /api/v1/rides

Create a new ride.

**Authentication:** Required (JWT)

**Request Body:**

```json
{
  "title": "Sunday Morning Ride",
  "started_at": "2024-06-15T08:30:00Z",
  "ended_at": "2024-06-15T11:45:00Z",
  "distance_meters": 125430.50,
  "duration_seconds": 11700,
  "avg_speed_kmh": 38.56,
  "max_speed_kmh": 95.2,
  "polyline": "_p~iF~ps|U_ulLnnqC_mqNvxq`@"
}
```

**Field Descriptions:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `title` | string | No | Ride title/name |
| `started_at` | ISO 8601 | Yes | Ride start timestamp |
| `ended_at` | ISO 8601 | Yes | Ride end timestamp |
| `distance_meters` | number | Yes | Total distance in meters |
| `duration_seconds` | integer | Yes | Total duration in seconds |
| `avg_speed_kmh` | number | No | Average speed in km/h |
| `max_speed_kmh` | number | No | Maximum speed in km/h |
| `polyline` | string | Yes | Encoded polyline of route |

**Validation Rules:**
- `started_at` must be before `ended_at`
- `distance_meters` must be >= 0
- `duration_seconds` must be > 0
- `polyline` must be valid encoded polyline format

**Response:** `201 Created`

```json
{
  "id": "650e8400-e29b-41d4-a716-446655440001",
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "title": "Sunday Morning Ride",
  "started_at": "2024-06-15T08:30:00Z",
  "ended_at": "2024-06-15T11:45:00Z",
  "distance_meters": 125430.50,
  "duration_seconds": 11700,
  "avg_speed_kmh": 38.56,
  "max_speed_kmh": 95.2,
  "polyline": "_p~iF~ps|U_ulLnnqC_mqNvxq`@",
  "created_at": "2024-06-15T11:45:30Z",
  "updated_at": "2024-06-15T11:45:30Z"
}
```

**Error Responses:**

`400 Bad Request` - Invalid input
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "started_at must be before ended_at"
  }
}
```

`422 Unprocessable Entity` - Validation error
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "distance_meters is required",
    "details": {
      "field": "distance_meters"
    }
  }
}
```

---

### DELETE /api/v1/rides/:id

Delete a specific ride.

**Authentication:** Required (JWT)

**URL Parameters:**
- `id` (UUID) - Ride ID

**Example Request:**

```
DELETE /api/v1/rides/650e8400-e29b-41d4-a716-446655440001
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response:** `204 No Content`

No response body.

**Error Responses:**

`404 Not Found` - Ride doesn't exist or doesn't belong to user
```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "Ride not found"
  }
}
```

`403 Forbidden` - User doesn't own this ride
```json
{
  "error": {
    "code": "FORBIDDEN",
    "message": "You don't have permission to delete this ride"
  }
}
```

---

## Data Models

### User

```typescript
{
  id: string (UUID)
  email: string
  full_name: string | null
  created_at: string (ISO 8601)
  updated_at: string (ISO 8601)
}
```

### Ride

```typescript
{
  id: string (UUID)
  user_id: string (UUID)
  title: string | null
  started_at: string (ISO 8601)
  ended_at: string (ISO 8601)
  distance_meters: number
  duration_seconds: number
  avg_speed_kmh: number | null
  max_speed_kmh: number | null
  polyline: string (encoded polyline)
  created_at: string (ISO 8601)
  updated_at: string (ISO 8601)
}
```

### Pagination

```typescript
{
  total: number         // Total number of items
  limit: number         // Items per page
  offset: number        // Current offset
  has_more: boolean     // Whether more items exist
}
```

---

## Status Codes

### Success Codes

| Code | Description |
|------|-------------|
| `200 OK` | Request successful |
| `201 Created` | Resource created successfully |
| `204 No Content` | Request successful, no response body |

### Error Codes

| Code | Description |
|------|-------------|
| `400 Bad Request` | Invalid request format |
| `401 Unauthorized` | Authentication required or failed |
| `403 Forbidden` | Authenticated but insufficient permissions |
| `404 Not Found` | Resource not found |
| `409 Conflict` | Resource conflict (e.g., duplicate email) |
| `422 Unprocessable Entity` | Validation error |
| `500 Internal Server Error` | Server error |

---

## Rate Limiting

**Not implemented in MVP.**

Future versions may implement rate limiting:
- 100 requests per minute per user
- Return `429 Too Many Requests` when exceeded

---

## Versioning Strategy

**Current Version:** v1

API is versioned via URL path: `/api/v1/...`

**Backward Compatibility:**
- Additive changes (new fields) are not breaking
- Removing fields requires new version
- Changing field types requires new version

---

## Example Usage

### Complete Flow: Register → Login → Create Ride → Get Rides

#### 1. Register

```bash
curl -X POST https://api.ridelog.app/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "rider@example.com",
    "password": "SecurePass123",
    "full_name": "John Rider"
  }'
```

#### 2. Login

```bash
curl -X POST https://api.ridelog.app/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "rider@example.com",
    "password": "SecurePass123"
  }'
```

Response:
```json
{
  "user": {...},
  "token": "eyJhbGc...",
  "expires_at": "2024-06-22T14:23:45Z"
}
```

#### 3. Create Ride

```bash
curl -X POST https://api.ridelog.app/api/v1/rides \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJhbGc..." \
  -d '{
    "title": "Morning Commute",
    "started_at": "2024-06-15T08:00:00Z",
    "ended_at": "2024-06-15T08:30:00Z",
    "distance_meters": 15200,
    "duration_seconds": 1800,
    "avg_speed_kmh": 30.4,
    "polyline": "_p~iF~ps|U_ulLnnqC"
  }'
```

#### 4. Get Rides

```bash
curl -X GET https://api.ridelog.app/api/v1/rides?limit=10 \
  -H "Authorization: Bearer eyJhbGc..."
```

---

## Notes

- All timestamps use ISO 8601 format in UTC
- All distances in meters
- All speeds in kilometers per hour (km/h)
- All durations in seconds
- Polyline encoding follows Google's Encoded Polyline Algorithm Format

---

**End of API Specification**
