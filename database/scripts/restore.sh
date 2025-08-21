#!/bin/bash

# Database Restore Script
# Script untuk restore database PostgreSQL dari backup

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

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

show_usage() {
    echo -e "${BLUE}Usage:${NC} $0 [backup_file]"
    echo ""
    echo "Options:"
    echo "  backup_file    Path to backup file (optional, will show list if not provided)"
    echo ""
    echo "Examples:"
    echo "  $0"
    echo "  $0 database/backups/backup_geotagging_usaha_dev_20240101_120000.sql.gz"
}

list_backups() {
    echo -e "${BLUE}Available backup files:${NC}"
    echo ""
    
    local count=0
    for file in ${BACKUP_DIR}/backup_${DB_NAME}_*.sql.gz; do
        if [ -f "$file" ]; then
            count=$((count + 1))
            local size=$(du -h "$file" | cut -f1)
            local date=$(basename "$file" | sed 's/backup_'${DB_NAME}'_\(.*\)\.sql\.gz/\1/')
            local formatted_date=$(echo $date | sed 's/\([0-9]\{8\}\)_\([0-9]\{6\}\)/\1 \2/' | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\) \([0-9]\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1-\2-\3 \4:\5:\6/')
            echo -e "${count}. ${file}"
            echo -e "   Size: ${size}"
            echo -e "   Date: ${formatted_date}"
            echo ""
        fi
    done
    
    if [ $count -eq 0 ]; then
        log_warn "No backup files found in ${BACKUP_DIR}"
        return 1
    fi
    
    return 0
}

# Check if PostgreSQL tools are available
if ! command -v psql &> /dev/null; then
    log_error "psql not found. Please install PostgreSQL client tools."
    exit 1
fi

# Handle command line arguments
if [ $# -eq 0 ]; then
    list_backups
    if [ $? -eq 0 ]; then
        echo -e "${BLUE}Enter the full path of the backup file to restore:${NC}"
        read -r BACKUP_FILE
    else
        exit 1
    fi
elif [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_usage
    exit 0
else
    BACKUP_FILE="$1"
fi

# Validate backup file
if [ ! -f "${BACKUP_FILE}" ]; then
    log_error "Backup file not found: ${BACKUP_FILE}"
    exit 1
fi

# Check if file is compressed
if [[ "${BACKUP_FILE}" == *.gz ]]; then
    IS_COMPRESSED=true
    TEMP_FILE="/tmp/$(basename ${BACKUP_FILE} .gz)"
else
    IS_COMPRESSED=false
    TEMP_FILE="${BACKUP_FILE}"
fi

# Warning message
echo -e "${RED}WARNING:${NC} This will completely replace the current database!"
echo -e "Database: ${DB_NAME}"
echo -e "Host: ${DB_HOST}:${DB_PORT}"
echo -e "Backup file: ${BACKUP_FILE}"
echo ""
echo -e "${YELLOW}Are you sure you want to continue? (type 'yes' to confirm):${NC}"
read -r CONFIRMATION

if [ "${CONFIRMATION}" != "yes" ]; then
    log_info "Restore cancelled."
    exit 0
fi

log_info "Starting database restore..."

# Decompress backup file if needed
if [ "${IS_COMPRESSED}" = true ]; then
    log_info "Decompressing backup file..."
    gunzip -c "${BACKUP_FILE}" > "${TEMP_FILE}"
    
    if [ $? -ne 0 ]; then
        log_error "Failed to decompress backup file"
        exit 1
    fi
fi

# Set password
export PGPASSWORD=${DB_PASSWORD}

# Restore database
log_info "Restoring database..."

psql \
    --host=${DB_HOST} \
    --port=${DB_PORT} \
    --username=${DB_USER} \
    --dbname=postgres \
    --no-password \
    --quiet \
    --file="${TEMP_FILE}"

# Check if restore was successful
if [ $? -eq 0 ]; then
    log_info "Database restore completed successfully!"
    
    # Verify database
    log_info "Verifying database..."
    TABLE_COUNT=$(psql --host=${DB_HOST} --port=${DB_PORT} --username=${DB_USER} --dbname=${DB_NAME} --no-password --tuples-only --command="SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" | xargs)
    
    if [ "${TABLE_COUNT}" -gt 0 ]; then
        log_info "Database verification successful. Found ${TABLE_COUNT} tables."
    else
        log_warn "Database verification failed or no tables found."
    fi
else
    log_error "Database restore failed!"
    exit 1
fi

# Clean up temporary file
if [ "${IS_COMPRESSED}" = true ] && [ -f "${TEMP_FILE}" ]; then
    rm "${TEMP_FILE}"
fi

# Unset password
unset PGPASSWORD

log_info "Restore process completed!"
