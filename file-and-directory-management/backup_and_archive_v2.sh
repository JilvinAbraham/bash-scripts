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

# Function to perform backup for each source
backup_source() {
    SOURCE=$1
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
    
    # Create a separate log file for each backup process
    LOG_FILE_PROCESS="${BACKUP_DIR}/backup_${BASENAME}_${TIMESTAMP}.log"
    echo "Performing $BACKUP_TYPE backup for $SOURCE to $DEST" > "$LOG_FILE_PROCESS"

    # Perform backup
    tar --listed-incremental="$SNAPSHOT_FILE" -czf "$DEST" "$SOURCE" 2>> "$LOG_FILE_PROCESS"

    if [ $? -eq 0 ]; then
        echo "$BACKUP_TYPE backup of $SOURCE successful" >> "$LOG_FILE_PROCESS"
    else
        echo "Error: $BACKUP_TYPE backup of $SOURCE failed" >> "$LOG_FILE_PROCESS"
    fi

    # Append each backup log to the main log
    cat "$LOG_FILE_PROCESS" >> "$LOG_FILE"
}

# Backup each source in parallel
for SOURCE in "${SOURCE_PATHS[@]}"; do
    if [ -e "$SOURCE" ]; then
        backup_source "$SOURCE" &  # Run backup in the background
    else
        echo "Warning: $SOURCE does not exist" >> "$LOG_FILE"
    fi
done

# Wait for all background processes to finish
wait

# End logging
echo "Backup completed at $(date)" >> "$LOG_FILE"

# Print completion message
echo "Backup process finished. Logs are available at $LOG_FILE"
