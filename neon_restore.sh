#!/bin/bash

# Neon PostgreSQL Restore Script
# Usage:
#   Interactive: ./neon_restore.sh
#   Direct:      ./neon_restore.sh <backup_file> "postgresql://user:pass@host/dbname" [--clean] [--parallel]

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Neon PostgreSQL Restore ===${NC}\n"

# Use PostgreSQL 17 explicitly
PG_RESTORE="/opt/homebrew/opt/postgresql@17/bin/pg_restore"

# Check if pg_restore is installed
if [ ! -f "$PG_RESTORE" ]; then
    echo -e "${RED}Error: pg_restore version 17 not found at $PG_RESTORE${NC}"
    echo "Install PostgreSQL 17 client tools:"
    echo "  brew install postgresql@17"
    exit 1
fi

# Display version
PG_VERSION=$($PG_RESTORE --version)
echo -e "${GREEN}Using: $PG_VERSION${NC}\n"

# Check if arguments provided (non-interactive mode)
if [ -n "$1" ] && [ -n "$2" ]; then
    BACKUP_FILE="$1"
    TARGET_DB="$2"
    echo -e "${GREEN}Using arguments from command line${NC}\n"

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

    # Skip interactive prompts
    CLEAN_OPTION=$([ -n "$CLEAN_FLAGS" ] && echo "yes" || echo "no")
    PARALLEL_OPTION=$([ -n "$PARALLEL_FLAGS" ] && echo "yes" || echo "no")
    CONFIRM="yes"
else
    # Interactive mode
    # List available backup files
    echo -e "${YELLOW}Available backup files:${NC}"
    ls -lh db_backups/*.dump 2>/dev/null || ls -lh *.dump 2>/dev/null || echo "  (none found)"
    echo ""

    # Prompt for backup file
    echo -e "${YELLOW}Enter backup filename to restore:${NC}"
    read -r BACKUP_FILE

    if [ ! -f "$BACKUP_FILE" ]; then
        echo -e "${RED}Error: File '$BACKUP_FILE' not found${NC}"
        exit 1
    fi

    # Prompt for target connection string
    echo -e "\n${YELLOW}Enter TARGET Neon connection string (paste as single line):${NC}"
    echo "(Format: postgresql://user:password@host/dbname)"
    echo ""
    echo -e "${YELLOW}Tip: If pasting causes issues, use:${NC}"
    echo "  ./neon_restore.sh <backup_file> \"postgresql://user:pass@host/dbname\""
    echo ""
    read -r TARGET_DB

    if [ -z "$TARGET_DB" ]; then
        echo -e "${RED}Error: Target connection string cannot be empty${NC}"
        exit 1
    fi

    # Ask about cleaning existing database
    echo -e "\n${YELLOW}Do you want to CLEAN (drop) existing objects before restore?${NC}"
    echo -e "${RED}WARNING: This will DELETE existing tables/data in the target database!${NC}"
    echo -e "Options:"
    echo -e "  ${GREEN}yes${NC} - Clean existing objects (recommended for fresh restore)"
    echo -e "  ${YELLOW}no${NC}  - Keep existing objects (may cause conflicts)"
    read -r CLEAN_OPTION

    CLEAN_FLAGS=""
    if [ "$CLEAN_OPTION" = "yes" ]; then
        CLEAN_FLAGS="--clean --if-exists"
        echo -e "${YELLOW}Will use --clean --if-exists flags${NC}"
    fi

    # Ask about parallel restore
    echo -e "\n${YELLOW}Enable parallel restore for faster performance? (yes/no):${NC}"
    echo -e "  ${GREEN}yes${NC} - Use 4 parallel jobs (faster for large databases)"
    echo -e "  ${YELLOW}no${NC}  - Single-threaded restore"
    read -r PARALLEL_OPTION

    PARALLEL_FLAGS=""
    if [ "$PARALLEL_OPTION" = "yes" ]; then
        PARALLEL_FLAGS="-j 4"
        echo -e "${YELLOW}Will use 4 parallel jobs${NC}"
    fi

    # Confirmation
    echo -e "\n${RED}WARNING: This will restore data to the target database.${NC}"
    echo -e "Target: $TARGET_DB"
    echo -e "From file: $BACKUP_FILE"
    echo -e "Clean existing: ${CLEAN_OPTION}"
    echo -e "Parallel restore: ${PARALLEL_OPTION}"
    echo -e "\n${YELLOW}Continue? (yes/no):${NC}"
    read -r CONFIRM

    if [ "$CONFIRM" != "yes" ]; then
        echo -e "${YELLOW}Restore cancelled.${NC}"
        exit 0
    fi
fi

# Validate backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo -e "${RED}Error: Backup file '$BACKUP_FILE' not found${NC}"
    exit 1
fi

echo -e "\n${GREEN}Starting restore...${NC}"
echo -e "Command: pg_restore -v --no-owner --no-acl $CLEAN_FLAGS $PARALLEL_FLAGS"
echo ""

# Display restore info
echo -e "Backup file: ${YELLOW}$BACKUP_FILE${NC}"
echo -e "Target DB:   ${YELLOW}$TARGET_DB${NC}"
echo -e "Clean mode:  ${YELLOW}$CLEAN_OPTION${NC}"
echo -e "Parallel:    ${YELLOW}$PARALLEL_OPTION${NC}"
echo ""

# Perform restore
$PG_RESTORE -v --no-owner --no-acl $CLEAN_FLAGS $PARALLEL_FLAGS -d "$TARGET_DB" "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}✓ Restore completed successfully!${NC}"
else
    echo -e "\n${RED}✗ Restore failed!${NC}"
    echo -e "${YELLOW}Tip: Make sure the target database exists and is empty, or use --clean flag${NC}"
    exit 1
fi
