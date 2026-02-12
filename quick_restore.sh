#!/bin/bash

# Quick Neon PostgreSQL Restore (Non-interactive)
# Usage: ./quick_restore.sh <backup_file> <target_connection_string> [--clean] [--parallel]
#
# Examples:
#   ./quick_restore.sh db_backups/Shopelize_db_20260212_131534.dump "postgresql://user:pass@host/db"
#   ./quick_restore.sh db_backups/Shopelize_db_20260212_131534.dump "postgresql://user:pass@host/db" --clean
#   ./quick_restore.sh db_backups/Shopelize_db_20260212_131534.dump "postgresql://user:pass@host/db" --clean --parallel

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check arguments
if [ $# -lt 2 ]; then
    echo -e "${RED}Error: Missing required arguments${NC}"
    echo ""
    echo "Usage: $0 <backup_file> <target_connection_string> [--clean] [--parallel]"
    echo ""
    echo "Examples:"
    echo "  $0 db_backups/Shopelize_db_20260212_131534.dump \"postgresql://user:pass@host/db\""
    echo "  $0 db_backups/Shopelize_db_20260212_131534.dump \"postgresql://user:pass@host/db\" --clean"
    echo "  $0 db_backups/Shopelize_db_20260212_131534.dump \"postgresql://user:pass@host/db\" --clean --parallel"
    echo ""
    echo "Flags:"
    echo "  --clean     Drop existing objects before restore"
    echo "  --parallel  Use 4 parallel jobs for faster restore"
    exit 1
fi

BACKUP_FILE="$1"
TARGET_DB="$2"

# Use PostgreSQL 17 explicitly
PG_RESTORE="/opt/homebrew/opt/postgresql@17/bin/pg_restore"

# Check if pg_restore is installed
if [ ! -f "$PG_RESTORE" ]; then
    echo -e "${RED}Error: pg_restore version 17 not found at $PG_RESTORE${NC}"
    echo "Install PostgreSQL 17 client tools:"
    echo "  brew install postgresql@17"
    exit 1
fi

# Check if backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo -e "${RED}Error: Backup file '$BACKUP_FILE' not found${NC}"
    exit 1
fi

# Parse optional flags
CLEAN_FLAGS=""
PARALLEL_FLAGS=""

for arg in "$@"; do
    case $arg in
        --clean)
            CLEAN_FLAGS="--clean --if-exists"
            ;;
        --parallel)
            PARALLEL_FLAGS="-j 4"
            ;;
    esac
done

# Display version
echo -e "${GREEN}=== Quick Neon PostgreSQL Restore ===${NC}\n"
PG_VERSION=$($PG_RESTORE --version)
echo -e "${GREEN}Using: $PG_VERSION${NC}\n"

# Display restore info
echo -e "Backup file: ${YELLOW}$BACKUP_FILE${NC}"
echo -e "Target DB:   ${YELLOW}$TARGET_DB${NC}"
echo -e "Clean mode:  ${YELLOW}$([ -n "$CLEAN_FLAGS" ] && echo "YES" || echo "NO")${NC}"
echo -e "Parallel:    ${YELLOW}$([ -n "$PARALLEL_FLAGS" ] && echo "YES (4 jobs)" || echo "NO")${NC}"
echo ""

# Perform restore
echo -e "${GREEN}Starting restore...${NC}"
echo -e "Command: pg_restore -v --no-owner --no-acl $CLEAN_FLAGS $PARALLEL_FLAGS"
echo ""

$PG_RESTORE -v --no-owner --no-acl $CLEAN_FLAGS $PARALLEL_FLAGS -d "$TARGET_DB" "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}✓ Restore completed successfully!${NC}"
else
    echo -e "\n${RED}✗ Restore failed!${NC}"
    exit 1
fi
