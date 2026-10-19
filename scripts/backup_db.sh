#!/usr/bin/env bash
# ==============================================================================
# SonarQube PostgreSQL Automated Backup Script
# Creates a compressed dump of the database and removes backups older than 7 days
# Can be scheduled in cron: 0 3 * * * /path/to/scripts/backup_db.sh
# ==============================================================================

set -euo pipefail

BACKUP_DIR="${BACKUP_DIR:-/opt/backups/sonarqube}"
CONTAINER_NAME="${DB_CONTAINER:-sonarqube_postgres}"
DB_USER="${POSTGRES_USER:-sonar}"
DB_NAME="${POSTGRES_DB:-sonar}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/sonar_db_${TIMESTAMP}.sql.gz"

mkdir -p "$BACKUP_DIR"

echo "[$(date -Iseconds)] Starting PostgreSQL backup for ${DB_NAME}..."

# Execute pg_dump inside container and compress with gzip
if docker exec "$CONTAINER_NAME" pg_dump -U "$DB_USER" "$DB_NAME" | gzip > "$BACKUP_FILE"; then
    echo "[$(date -Iseconds)] Backup created successfully: ${BACKUP_FILE} ($(du -h "$BACKUP_FILE" | cut -f1))"
else
    echo "[ERROR] Database backup failed!" >&2
    exit 1
fi

# Clean up backups older than 7 days
find "$BACKUP_DIR" -type f -name "sonar_db_*.sql.gz" -mtime +7 -delete
echo "[$(date -Iseconds)] Backup rotation completed. Preserving last 7 days."
