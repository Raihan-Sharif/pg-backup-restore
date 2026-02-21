#!/bin/bash

# Supabase PostgreSQL Restore Script
# Usage:
#   Interactive: ./supabase_restore.sh
#   Direct:      ./supabase_restore.sh <backup_file> "postgresql://postgres.[your-password]@aws-0-eu-central-1.pooler.supabase.com:5432/postgres" [--clean] [--parallel]

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Supabase PostgreSQL Restore ===${NC}\n"

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
    
    if [ -z "$BACKUP_FILE" ]; then
        echo -e "${RED}Error: Backup file cannot be empty${NC}"
        exit 1
    fi

    if [ ! -f "$BACKUP_FILE" ]; then
        echo -e "${RED}Error: File '$BACKUP_FILE' not found${NC}"
        exit 1
    fi

    # Prompt for target connection string
    echo -e "\n${YELLOW}Enter TARGET Supabase connection string (paste as single line):${NC}"
    echo -e "${YELLOW}Note: Use the Session mode connection string (port 5432) for pg_restore${NC}"
    echo "(Format: postgresql://postgres.[your-password]@aws-0-eu-central-1.pooler.supabase.com:5432/postgres)"
    echo ""
    read -r TARGET_DB

    if [ -z "$TARGET_DB" ]; then
        echo -e "${RED}Error: Target connection string cannot be empty${NC}"
        exit 1
    fi
    
    # Validate connection string format
    if [[ ! "$TARGET_DB" =~ ^postgresql:// ]] && [[ ! "$TARGET_DB" =~ ^postgres:// ]]; then
        echo -e "${RED}Error: Invalid connection string format${NC}"
        echo "Must start with: postgresql:// or postgres://"
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
    echo -e "Target: $(echo "$TARGET_DB" | sed -E 's|:([^:@]+)@|:***@|') " # Hide password in output
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
echo -e "Target DB:   ${YELLOW}$(echo "$TARGET_DB" | sed -E 's|:([^:@]+)@|:***@|')${NC}"
echo -e "Clean mode:  ${YELLOW}$CLEAN_OPTION${NC}"
echo -e "Parallel:    ${YELLOW}$PARALLEL_OPTION${NC}"
echo ""

# Perform restore
$PG_RESTORE -v --no-owner --no-acl $CLEAN_FLAGS $PARALLEL_FLAGS -d "$TARGET_DB" "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}✓ Restore completed successfully!${NC}"
else
    echo -e "\n${RED}✗ Restore failed!${NC}"
    echo -e "${YELLOW}Tip: Make sure the target database exists, or use --clean flag${NC}"
    exit 1
fi
