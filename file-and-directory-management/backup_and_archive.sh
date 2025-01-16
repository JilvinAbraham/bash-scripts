#!/bin/bash

# Configuration
SOURCE_PATHS=("/path/to/source1" "/path/to/source2")  # Paths to backup
BACKUP_DIR="/path/to/backup"  # Backup destination
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")  # Current date and time
LOG_FILE="${BACKUP_DIR}/backup_log_${TIMESTAMP}.log"

# Create the backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Start logging
echo "Backup started at $(date)" > "$LOG_FILE"

# Backup each source path
for SOURCE in "${SOURCE_PATHS[@]}"; do
    if [ -e "$SOURCE" ]; then # check if source paths exists
        DEST="${BACKUP_DIR}/$(basename "$SOURCE")_${TIMESTAMP}.tar.gz"
        echo "Backing up $SOURCE to $DEST" >> "$LOG_FILE"
        tar -czf "$DEST" "$SOURCE" 2>> "$LOG_FILE" # archive and compress write error to log file
        if [ $? -eq 0 ]; then # check if last command was successfull
            echo "Backup of $SOURCE successful" >> "$LOG_FILE"
        else
            echo "Error: Backup of $SOURCE failed" >> "$LOG_FILE"
        fi
    else
        echo "Warning: $SOURCE does not exist" >> "$LOG_FILE"
    fi
done

# End logging
echo "Backup completed at $(date)" >> "$LOG_FILE"

# Print completion message
echo "Backup process finished. Logs are available at $LOG_FILE"

