#!/bin/bash

# Configuration
SOURCE_PATHS=("/path/to/source1" "/path/to/source2")  # Paths to backup
BACKUP_DIR="/path/to/backup"  # Backup destination
SNAPSHOT_DIR="${BACKUP_DIR}/snapshots"  # Directory for snapshot files
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")  # Current date and time
LOG_FILE="${BACKUP_DIR}/backup_log_${TIMESTAMP}.log"
INCREMENTAL_MODE=true  # Set to true for incremental backups

# Create necessary directories
mkdir -p "$BACKUP_DIR"
mkdir -p "$SNAPSHOT_DIR"

# Start logging
echo "Backup started at $(date)" > "$LOG_FILE"

# Backup each source path
for SOURCE in "${SOURCE_PATHS[@]}"; do
    if [ -e "$SOURCE" ]; then
        BASENAME=$(basename "$SOURCE")
        SNAPSHOT_FILE="${SNAPSHOT_DIR}/${BASENAME}_snapshot.snar"
        BACKUP_TYPE="incremental"
        BACKUP_SUFFIX="_incremental_${TIMESTAMP}.tar.gz"

        # Determine backup type (full or incremental)
        if [ "$INCREMENTAL_MODE" = false ] || [ ! -f "$SNAPSHOT_FILE" ]; then
            BACKUP_TYPE="full"
            BACKUP_SUFFIX="_full_${TIMESTAMP}.tar.gz"
        fi

        DEST="${BACKUP_DIR}/${BASENAME}${BACKUP_SUFFIX}"
        echo "Performing $BACKUP_TYPE backup for $SOURCE to $DEST" >> "$LOG_FILE"

        tar --listed-incremental="$SNAPSHOT_FILE" -czf "$DEST" "$SOURCE" 2>> "$LOG_FILE"

        if [ $? -eq 0 ]; then
            echo "$BACKUP_TYPE backup of $SOURCE successful" >> "$LOG_FILE"
        else
            echo "Error: $BACKUP_TYPE backup of $SOURCE failed" >> "$LOG_FILE"
        fi
    else
        echo "Warning: $SOURCE does not exist" >> "$LOG_FILE"
    fi
done

# End logging
echo "Backup completed at $(date)" >> "$LOG_FILE"

# Print completion message
echo "Backup process finished. Logs are available at $LOG_FILE"
