# RideLog - Project Plan

**Version:** 1.0
**Last Updated:** 2026-03-05
**Status:** In Planning

---

## Project Overview

**App Name:** RideLog

**Positioning:** "Track every ride. Relive every road."

**Purpose:**
RideLog is a mobile application designed specifically for motorcycle riders to track their journeys, record GPS routes, visualize rides on a map, and maintain a personal riding history.

**Target Users:**
Motorcycle riders who want to record and review their rides, analyze statistics, and build a personal riding archive.

---

## Tech Stack

| Component | Technology |
|-----------|------------|
| **Mobile App** | Flutter (Dart) |
| **Backend API** | Go (Gin framework) |
| **Database** | PostgreSQL with PostGIS extension |
| **Maps** | Mapbox or OpenStreetMap |
| **Authentication** | JWT (JSON Web Tokens) |
| **Deployment** | Docker + Cloud VM |
| **Version Control** | Git |

---

## MVP Features

The first version (MVP) will include **only** the following core features:

1. **User Authentication**
   - User registration
   - User login
   - JWT-based session management

2. **Start Ride**
   - One-tap ride recording initiation
   - GPS permission handling

3. **GPS Tracking**
   - Real-time location tracking
   - Background tracking support
   - Periodic location point collection

4. **Live Route Drawing**
   - Real-time route visualization on map
   - Current location marker
   - Route polyline rendering

5. **End Ride**
   - Stop recording
   - Calculate ride statistics

6. **Ride Summary**
   - Distance traveled
   - Duration
   - Average speed
   - Route visualization

7. **Ride History**
   - List of past rides
   - View ride details
   - Delete rides

8. **Backend Ride Storage**
   - Persistent ride data storage
   - Compressed polyline storage
   - User-ride associations

9. **Ride Synchronization**
   - Offline ride recording
   - Auto-sync when network available
   - Conflict resolution

**Out of Scope for MVP:**
- Social feeds
- Leaderboards
- Community features
- Photo attachments
- Ride sharing
- Route planning

---

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────┐
│   Flutter Mobile App            │
│                                 │
│  - UI/UX                        │
│  - GPS Tracking                 │
│  - Map Rendering                │
│  - Offline Storage              │
│  - Sync Logic                   │
└────────────┬────────────────────┘
             │
             │ REST API (HTTPS)
             │
┌────────────▼────────────────────┐
│   Go Backend API                │
│                                 │
│  - Authentication               │
│  - Ride CRUD Operations         │
│  - API Endpoints                │
└────────────┬────────────────────┘
             │
             │ SQL Queries
             │
