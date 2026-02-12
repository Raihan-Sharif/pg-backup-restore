#!/bin/bash

# Neon PostgreSQL Backup Script
# Usage:
#   Interactive: ./neon_backup.sh
#   Direct:      ./neon_backup.sh "postgresql://user:pass@host/dbname"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Neon PostgreSQL Backup ===${NC}\n"

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
    echo -e "${YELLOW}Enter SOURCE Neon connection string (paste as single line):${NC}"
    echo "(Format: postgresql://user:password@host/dbname)"
    echo ""
    echo -e "${YELLOW}Tip: If pasting causes issues, use:${NC}"
    echo "  ./neon_backup.sh \"postgresql://user:pass@host/dbname\""
    echo ""
    read -r SOURCE_DB
fi

if [ -z "$SOURCE_DB" ]; then
    echo -e "${RED}Error: Source connection string cannot be empty${NC}"
    exit 1
fi

# Validate connection string format
if [[ ! "$SOURCE_DB" =~ ^postgresql:// ]]; then
    echo -e "${RED}Error: Invalid connection string format${NC}"
    echo "Must start with: postgresql://"
    exit 1
fi

# Extract database name from connection string
# Format: postgresql://user:password@host/dbname or postgresql://user:password@host/dbname?params
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
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_${TIMESTAMP}.dump"

echo -e "\n${GREEN}Starting backup...${NC}"
echo "Output file: $BACKUP_FILE"

# Perform backup
$PG_DUMP -Fc -v --no-owner --no-acl -d "$SOURCE_DB" -f "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    FILE_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo -e "\n${GREEN}✓ Backup completed successfully!${NC}"
    echo -e "File: $BACKUP_FILE ($FILE_SIZE)"
    echo -e "\n${YELLOW}To restore, run:${NC}"
    echo -e "  pg_restore -v --no-owner --no-acl -d \"your-target-connection-string\" $BACKUP_FILE"
else
    echo -e "\n${RED}✗ Backup failed!${NC}"
    exit 1
fi
