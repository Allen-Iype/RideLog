# RideLog - Deployment Guide

This guide covers how to deploy the RideLog backend API to production and configure the mobile app for production use.

---

## Backend Deployment

### Prerequisites

- Docker and Docker Compose installed
- A server with ports 8080 (API) and 5432 (PostgreSQL) available
- Domain name (optional, but recommended for HTTPS)

### Production Deployment Steps

#### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd RideLog/backend
```

#### 2. Create Environment File

Copy the example environment file and configure it:

```bash
cp .env.example .env
```

Edit `.env` with your production values:

```env
# Server Configuration
SERVER_PORT=8080
SERVER_HOST=0.0.0.0

# Database Configuration
DB_HOST=postgres
DB_PORT=5432
DB_USER=ridelog
DB_PASSWORD=<STRONG_PASSWORD_HERE>
DB_NAME=ridelog_db
DB_SSLMODE=disable

# JWT Configuration
JWT_SECRET=<LONG_RANDOM_STRING_HERE>
```

**Security Notes:**
- Use a strong, random password for `DB_PASSWORD`
- Generate a secure random string for `JWT_SECRET` (e.g., `openssl rand -base64 32`)
- Never commit the `.env` file to version control

#### 3. Deploy with Docker Compose

```bash
# Build and start all services
docker-compose -f docker-compose.prod.yml up -d

# Check service status
docker-compose -f docker-compose.prod.yml ps

# View logs
docker-compose -f docker-compose.prod.yml logs -f backend
```

#### 4. Verify Deployment

Test the health endpoint:

```bash
curl http://your-server-ip:8080/health
```

Expected response:
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "database": "connected"
}
```

### Production Best Practices

#### Enable HTTPS with Nginx

Create `nginx.conf`:

```nginx
server {
    listen 80;
    server_name api.yourdomain.com;

    # Redirect to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.yourdomain.com;

    ssl_certificate /etc/ssl/certs/your-cert.crt;
    ssl_certificate_key /etc/ssl/private/your-key.key;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

#### Database Backups

Set up automated backups:

```bash
# Create backup script
cat > backup.sh <<'EOF'
#!/bin/bash
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)
docker exec ridelog_postgres_prod pg_dump -U ridelog ridelog_db > "$BACKUP_DIR/ridelog_$DATE.sql"
# Keep only last 7 days
find $BACKUP_DIR -name "ridelog_*.sql" -mtime +7 -delete
EOF

chmod +x backup.sh

# Add to crontab (daily at 2 AM)
echo "0 2 * * * /path/to/backup.sh" | crontab -
```

#### Monitoring

Monitor your services:

```bash
# Check resource usage
docker stats ridelog_backend_prod ridelog_postgres_prod

# Check logs for errors
docker-compose -f docker-compose.prod.yml logs --tail=100 backend | grep ERROR
```

### Updating the Application

```bash
# Pull latest changes
git pull origin main

# Rebuild and restart
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d --build

# Verify
curl http://your-server-ip:8080/health
```

---

## Mobile App Configuration

### Update API Base URL

Before building for production, update the API base URL in the mobile app:

**File:** `mobile/lib/services/api_client.dart`

```dart
// Change from:
static const String baseUrl = 'http://localhost:8080/api/v1';

// To your production URL:
static const String baseUrl = 'https://api.yourdomain.com/api/v1';
```

**File:** `mobile/lib/services/auth_service.dart`

```dart
// Change from:
static const String baseUrl = 'http://localhost:8080/api/v1';

// To your production URL:
static const String baseUrl = 'https://api.yourdomain.com/api/v1';
```

### Build for Production

#### Android

```bash
cd mobile

# Build APK
flutter build apk --release

# Or build App Bundle (recommended for Play Store)
flutter build appbundle --release

# Output locations:
# APK: build/app/outputs/flutter-apk/app-release.apk
# Bundle: build/app/outputs/bundle/release/app-release.aab
```

#### iOS

```bash
cd mobile

# Build for iOS
flutter build ios --release

# Output: build/ios/iphoneos/Runner.app
```

### Environment-Specific Configuration

For managing multiple environments (dev, staging, production), consider using flavors:

**File:** `mobile/lib/config/environment.dart`

```dart
class Environment {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api/v1',
  );
}
```

Build with environment variable:

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://api.yourdomain.com/api/v1
```

---

## Production Checklist

### Backend
- [ ] Environment variables configured securely
- [ ] Strong database password set
- [ ] JWT secret generated (minimum 32 characters)
- [ ] HTTPS/SSL configured (if using domain)
- [ ] Database backups automated
- [ ] Monitoring set up
- [ ] Firewall configured (only expose necessary ports)
- [ ] Regular updates scheduled

### Mobile App
- [ ] Production API URL configured
- [ ] App icons created
- [ ] Splash screen configured
- [ ] Release builds tested
- [ ] App signing configured
- [ ] Privacy policy added (if required)
- [ ] Terms of service added (if required)

---

## Troubleshooting

### Backend Won't Start

```bash
# Check logs
docker-compose -f docker-compose.prod.yml logs backend

# Check if database is ready
docker-compose -f docker-compose.prod.yml logs postgres

# Restart services
docker-compose -f docker-compose.prod.yml restart
```

### Database Connection Issues

```bash
# Test database connectivity
docker exec -it ridelog_postgres_prod psql -U ridelog -d ridelog_db -c "SELECT 1;"

# Check database logs
docker-compose -f docker-compose.prod.yml logs postgres | tail -50
```

### Mobile App Can't Connect

1. Verify API URL is correct and accessible
2. Check if HTTPS certificate is valid
3. Test API endpoint with curl:
   ```bash
   curl https://api.yourdomain.com/api/v1/health
   ```
4. Check mobile app logs for specific errors

---

## Security Recommendations

1. **Use HTTPS**: Always use HTTPS in production
2. **Strong Passwords**: Use long, random passwords
3. **Regular Updates**: Keep dependencies and OS updated
4. **Firewall**: Only expose necessary ports
5. **Rate Limiting**: Consider adding rate limiting to prevent abuse
6. **Monitoring**: Set up alerts for suspicious activity
7. **Backups**: Automate regular database backups
8. **Secrets Management**: Never commit secrets to version control

---

## Support

For issues or questions:
- Check logs: `docker-compose -f docker-compose.prod.yml logs`
- Review documentation in `/docs`
- Create an issue on GitHub