┌────────────▼────────────────────┐
│   PostgreSQL + PostGIS          │
│                                 │
│  - User Data                    │
│  - Ride Metadata                │
│  - GPS Points/Polylines         │
└─────────────────────────────────┘
```

### Responsibility Distribution

**Flutter Mobile App:**
- User interface and experience
- GPS location tracking
- Map rendering and interaction
- Offline ride recording to local storage
- Syncing ride data to backend when online

**Go Backend API:**
- User authentication and authorization
- Ride data storage and retrieval
- RESTful API services
- Data validation
- Business logic

**PostgreSQL Database:**
- Persistent storage of users
- Rides metadata
- GPS points or compressed polylines
- Geospatial queries via PostGIS

---

## Development Phases

### Phase 1 – Project Setup ✅
**Objective:** Initialize project structure for both mobile and backend

**Tasks:**
- [x] Create Flutter project structure
- [x] Create Go backend project structure
- [x] Initialize Git repository
- [x] Set up PostgreSQL database configuration
- [x] Create initial folder organization
- [x] Set up development environment

**Expected Output:**
- Working Flutter app skeleton ✅
- Working Go API skeleton ✅
- Database configuration ready ✅
- Clean folder structure ✅

**Acceptance Criteria:**
- [x] Flutter app runs and displays "Hello World" ✅
- [x] Go server starts and responds to health check ✅
- [x] PostgreSQL configuration ready (Docker setup deferred to Phase 6) ✅
- [x] Git repository initialized with proper .gitignore ✅

**Completed:** 2026-03-05

---

### Phase 2 – Map Integration ✅
**Objective:** Integrate map rendering in Flutter app

**Tasks:**
- [x] Add map dependency (flutter_map or Mapbox)
- [x] Create map screen
- [x] Display basic map centered on user location
- [x] Test map rendering on device/emulator

**Expected Output:**
- Map displays correctly ✅
- Map is interactive (pan, zoom) ✅
- User location shown on map ✅

**Acceptance Criteria:**
- [x] Map loads without errors ✅
- [x] User can interact with map smoothly ✅
- [x] Current location is visible ✅

**Completed:** 2026-03-05

---

### Phase 3 – GPS Tracking ✅
**Objective:** Implement GPS location tracking

**Tasks:**
- [x] Add location permission handling
- [x] Implement GPS tracking service
- [x] Request and handle location permissions
- [x] Capture location updates periodically
- [x] Display current location on map

**Expected Output:**
- App requests location permissions ✅
- Location updates captured every 5-10 seconds ✅
- Live location marker on map ✅

**Acceptance Criteria:**
- [x] Location permissions properly requested ✅
- [x] GPS coordinates captured accurately ✅
- [x] Location updates in foreground work reliably ✅

**Completed:** 2026-03-06

---

### Phase 4 – Ride Recording ✅
**Objective:** Enable start/stop ride functionality with live route drawing

**Tasks:**
- [x] Create ride recording screen
- [x] Implement start ride button
- [x] Implement stop ride button
- [x] Draw polyline of route in real-time
- [x] Calculate ride statistics (distance, duration, speed)

**Expected Output:**
- User can start a ride ✅
- Route is drawn on map as user moves ✅
- User can stop ride ✅
- Basic statistics calculated ✅

**Acceptance Criteria:**
- [x] Start button initiates tracking ✅
- [x] Route appears on map during ride ✅
- [x] Stop button ends tracking ✅
- [x] Distance and duration calculated correctly ✅

**Completed:** 2026-03-06

---

### Phase 5 – Local Ride Storage ✅
**Objective:** Store rides locally for offline support

**Tasks:**
- [x] Set up SQLite database in Flutter
- [x] Create ride data model
- [x] Implement local CRUD operations
- [x] Store ride metadata and GPS points locally
- [ ] Retrieve and display locally stored rides (UI screens - deferred to Phase 9)

**Expected Output:**
- Rides stored in local database ✅
- Ride history shows local rides (UI pending - Phase 9)
- Rides persist across app restarts ✅

**Acceptance Criteria:**
- [x] Rides saved locally after recording ✅
- [ ] Local rides viewable in ride history (UI screens - deferred to Phase 9)
- [x] No data loss on app restart ✅

**Completed:** 2026-03-06

**Note:** Core storage functionality complete. Ride viewing UI screens (RideHistoryScreen, RideDetailScreen) deferred to Phase 9 for better flow.

---

### Phase 6 – Backend API
**Objective:** Build backend API for ride storage and retrieval

**Tasks:**
- [ ] Design database schema
- [ ] Implement database migrations
- [ ] Create ride model in Go
- [ ] Implement ride POST endpoint
- [ ] Implement ride GET endpoints (list, detail)
- [ ] Implement ride DELETE endpoint
- [ ] Add request validation
- [ ] Test API with Postman/curl

**Expected Output:**
- RESTful API for rides
- Database tables created
- API endpoints functional

**Acceptance Criteria:**
- POST /api/rides creates a ride
- GET /api/rides returns ride list
- GET /api/rides/:id returns ride detail
- DELETE /api/rides/:id deletes a ride
- All endpoints return proper HTTP status codes

---

### Phase 7 – Ride Synchronization
**Objective:** Sync local rides to backend when online

**Tasks:**
- [ ] Implement API client in Flutter
- [ ] Detect network connectivity
- [ ] Sync unsynced rides to backend
- [ ] Mark rides as synced in local database
- [ ] Handle sync failures gracefully
- [ ] Display sync status in UI

**Expected Output:**
- Local rides automatically sync when online
- Sync status visible to user
- Failed syncs retry automatically

**Acceptance Criteria:**
- Offline rides sync when internet available
- No duplicate rides created
- Sync errors handled without crashes

---

### Phase 8 – Authentication
**Objective:** Implement user registration, login, and JWT authentication

**Tasks:**
- [ ] Create user table in database
- [ ] Implement user registration endpoint
- [ ] Implement user login endpoint
- [ ] Generate and validate JWT tokens
- [ ] Protect ride endpoints with authentication
- [ ] Create login/register screens in Flutter
- [ ] Store JWT token securely in Flutter
- [ ] Add token to API requests

**Expected Output:**
- Users can register and login
- JWT tokens issued on login
- API endpoints require authentication

**Acceptance Criteria:**
- User registration creates new user
- Login returns valid JWT token
- Authenticated requests succeed
- Unauthenticated requests return 401

---

### Phase 9 – Ride History and Summaries
**Objective:** Display ride history and detailed ride summaries

**Tasks:**
- [ ] Create ride history screen
- [ ] Fetch rides from backend
- [ ] Display ride list with basic info
- [ ] Create ride detail screen
- [ ] Show ride statistics
- [ ] Render route on map in detail view
- [ ] Implement pull-to-refresh

**Expected Output:**
- Scrollable list of past rides
- Tappable ride items
- Detailed ride view with map and stats

**Acceptance Criteria:**
- All user rides displayed in history
- Ride details show complete information
- Route rendered accurately on map

---

### Phase 10 – Production Readiness
**Objective:** Prepare app for production deployment

**Tasks:**
- [ ] Add error handling throughout app
- [ ] Implement logging
- [ ] Add loading indicators
- [ ] Handle edge cases (no GPS, no internet, etc.)
- [ ] Optimize performance
- [ ] Set up backend deployment (Docker)
- [ ] Configure production database
- [ ] Set up HTTPS/SSL
- [ ] Test on physical devices
- [ ] Create app icons and splash screen

**Expected Output:**
- Production-ready mobile app
- Deployed backend API
- Stable and performant system

**Acceptance Criteria:**
- App handles errors gracefully
- Backend deployed and accessible
- HTTPS configured
- App tested on iOS and Android
- No critical bugs

---

## Development Progress Tracker

### Overall Progress
- [x] Phase 1 – Project Setup ✅
- [x] Phase 2 – Map Integration ✅
- [x] Phase 3 – GPS Tracking ✅
- [x] Phase 4 – Ride Recording ✅
- [x] Phase 5 – Local Ride Storage ✅
- [x] Phase 6 – Backend API ✅
- [x] Phase 7 – Ride Synchronization ✅
- [ ] Phase 8 – Authentication
- [ ] Phase 9 – Ride History and Summaries
- [ ] Phase 10 – Production Readiness

### Current Phase
**Active Phase:** Phase 8 – Authentication
**Status:** Ready to Start
**Started:** -
**Completed:** -

### Completed Phases
**Phase 1 – Project Setup**
**Status:** ✅ COMPLETE
**Started:** 2026-03-05
**Completed:** 2026-03-05

**Phase 2 – Map Integration**
**Status:** ✅ COMPLETE
**Started:** 2026-03-05
**Completed:** 2026-03-05

**Phase 3 – GPS Tracking**
**Status:** ✅ COMPLETE
**Started:** 2026-03-05
**Completed:** 2026-03-06

**Phase 4 – Ride Recording**
**Status:** ✅ COMPLETE
**Started:** 2026-03-06
**Completed:** 2026-03-06

**Phase 5 – Local Ride Storage**
**Status:** ✅ COMPLETE
**Started:** 2026-03-06
**Completed:** 2026-03-06

**Phase 6 – Backend API**
**Status:** ✅ COMPLETE
**Started:** 2026-03-10
**Completed:** 2026-03-10

**Phase 7 – Ride Synchronization**
**Status:** ✅ COMPLETE
**Started:** 2026-03-10
**Completed:** 2026-03-10

---

## Milestones

| Milestone | Target Date | Status |
|-----------|-------------|--------|
| Project Setup Complete | 2026-03-05 | ✅ Complete |
| GPS Tracking Working | 2026-03-06 | ✅ Complete |
| Ride Recording Working | 2026-03-06 | ✅ Complete |
| Offline Recording Working | 2026-03-06 | ✅ Complete |
| Backend API Complete | TBD | ⬜ Not Started |
| Authentication Working | TBD | ⬜ Not Started |
| MVP Complete | TBD | ⬜ Not Started |
| Production Deployment | TBD | ⬜ Not Started |

---

## Implementation Notes

### GPS Data Strategy

**Recording Strategy:**
- Capture location points every 5-10 seconds or every 10 meters (whichever comes first)
- Store raw GPS points during ride recording
- Compress route into polyline format before syncing to backend
- Use polyline encoding (similar to Google's encoded polyline format)

**Storage Strategy:**
- Local: Store raw GPS points in SQLite for offline support
- Backend: Store compressed polyline + metadata for efficiency
- Reduce network payload by transmitting compressed data

**Optimization:**
- Implement GPS point simplification (Douglas-Peucker algorithm)
- Balance accuracy vs. storage size
- Target: <1KB per kilometer of riding

### Offline Support

**Requirements:**
- App must function without internet connection
- All ride recording happens locally first
- Sync to backend when connection available

**Implementation:**
- SQLite for local storage
- Sync queue for pending uploads
- Retry mechanism for failed syncs
- Conflict resolution (local timestamp wins)

### Background Tracking

**Requirements:**
- GPS tracking continues when screen is off
- Battery-efficient tracking
- Foreground service notification (Android)

**Implementation:**
- Use platform-specific background location services
- Flutter background plugins (e.g., background_location)
- Show persistent notification during ride
- Optimize GPS accuracy vs. battery consumption

---

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| Battery drain from GPS | High | Optimize tracking frequency, use geofencing |
| GPS inaccuracy | Medium | Filter out low-accuracy points, smoothing algorithms |
| Network sync failures | Medium | Implement robust retry logic, queue management |
| Background tracking restrictions (iOS) | High | Clearly communicate permissions, use foreground service |
| Database migration issues | Low | Use proper migration tooling, backup strategies |

---

## Success Criteria

The MVP will be considered successful when:

1. ✅ Users can register and log in
2. ✅ Users can record a ride from start to finish
3. ✅ Rides are recorded offline and synced when online
4. ✅ GPS route is accurately captured and displayed
5. ✅ Ride statistics are calculated correctly
6. ✅ Ride history is viewable
7. ✅ App is stable and doesn't crash
8. ✅ Backend API is deployed and accessible

---

## Future Enhancements (Post-MVP)

These features are **not** part of the initial MVP:

- Photo attachments to rides
- Ride sharing with other users
- Social feed
- Leaderboards and achievements
- Route planning and navigation
- Weather data integration
- Motorcycle profiles (multiple bikes)
- Fuel consumption tracking
- Maintenance reminders
- Community features
- Export to GPX/KML

---

## Development Principles

1. **Build Incrementally** – Each phase produces a working application
2. **Keep It Simple** – Avoid over-engineering and premature optimization
3. **Offline First** – App must work without internet
4. **Test Continuously** – Test on real devices frequently
5. **Document Everything** – Keep docs updated as we progress
6. **Production Quality** – Write clean, maintainable code from the start

---

## Notes

- Single developer project
- Focus on core functionality first
- Avoid unnecessary complexity
- Simple, scalable architecture
- Defer social features until MVP validated

---

**End of Project Plan**
