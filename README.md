# RideLog

Mobile app for recording motorcycle rides: real-time GPS tracking with live route display on OpenStreetMap, offline recording with automatic sync, JWT-authenticated accounts, and ride history with per-ride stats (distance, duration, speed).

**Status:** working MVP, built solo in ~6 days (March 2026). Runs locally end-to-end; not deployed to app stores.

## Tech stack

| Component | Technology |
|-----------|------------|
| Mobile app | Flutter (Dart), SQLite for offline storage |
| Backend API | Go (Gin) |
| Database | PostgreSQL + PostGIS |
| Maps | OpenStreetMap |
| Auth | JWT |
| Deployment | Docker Compose |

## Project structure

```
RideLog/
├── docs/                 # Architecture, API spec, setup/testing/deployment guides
├── mobile/               # Flutter app
│   ├── lib/              # Dart source
│   ├── android/
│   └── ios/
└── backend/              # Go API
    ├── cmd/              # Entry points
    ├── internal/         # Application code
    └── migrations/       # Database migrations
```

## Getting started

Prerequisites: Flutter SDK 3.x, Go 1.21+, Docker + Compose.

```bash
git clone https://github.com/Allen-Iype/RideLog.git
cd RideLog

# Start the database
cd backend
docker-compose up -d

# Run the backend (http://localhost:8080)
go run cmd/server/main.go

# Run the mobile app
cd ../mobile
flutter pub get
flutter run
```

Verify: `curl http://localhost:8080/health` for the API; `docker exec -it ridelog_postgres psql -U ridelog -d ridelog_db -c "SELECT PostGIS_Version();"` for the database.

See [docs/SETUP_AND_TEST.md](docs/SETUP_AND_TEST.md) for the full setup and end-to-end testing walkthrough, and the rest of `docs/` for the architecture, API spec, and deployment notes.

## What works

- **Mobile:** registration/login, live GPS tracking with quality indicators, start/stop ride recording with live route drawn on the map, offline recording (SQLite) with manual and automatic sync on reconnect, ride history with route playback on a map.
- **Backend:** 8 REST endpoints (auth, ride CRUD, health check), JWT auth with hashed passwords, PostGIS storage of GPS points with sequence metadata, structured logging, Dockerized with migrations run on startup.

## API

```
POST   /api/v1/auth/register
POST   /api/v1/auth/login
GET    /api/v1/user/me          (protected)
POST   /api/v1/rides            (protected)
GET    /api/v1/rides            (protected)
GET    /api/v1/rides/:id        (protected)
DELETE /api/v1/rides/:id        (protected)
GET    /health
```

Full request/response documentation: [docs/API_SPEC.md](docs/API_SPEC.md).

## Testing

```bash
cd backend && go test ./...
cd mobile && flutter test && flutter analyze
```

## Configuration

Backend config lives in `backend/.env` (copy from `.env.example`): server host/port, Postgres connection, and `JWT_SECRET` (32+ chars). Point the mobile app at a non-default API with `flutter run --dart-define=API_BASE_URL=...`.

Production compose: `docker-compose -f docker-compose.prod.yml up -d` — see [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md).

## Known limitations

- Not load-tested; single-user-scale MVP.
- App uses Flutter's default launcher icon.
- No automated E2E tests — testing procedures are manual, documented in [docs/TESTING_GUIDE.md](docs/TESTING_GUIDE.md).

## How this was built

Built by directing AI coding agents (Claude Code) through a phased plan (see `docs/PROJECT_PLAN.md` and `docs/PROGRESS.md`); architecture choices, review, and testing are mine.

## License

MIT — see [LICENSE](LICENSE).
