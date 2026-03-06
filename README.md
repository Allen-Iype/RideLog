# RideLog

**Track every ride. Relive every road.**

A mobile application for motorcycle riders to track journeys, visualize routes on maps, and maintain a personal riding history.

## 🏍️ Overview

RideLog is designed specifically for motorcycle enthusiasts who want to:
- Track their rides with GPS accuracy
- Visualize routes on interactive maps
- Store and review riding history
- Analyze ride statistics (distance, duration, speed)
- Record rides offline and sync when connected

## 🛠️ Tech Stack

| Component | Technology |
|-----------|------------|
| **Mobile App** | Flutter (Dart) |
| **Backend API** | Go (Gin framework) |
| **Database** | PostgreSQL + PostGIS |
| **Maps** | OpenStreetMap / Mapbox |
| **Authentication** | JWT |
| **Deployment** | Docker + Cloud VM |

## 📁 Project Structure

```
RideLog/
├── docs/                 # Project documentation
│   ├── PROJECT_PLAN.md   # Development roadmap
│   ├── ARCHITECTURE.md   # System architecture
│   └── API_SPEC.md       # API specification
├── mobile/               # Flutter mobile application
│   ├── lib/              # Dart source code
│   ├── android/          # Android platform code
│   └── ios/              # iOS platform code
└── backend/              # Go backend API
    ├── cmd/              # Application entry points
    ├── internal/         # Private application code
    ├── pkg/              # Public libraries
    └── migrations/       # Database migrations
```

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK:** 3.x or higher
- **Go:** 1.21 or higher
- **Docker:** Latest version
- **Docker Compose:** Latest version
- **Git:** Latest version

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/RideLog.git
   cd RideLog
   ```

2. **Start the database:**
   ```bash
   cd backend
   docker-compose up -d
   ```

3. **Run the backend:**
   ```bash
   cd backend
   go run cmd/server/main.go
   ```

   Backend will be available at `http://localhost:8080`

4. **Run the mobile app:**
   ```bash
   cd mobile
   flutter pub get
   flutter run
   ```

### Verify Setup

- **Database:**
  ```bash
  docker exec -it ridelog_postgres psql -U ridelog -d ridelog_db -c "SELECT PostGIS_Version();"
  ```

- **Backend:**
  ```bash
  curl http://localhost:8080/health
  ```

- **Flutter:**
  ```bash
  cd mobile && flutter doctor
  ```

## 📚 Documentation

Comprehensive documentation is available in the `docs/` directory:

- **[Project Plan](docs/PROJECT_PLAN.md)** - Development phases, tasks, and milestones
- **[Architecture](docs/ARCHITECTURE.md)** - System design and technical decisions
- **[API Specification](docs/API_SPEC.md)** - Complete API documentation

## 🏗️ Development Status

**Current Phase:** Phase 1 - Project Setup ✅

### Completed
- [x] Project documentation
- [x] Flutter project structure
- [x] Go backend skeleton
- [x] PostgreSQL + PostGIS setup
- [x] Git repository initialization

### In Progress
- [ ] Phase 2 - Map Integration

### Upcoming
- [ ] Phase 3 - GPS Tracking
- [ ] Phase 4 - Ride Recording
- [ ] Phase 5 - Local Storage
- [ ] Phase 6 - Backend API
- [ ] Phase 7 - Synchronization
- [ ] Phase 8 - Authentication
- [ ] Phase 9 - Ride History
- [ ] Phase 10 - Production Deployment

See [PROJECT_PLAN.md](docs/PROJECT_PLAN.md) for detailed progress tracking.

## 🎯 MVP Features

The initial release (MVP) includes:

1. ✅ User authentication (register/login)
2. ✅ Start and stop ride recording
3. ✅ Real-time GPS tracking
4. ✅ Live route visualization on map
5. ✅ Ride statistics (distance, duration, speed)
6. ✅ Offline ride recording
7. ✅ Ride history and details
8. ✅ Automatic sync when online

## 🧪 Testing

```bash
# Run backend tests
cd backend
go test ./...

# Run Flutter tests
cd mobile
flutter test
```

## 🐳 Docker

Run the entire stack with Docker:

```bash
docker-compose up -d
```

This starts:
- PostgreSQL with PostGIS on port 5432
- Backend API on port 8080 (future)

## 📱 Mobile App Development

```bash
# Run on iOS simulator
cd mobile
flutter run -d ios

# Run on Android emulator
flutter run -d android

# Build release APK
flutter build apk

# Build iOS app
flutter build ios
```

## 🔐 Environment Variables

Create a `.env` file in the `backend/` directory:

```env
# Database
DB_HOST=localhost
DB_PORT=5432
DB_USER=ridelog
DB_PASSWORD=ridelog_dev_password
DB_NAME=ridelog_db

# JWT
JWT_SECRET=your-secret-key-change-in-production

# Server
PORT=8080
ENVIRONMENT=development
```

## 🤝 Contributing

This is a solo developer project, but contributions are welcome!

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

MIT License - see LICENSE file for details

## 🙏 Acknowledgments

- Flutter team for the excellent framework
- PostGIS for geospatial capabilities
- OpenStreetMap for map data

## 📧 Contact

For questions or feedback, please open an issue on GitHub.

---

**Built with ❤️ for motorcycle riders**
