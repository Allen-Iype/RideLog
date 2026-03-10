# RideLog 🏍️

**Track every ride. Relive every road.**

A production-ready mobile application for motorcycle riders to track journeys, visualize routes on maps, and maintain a personal riding history.

[![Status](https://img.shields.io/badge/Status-MVP%20Complete-success)](https://github.com/yourusername/RideLog)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)](https://flutter.dev)
[![Go](https://img.shields.io/badge/Go-1.25-00ADD8)](https://golang.org)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED)](https://www.docker.com)

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
- **[Deployment Guide](docs/DEPLOYMENT.md)** - Production deployment instructions
- **[Progress](docs/PROGRESS.md)** - Detailed implementation progress

## 🏗️ Development Status

**🎉 MVP COMPLETE - Production Ready!**

All 10 phases have been successfully implemented:

- ✅ **Phase 1:** Project Setup
- ✅ **Phase 2:** Map Integration (OpenStreetMap)
- ✅ **Phase 3:** GPS Tracking (Real-time location)
- ✅ **Phase 4:** Ride Recording (Start/stop with live route)
- ✅ **Phase 5:** Local Storage (SQLite with offline support)
- ✅ **Phase 6:** Backend API (Go + PostgreSQL + PostGIS)
- ✅ **Phase 7:** Synchronization (Auto-sync with connectivity detection)
- ✅ **Phase 8:** Authentication (JWT-based with secure storage)
- ✅ **Phase 9:** Ride History (List and detail views with maps)
- ✅ **Phase 10:** Production Readiness (Docker, logging, deployment)

See [PROGRESS.md](docs/PROGRESS.md) for detailed implementation notes.

## ✨ Features

### Mobile App (Flutter)
- ✅ **User Authentication** - Secure JWT-based registration and login
- ✅ **Real-time GPS Tracking** - Accurate location tracking with quality indicators
- ✅ **Ride Recording** - Start/stop recording with live route visualization
- ✅ **Interactive Maps** - OpenStreetMap with current location marker
- ✅ **Live Statistics** - Real-time distance, duration, speed tracking
- ✅ **Offline Support** - Record rides without internet, sync when online
- ✅ **Ride History** - Browse past rides with detailed statistics
- ✅ **Route Visualization** - View complete routes on map with start/end markers
- ✅ **Sync Management** - Manual and automatic sync with connectivity detection
- ✅ **Secure Storage** - Encrypted local storage for sensitive data

### Backend API (Go)
- ✅ **RESTful API** - Clean, documented API endpoints
- ✅ **JWT Authentication** - Secure token-based authentication
- ✅ **PostgreSQL + PostGIS** - Geospatial data storage and queries
- ✅ **User Management** - Registration, login, password hashing
- ✅ **Ride CRUD** - Create, read, delete operations for rides
- ✅ **Route Storage** - GPS points with sequence and metadata
- ✅ **Health Checks** - Monitoring endpoints for production
- ✅ **Structured Logging** - Production-ready logging system
- ✅ **Docker Support** - Containerized deployment ready

## 🧪 Testing

```bash
# Backend tests
cd backend
go test ./...

# Flutter tests
cd mobile
flutter test

# Flutter analyze (code quality)
flutter analyze

# Backend build verification
go build ./cmd/server
```

## 🐳 Docker

### Development
```bash
cd backend
docker-compose up -d
```

### Production
```bash
cd backend
docker-compose -f docker-compose.prod.yml up -d
```

This starts:
- PostgreSQL with PostGIS (port 5432)
- Backend API (port 8080)
- Automatic migrations
- Health monitoring

## 📱 Mobile App Development

### Development
```bash
cd mobile

# Run on iOS simulator
flutter run -d ios

# Run on Android emulator
flutter run -d android

# Run with specific API URL
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
```

### Production Builds
```bash
cd mobile

# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS
flutter build ios --release

# With production API URL
flutter build apk --release --dart-define=API_BASE_URL=https://api.yourdomain.com/api/v1
```

## 🚀 Production Deployment

### Quick Start with Docker

```bash
cd backend

# Copy and configure environment
cp .env.example .env
# Edit .env with your production values

# Deploy
docker-compose -f docker-compose.prod.yml up -d

# Verify
curl http://localhost:8080/health
```

### Using Makefile

```bash
cd backend

# Install dependencies
make install

# Run locally
make dev

# Deploy to production
make prod

# View logs
make docker-logs

# Check health
make health
```

For complete deployment instructions, see [DEPLOYMENT.md](docs/DEPLOYMENT.md).

## 🔐 Environment Variables

Create a `.env` file in the `backend/` directory (see `.env.example`):

```env
# Server Configuration
SERVER_PORT=8080
SERVER_HOST=0.0.0.0

# Database Configuration
DB_HOST=postgres
DB_PORT=5432
DB_USER=ridelog
DB_PASSWORD=your_secure_password
DB_NAME=ridelog_db
DB_SSLMODE=disable

# JWT Configuration
JWT_SECRET=your_jwt_secret_minimum_32_chars
```

**Security:** Never commit `.env` files to version control!

## 📊 Project Statistics

- **Development Time:** 5 days (March 5-10, 2026)
- **Total Commits:** 5
- **Backend Code:** 30+ Go files (~3,000 lines)
- **Frontend Code:** 25+ Dart files (~2,500 lines)
- **Database Tables:** 3 (users, rides, route_points)
- **API Endpoints:** 8 RESTful endpoints
- **Mobile Screens:** 5 (Login, Register, Map, History, Detail)
- **Documentation:** 750+ lines across 5 guides

## 🎯 API Endpoints

### Authentication
- `POST /api/v1/auth/register` - User registration
- `POST /api/v1/auth/login` - User login
- `GET /api/v1/user/me` - Get current user (protected)

### Rides
- `POST /api/v1/rides` - Create new ride (protected)
- `GET /api/v1/rides` - List all rides (protected)
- `GET /api/v1/rides/:id` - Get ride details (protected)
- `DELETE /api/v1/rides/:id` - Delete ride (protected)

### Health
- `GET /health` - Health check endpoint

See [API_SPEC.md](docs/API_SPEC.md) for complete documentation.

## 🤝 Contributing

This project was built as a solo developer MVP. Contributions are welcome!

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
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
