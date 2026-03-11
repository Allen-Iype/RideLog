# RideLog - Complete Setup and Testing Guide

**Version:** 2.0
**Last Updated:** 2026-03-11
**Status:** Complete MVP (All 10 Phases)

This guide walks you through setting up the entire RideLog system from scratch and verifying that everything works end-to-end.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Backend Setup](#backend-setup)
3. [Mobile App Setup](#mobile-app-setup)
4. [End-to-End Testing](#end-to-end-testing)
5. [Troubleshooting](#troubleshooting)
6. [Test Checklist](#test-checklist)

---

## Prerequisites

### Required Software

Before starting, ensure you have:

- ✅ **Git** - Latest version
- ✅ **Docker Desktop** - Running and configured
- ✅ **Go** - Version 1.21 or higher
- ✅ **Flutter SDK** - Version 3.x or higher
- ✅ **Android Studio** (for Android) or **Xcode** (for iOS)
- ✅ **Terminal/Command Line** access

### Verify Installations

```bash
# Check Git
git --version

# Check Docker
docker --version
docker-compose --version

# Check Go
go version

# Check Flutter
flutter doctor
```

**Expected Output:**
- Git: version 2.x+
- Docker: version 20.x+
- Go: version 1.21+
- Flutter: No major issues (✓ marks for all components)

---

## Backend Setup

### Step 1: Clone the Repository

```bash
git clone https://github.com/yourusername/RideLog.git
cd RideLog
```

### Step 2: Set Up Environment Variables

```bash
cd backend

# Copy example environment file
cp .env.example .env
```

**Edit `.env` file:**

```env
# Server Configuration
SERVER_PORT=8080
SERVER_HOST=0.0.0.0

# Database Configuration
DB_HOST=postgres
DB_PORT=5432
DB_USER=ridelog
DB_PASSWORD=ridelog123
DB_NAME=ridelog_db
DB_SSLMODE=disable

# JWT Configuration (use a strong secret in production)
JWT_SECRET=your_jwt_secret_minimum_32_characters_long
```

⚠️ **For development, the example values are fine. For production, use strong random passwords.**

### Step 3: Start the Database

```bash
# Start PostgreSQL with PostGIS using Docker Compose
docker-compose up -d

# Verify database is running
docker ps
```

**Expected Output:**
```
CONTAINER ID   IMAGE            STATUS         PORTS
abc123...      postgis/postgis  Up 10 seconds  0.0.0.0:5432->5432/tcp
```

### Step 4: Verify Database Connection

```bash
# Connect to database
docker exec -it ridelog_postgres psql -U ridelog -d ridelog_db

# Inside PostgreSQL, run:
SELECT PostGIS_Version();

# Exit
\q
```

**Expected Output:**
```
            postgis_version
---------------------------------------
 3.4 USE_GEOS=1 USE_PROJ=1 USE_STATS=1
```

### Step 5: Install Go Dependencies

```bash
# In backend directory
go mod download
go mod tidy
```

### Step 6: Run Database Migrations

```bash
# Run migrations
go run cmd/migrate/main.go up
```

**Expected Output:**
```
Running migrations...
Migration: 001_initial_schema.sql ... OK
Migration: 002_add_users.sql ... OK
Migrations completed successfully!
```

### Step 7: Start the Backend Server

```bash
# Run the backend
go run cmd/server/main.go
```

**Expected Output:**
```
╔════════════════════════════════════════╗
║         RideLog Backend API            ║
╚════════════════════════════════════════╝
Server starting on localhost:8080
Health check: http://localhost:8080/health
API v1: http://localhost:8080/api/v1
Press Ctrl+C to stop
```

### Step 8: Test Backend Health Endpoint

**Open a new terminal:**

```bash
curl http://localhost:8080/health
```

**Expected Response:**
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "database": "connected"
}
```

✅ **Backend is now running!**

---

## Mobile App Setup

### Step 1: Navigate to Mobile Directory

```bash
# Open a new terminal
cd /Users/allen/Personal/RideLog/mobile
```

### Step 2: Install Flutter Dependencies

```bash
flutter pub get
```

**Expected Output:**
```
Running "flutter pub get" in mobile...
Resolving dependencies... (X.Xs)
Got dependencies!
```

### Step 3: Configure API URL (Development)

The app is pre-configured for local development:

- **iOS Simulator**: Uses `http://localhost:8080/api/v1`
- **Android Emulator**: Should use `http://10.0.2.2:8080/api/v1`

**For Android Emulator, update the URL:**

Edit `mobile/lib/config/environment.dart`:

```dart
static const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8080/api/v1',  // Android emulator
);
```

Or run with dart-define:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
```

### Step 4: Start an Emulator/Simulator

**For Android:**
```bash
# List available emulators
flutter emulators

# Launch an emulator
flutter emulators --launch <emulator_id>
```

**For iOS:**
```bash
# Open iOS Simulator (Mac only)
open -a Simulator
```

### Step 5: Run the Mobile App

```bash
# Run on connected device/emulator
flutter run

# Or specify platform
flutter run -d android
flutter run -d ios
```

**Expected Output:**
```
Launching lib/main.dart on Android SDK built for x86 in debug mode...
Running Gradle task 'assembleDebug'...
✓ Built build/app/outputs/flutter-apk/app-debug.apk.
Installing build/app/outputs/flutter-apk/app.apk...
Flutter run key commands.
h Repeat this help message.
r Hot reload.
R Hot restart.
q Quit (terminate the application on the device).
```

✅ **Mobile app is now running!**

---

## End-to-End Testing

Now let's test the complete user journey through all features.

### Test 1: User Registration

**Objective:** Create a new user account

**Steps:**
1. App should launch to the login screen
2. Tap "Don't have an account? Sign Up"
3. Enter:
   - **Email**: `test@example.com`
   - **Password**: `password123`
   - **Confirm Password**: `password123`
4. Tap "Sign Up"

**Expected Results:**
- ✅ Registration success message appears
- ✅ Automatically navigates to map screen
- ✅ JWT token stored securely

**Backend Verification:**
```bash
# Check logs in backend terminal
# Should see: POST /api/v1/auth/register | 201
```

---

### Test 2: User Login

**Objective:** Test logout and login flow

**Steps:**
1. From map screen, tap the logout icon (top-right)
2. Confirm logout
3. Should return to login screen
4. Enter:
   - **Email**: `test@example.com`
   - **Password**: `password123`
5. Tap "Sign In"

**Expected Results:**
- ✅ Login success
- ✅ Navigates to map screen
- ✅ Map loads with user's location

**Backend Verification:**
```bash
# Should see: POST /api/v1/auth/login | 200
```

---

### Test 3: Map and GPS Tracking

**Objective:** Verify map displays and GPS works

**Steps:**
1. On map screen, observe the map loads
2. Pan and zoom the map
3. Tap "My Location" button (compass icon)

**Expected Results:**
- ✅ OpenStreetMap tiles load
- ✅ Map is interactive (pan/zoom)
- ✅ Red location marker appears
- ✅ "My Location" button centers on current position

**For Android Emulator - Set GPS Location:**
```bash
# In terminal, set a location (San Francisco)
adb emu geo fix -122.4194 37.7749
```

---

### Test 4: Start Ride Recording

**Objective:** Record a ride with GPS tracking

**Steps:**
1. Ensure GPS tracking is ready (green indicator)
2. Tap green "Start Ride" button
3. Observe the UI changes

**Expected Results:**
- ✅ Button changes to red "Stop Ride"
- ✅ "Ride recording started!" message
- ✅ Ride stats panel appears showing:
   - Red "RECORDING" indicator
   - Distance: 0.00 km
   - Duration: counting (1s, 2s, 3s...)
   - Avg Speed: 0.0 km/h
   - Max Speed: 0.0 km/h
   - GPS Points: 0

---

### Test 5: Simulate Ride Movement

**Objective:** Test route tracking and statistics

**Steps:**
1. While ride is recording, simulate GPS movement
2. Run these commands in a new terminal (every 5 seconds):

```bash
# Point 1: Start
adb emu geo fix -122.4194 37.7749
sleep 5

# Point 2: Move north
adb emu geo fix -122.4189 37.7759
sleep 5

# Point 3: Move north
adb emu geo fix -122.4184 37.7769
sleep 5

# Point 4: Move north
adb emu geo fix -122.4179 37.7779
sleep 5

# Point 5: Move northeast
adb emu geo fix -122.4174 37.7789
```

**Expected Results:**
- ✅ Blue polyline appears on map
- ✅ Polyline connects each GPS point
- ✅ Location marker moves along route
- ✅ Statistics update in real-time:
  - Distance increases
  - Duration counts up
  - Avg Speed calculates
  - GPS Points count increases
  - Map auto-follows current location

---

### Test 6: Stop and Save Ride

**Objective:** Complete ride recording and save to local database

**Steps:**
1. After simulating movement, tap red "Stop Ride" button
2. Review ride summary dialog
3. Tap "Save Ride"

**Expected Results:**
- ✅ Ride summary dialog appears showing:
  - Distance (e.g., ~1.1 km)
  - Duration (e.g., 20s)
  - Average Speed
  - Max Speed
  - GPS Points count
- ✅ "Save Ride" and "Discard" buttons present
- ✅ After tapping "Save Ride":
  - Success message appears
  - Ride saved to local SQLite database
  - Map clears, ready for next ride

---

### Test 7: Ride Synchronization

**Objective:** Test offline ride syncing to backend

**Steps:**
1. Tap "Sync" button (cloud icon) in top bar
2. Or wait for auto-sync to trigger

**Expected Results:**
- ✅ "Syncing rides..." message appears
- ✅ Progress indicator shows
- ✅ Success message: "X ride(s) synced successfully"
- ✅ Sync status updates (cloud icon changes)

**Backend Verification:**
```bash
# In backend terminal, should see:
POST /api/v1/rides | 201
```

**Verify in Backend:**
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" http://localhost:8080/api/v1/rides
```

---

### Test 8: View Ride History

**Objective:** Test ride history screen

**Steps:**
1. From map screen, tap "Ride History" button (bottom navigation)
2. Observe the list of rides
3. Pull down to refresh

**Expected Results:**
- ✅ List of rides appears (showing saved/synced rides)
- ✅ Each ride card shows:
  - Date and time
  - Distance, duration, avg speed
  - Sync status (cloud icon - synced or local only)
  - Delete button
- ✅ Pull-to-refresh works and fetches latest from backend

---

### Test 9: View Ride Details

**Objective:** Test detailed ride view with map

**Steps:**
1. From ride history, tap on any ride card
2. Observe the ride detail screen

**Expected Results:**
- ✅ Map displays with full route polyline
- ✅ Green start marker at beginning
- ✅ Red finish marker at end
- ✅ Complete statistics grid shows:
  - Distance
  - Duration
  - Start/End time
  - Average speed
  - Max speed
  - GPS points count
- ✅ Map auto-fits to show entire route

---

### Test 10: Delete Ride

**Objective:** Test ride deletion

**Steps:**
1. From ride history, tap delete icon (trash) on any ride
2. Confirm deletion in dialog

**Expected Results:**
- ✅ Confirmation dialog appears
- ✅ After confirming:
  - Ride removed from list
  - If synced, deleted from backend too
  - Success message appears

**Backend Verification:**
```bash
# Should see: DELETE /api/v1/rides/:id | 200
```

---

### Test 11: Offline Mode

**Objective:** Test offline ride recording and sync

**Steps:**
1. **Disable network:**
   - On emulator: Turn off WiFi/mobile data
   - Or use airplane mode
2. Record a new ride (follow Test 4-6)
3. Save the ride
4. Try to sync - should queue for later
5. **Re-enable network**
6. Tap sync again

**Expected Results:**
- ✅ Can record rides offline
- ✅ Rides save to local database
- ✅ Sync shows "offline" or "pending" status
- ✅ When online, sync uploads queued rides
- ✅ Ride status changes from "local" to "synced"

---

### Test 12: Authentication Persistence

**Objective:** Verify login persists across app restarts

**Steps:**
1. Close the app completely (kill process)
2. Relaunch the app

**Expected Results:**
- ✅ User remains logged in
- ✅ Directly launches to map screen
- ✅ Can immediately record rides
- ✅ Sync works without re-login

**Test Logout:**
1. Tap logout
2. Close and reopen app

**Expected Results:**
- ✅ App launches to login screen
- ✅ Must login again

---

## Troubleshooting

### Backend Issues

#### Issue: Database won't start

```bash
# Check Docker is running
docker ps

# Restart Docker Desktop

# Remove and recreate database
docker-compose down -v
docker-compose up -d
```

#### Issue: Backend can't connect to database

**Check `.env` file:**
- Ensure `DB_HOST=postgres` (not `localhost`)
- Verify password matches docker-compose.yml

```bash
# Test database connection
docker exec -it ridelog_postgres psql -U ridelog -d ridelog_db -c "SELECT 1;"
```

#### Issue: Migrations fail

```bash
# Reset database
docker-compose down -v
docker-compose up -d

# Wait 10 seconds for DB to be ready
sleep 10

# Run migrations again
go run cmd/migrate/main.go up
```

---

### Mobile App Issues

#### Issue: App can't connect to backend

**Android Emulator:**
- Use `http://10.0.2.2:8080/api/v1` (not `localhost`)

**iOS Simulator:**
- Use `http://localhost:8080/api/v1`

**Verify backend is running:**
```bash
curl http://localhost:8080/health
```

#### Issue: GPS not working in emulator

**Android:**
```bash
# Set location manually
adb emu geo fix -122.4194 37.7749

# Verify adb connection
adb devices
```

**iOS:**
- In Simulator: Features → Location → Custom Location
- Enter coordinates manually

#### Issue: Build errors

```bash
# Clean and rebuild
cd mobile
flutter clean
flutter pub get
flutter run
```

#### Issue: Permission errors (Android)

**Check `AndroidManifest.xml` includes:**
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

---

### Common Errors and Fixes

#### Error: "JWT token is invalid"

**Solution:**
- Logout and login again
- Check JWT_SECRET in backend .env matches

#### Error: "Network request failed"

**Solution:**
- Verify backend is running: `curl http://localhost:8080/health`
- Check API URL in mobile app config
- Ensure firewall allows connections

#### Error: "Ride sync failed"

**Solution:**
- Check network connectivity
- Verify JWT token is valid
- Check backend logs for errors

---

## Test Checklist

Use this to track your testing progress:

### Backend
- [ ] Database starts successfully
- [ ] Migrations run without errors
- [ ] Backend server starts
- [ ] Health endpoint responds
- [ ] Can register new user
- [ ] Can login user
- [ ] Can create ride
- [ ] Can fetch rides
- [ ] Can delete ride

### Mobile App - Setup
- [ ] App builds successfully
- [ ] App launches without crashes
- [ ] Map loads and displays

### Mobile App - Authentication
- [ ] Registration works
- [ ] Login works
- [ ] Logout works
- [ ] Auth persists across restarts
- [ ] Protected routes work

### Mobile App - Ride Recording
- [ ] GPS location acquired
- [ ] Start ride button works
- [ ] Route polyline draws on map
- [ ] Live statistics update correctly
- [ ] Stop ride button works
- [ ] Ride summary displays
- [ ] Save ride works (local storage)
- [ ] Discard ride works

### Mobile App - Synchronization
- [ ] Manual sync works
- [ ] Auto-sync triggers
- [ ] Offline rides queue
- [ ] Synced rides marked correctly
- [ ] Connectivity detection works

### Mobile App - Ride History
- [ ] History screen displays rides
- [ ] Pull-to-refresh works
- [ ] Ride cards show correct data
- [ ] Sync status indicators correct

### Mobile App - Ride Details
- [ ] Detail screen displays
- [ ] Map shows full route
- [ ] Start/end markers display
- [ ] Statistics grid correct
- [ ] Map fits to route bounds

### Mobile App - Offline Mode
- [ ] Can record rides offline
- [ ] Offline rides save locally
- [ ] Sync queues offline rides
- [ ] Online sync uploads queued rides

### Error Handling
- [ ] Permission denial handled gracefully
- [ ] Network errors show messages
- [ ] Invalid login shows error
- [ ] No GPS signal handled
- [ ] Backend downtime handled

---

## Performance Benchmarks

Expected performance metrics:

| Operation | Expected Time |
|-----------|---------------|
| Backend startup | < 5 seconds |
| App cold start | < 3 seconds |
| Map load | < 2 seconds |
| GPS fix | < 10 seconds |
| Start ride | < 1 second |
| Save ride | < 500ms |
| Sync ride | < 2 seconds |
| Load history | < 1 second |

---

## Next Steps

After completing all tests:

1. ✅ **Development Complete** - All features verified
2. 🚀 **Ready for Production Deployment** - See [DEPLOYMENT.md](DEPLOYMENT.md)
3. 🎨 **Add Custom App Icon** - See [mobile/assets/icon/README.md](../mobile/assets/icon/README.md)
4. 📱 **Build Release APK/IPA** - For distribution
5. 🌐 **Deploy Backend** - To production server

---

## Support

If you encounter issues not covered here:

1. Check the logs:
   - Backend: terminal running `go run cmd/server/main.go`
   - Mobile: terminal running `flutter run`

2. Review documentation:
   - [ARCHITECTURE.md](ARCHITECTURE.md) - System design
   - [API_SPEC.md](API_SPEC.md) - API documentation
   - [DEPLOYMENT.md](DEPLOYMENT.md) - Production deployment

3. Common fixes:
   - Restart Docker: `docker-compose restart`
   - Clean Flutter: `flutter clean && flutter pub get`
   - Reset database: `docker-compose down -v && docker-compose up -d`

---

**Testing Guide Complete!**

*This guide covers the complete RideLog MVP with all 10 phases implemented.*
