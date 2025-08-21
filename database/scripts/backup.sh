#!/bin/bash

# Database Backup Script
# Script untuk backup database PostgreSQL

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi

# Configuration
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-5432}
DB_NAME=${DB_NAME:-geotagging_usaha_dev}
DB_USER=${DB_USER:-postgres}
BACKUP_DIR="database/backups"
DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/backup_${DB_NAME}_${DATE}.sql"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Create backup directory if it doesn't exist
mkdir -p ${BACKUP_DIR}

# Check if PostgreSQL tools are available
if ! command -v pg_dump &> /dev/null; then
    log_error "pg_dump not found. Please install PostgreSQL client tools."
    exit 1
fi

log_info "Starting database backup..."
log_info "Database: ${DB_NAME}"
log_info "Host: ${DB_HOST}:${DB_PORT}"
log_info "Backup file: ${BACKUP_FILE}"

# Perform backup
export PGPASSWORD=${DB_PASSWORD}

pg_dump \
    --host=${DB_HOST} \
    --port=${DB_PORT} \
    --username=${DB_USER} \
    --dbname=${DB_NAME} \
    --no-password \
    --verbose \
    --clean \
    --if-exists \
    --create \
    --format=plain \
    --file=${BACKUP_FILE}

# Check if backup was successful
if [ $? -eq 0 ]; then
    log_info "Backup completed successfully!"
    
    # Compress backup file
    log_info "Compressing backup file..."
    gzip ${BACKUP_FILE}
    
    if [ $? -eq 0 ]; then
        log_info "Backup file compressed: ${BACKUP_FILE}.gz"
        
        # Get file size
        SIZE=$(du -h "${BACKUP_FILE}.gz" | cut -f1)
        log_info "Backup size: ${SIZE}"
    else
        log_warn "Failed to compress backup file"
    fi
    
    # Clean up old backups (keep last 7 days)
    log_info "Cleaning up old backups..."
    find ${BACKUP_DIR} -name "backup_${DB_NAME}_*.sql.gz" -mtime +7 -delete
    
    log_info "Backup process completed!"
else
    log_error "Backup failed!"
    exit 1
fi

# Unset password
unset PGPASSWORD
