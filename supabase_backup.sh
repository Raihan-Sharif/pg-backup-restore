#!/bin/bash

# Supabase PostgreSQL Backup Script
# Usage:
#   Interactive: ./supabase_backup.sh
#   Direct:      ./supabase_backup.sh "postgresql://postgres.[your-password]@aws-0-eu-central-1.pooler.supabase.com:5432/postgres"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Supabase PostgreSQL Backup ===${NC}\n"

# Use PostgreSQL 17 explicitly
PG_DUMP="/opt/homebrew/opt/postgresql@17/bin/pg_dump"

# Check if pg_dump is installed
if [ ! -f "$PG_DUMP" ]; then
    echo -e "${RED}Error: pg_dump version 17 not found at $PG_DUMP${NC}"
    echo "Install PostgreSQL 17 client tools:"
    echo "  brew install postgresql@17"
    exit 1
fi

# Display version
PG_VERSION=$($PG_DUMP --version)
echo -e "${GREEN}Using: $PG_VERSION${NC}\n"

# Get connection string from argument or prompt
if [ -n "$1" ]; then
    SOURCE_DB="$1"
    echo -e "${GREEN}Using connection string from argument${NC}\n"
else
    # Prompt for source connection string
    echo -e "${YELLOW}Enter SOURCE Supabase connection string (paste as single line):${NC}"
    echo -e "${YELLOW}Note: Use the Session mode connection string (port 5432) for pg_dump${NC}"
    echo "(Format: postgresql://postgres.[your-password]@aws-0-eu-central-1.pooler.supabase.com:5432/postgres)"
    echo ""
    read -r SOURCE_DB
fi

if [ -z "$SOURCE_DB" ]; then
    echo -e "${RED}Error: Source connection string cannot be empty${NC}"
    exit 1
fi

# Validate connection string format
if [[ ! "$SOURCE_DB" =~ ^postgresql:// ]] && [[ ! "$SOURCE_DB" =~ ^postgres:// ]]; then
    echo -e "${RED}Error: Invalid connection string format${NC}"
    echo "Must start with: postgresql:// or postgres://"
    exit 1
fi

# Extract database name from connection string
DB_NAME=$(echo "$SOURCE_DB" | sed -E 's|.*://[^/]*/([^?]+).*|\1|')

# Validate database name extraction
if [ -z "$DB_NAME" ] || [[ "$DB_NAME" == *"://"* ]] || [[ "$DB_NAME" == *"@"* ]]; then
    echo -e "${RED}Error: Could not extract database name from connection string${NC}"
    echo "Connection string format should be:"
    echo "postgresql://user:password@host/dbname"
    echo ""
    echo -e "${YELLOW}Tip: Make sure to paste the entire connection string as a SINGLE LINE${NC}"
    exit 1
fi

echo -e "${GREEN}Database: $DB_NAME${NC}"

# Create backup directory if it doesn't exist
BACKUP_DIR="db_backups"
mkdir -p "$BACKUP_DIR"

# Generate backup filename with database name and timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/supabase_${DB_NAME}_${TIMESTAMP}.dump"

echo -e "\n${GREEN}Starting backup...${NC}"
echo "Output file: $BACKUP_FILE"

# Perform backup
$PG_DUMP -Fc -v --no-owner --no-acl -d "$SOURCE_DB" -f "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    FILE_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo -e "\n${GREEN}✓ Backup completed successfully!${NC}"
    echo -e "File: $BACKUP_FILE ($FILE_SIZE)"
    echo -e "\n${YELLOW}To restore, run:${NC}"
    echo -e "  ./supabase_restore.sh $BACKUP_FILE"
else
    echo -e "\n${RED}✗ Backup failed!${NC}"
    # Clean up the empty file
    rm -f "$BACKUP_FILE"
    exit 1
fi
