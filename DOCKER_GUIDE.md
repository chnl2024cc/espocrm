# EspoCRM Docker Setup Guide

This guide explains how to run EspoCRM using Docker with the provided configuration files.

## Overview

The Docker setup includes:
- **Dockerfile**: PHP 8.2 with Apache and necessary extensions
- **docker-compose.yml**: Multi-service setup with EspoCRM and MariaDB
- **espocrm.conf**: Apache virtual host configuration
- **my-cron**: Cron job setup for scheduled tasks
- **php-web.ini**: Optimized PHP settings for web performance

## Prerequisites

- Docker Engine 20.10+ 
- Docker Compose 2.0+
- Git (to clone the repository)

## Quick Start

### 1. Clone the Repository
```bash
git clone <repository-url>
cd espocrm
```

### 2. Build and Start Services

#### Option A: Build and Start in One Command
```bash
docker-compose up --build
```

#### Option B: Build First, Then Start
```bash
# Build the EspoCRM image
docker-compose build

# Start all services
docker-compose up -d
```

### 3. Access EspoCRM

Once the containers are running, access EspoCRM at:
- **URL**: http://localhost:8080
- **Database**: MariaDB 10.11 (accessible on port 3306)

## Configuration Details

### Dockerfile Features

The Dockerfile (`Dockerfile`) includes:

- **Base Image**: PHP 8.2 with Apache
- **PHP Extensions**: GD, PDO MySQL, Intl, Zip, BCMath, SOAP, OPcache, Exif
- **System Dependencies**: Cron, Unzip, Git, Curl, and various development libraries
- **Composer**: Installed globally for dependency management
- **Frontend Build**: Node.js and npm for building frontend assets
- **Cron Jobs**: Configured for scheduled tasks
- **Security**: Proper file ownership and Git safe directory configuration

### Docker Compose Services

The `docker-compose.yml` defines two services:

#### EspoCRM Service
- **Image**: Built from local Dockerfile
- **Port**: 8080 (host) → 80 (container)
- **Volumes**: 
  - `espocrm-data`: Persistent data storage
  - `espocrm-uploads`: File uploads storage
- **Dependencies**: Waits for MariaDB to be ready

#### MariaDB Service
- **Image**: mariadb:10.11
- **Database**: espocrm
- **Credentials**:
  - Root password: `root`
  - Database: `espocrm`
  - User: `espocrm`
  - Password: `espocrm`
- **Volume**: `db-data` for persistent database storage

### Apache Configuration

The `espocrm.conf` file configures:
- Document root pointing to `/var/www/html`
- `.htaccess` support for URL rewriting
- Client folder alias for static assets
- Custom error and access logging

### Cron Jobs

The `my-cron` file sets up:
- EspoCRM cron job running every minute
- Logs output to `/var/log/cron.log`

### PHP Settings

The `php-web.ini` optimizes PHP for web usage:
- Max execution time: 180 seconds
- Max input time: 180 seconds
- Memory limit: 256MB
- Max file upload: 20MB

## Management Commands

### Start Services
```bash
# Start in foreground (see logs)
docker-compose up

# Start in background
docker-compose up -d
```

### Stop Services
```bash
# Stop services
docker-compose stop

# Stop and remove containers
docker-compose down
```

### View Logs
```bash
# View all logs
docker-compose logs

# View specific service logs
docker-compose logs espocrm
docker-compose logs db

# Follow logs in real-time
docker-compose logs -f
```

### Rebuild After Changes
```bash
# Rebuild and restart
docker-compose up --build

# Force rebuild without cache
docker-compose build --no-cache
```

### Access Container Shell
```bash
# Access EspoCRM container
docker-compose exec espocrm bash

# Access database container
docker-compose exec db bash
```

## Data Persistence

The setup uses Docker volumes for data persistence:

- **Database Data**: Stored in `db-data` volume
- **EspoCRM Data**: Stored in `espocrm-data` volume  
- **File Uploads**: Stored in `espocrm-uploads` volume

These volumes persist data even when containers are removed.

## Troubleshooting

### Common Issues

1. **Port Already in Use**
   ```bash
   # Check what's using port 8080
   netstat -tulpn | grep :8080
   
   # Change port in docker-compose.yml if needed
   ports:
     - "8081:80"  # Use port 8081 instead
   ```

2. **Permission Issues**
   ```bash
   # Fix file permissions
   docker-compose exec espocrm chown -R www-data:www-data /var/www/html
   ```

3. **Database Connection Issues**
   ```bash
   # Check if database is ready
   docker-compose logs db
   
   # Test database connection
   docker-compose exec espocrm php -r "new PDO('mysql:host=db;dbname=espocrm', 'espocrm', 'espocrm');"
   ```

4. **Cron Jobs Not Running**
   ```bash
   # Check cron logs
   docker-compose exec espocrm cat /var/log/cron.log
   
   # Verify cron is running
   docker-compose exec espocrm ps aux | grep cron
   ```

### Reset Everything
```bash
# Stop and remove everything (including volumes)
docker-compose down -v

# Remove images
docker-compose down --rmi all

# Start fresh
docker-compose up --build
```

## Production Considerations

For production deployment, consider:

1. **Environment Variables**: Use `.env` file for sensitive data
2. **SSL/TLS**: Configure HTTPS with reverse proxy
3. **Backup Strategy**: Regular database and file backups
4. **Resource Limits**: Set memory and CPU limits in docker-compose.yml
5. **Security**: Use secrets management for database credentials
6. **Monitoring**: Add health checks and monitoring

## Support

For issues related to:
- **EspoCRM**: Check the [official documentation](https://docs.espocrm.com/)
- **Docker**: Refer to [Docker documentation](https://docs.docker.com/)
- **This Setup**: Check the logs and troubleshooting section above
