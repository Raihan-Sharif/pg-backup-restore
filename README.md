# PostgreSQL Backup & Restore Scripts

<div align="center">

[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14%2B-316192?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Shell Script](https://img.shields.io/badge/Shell_Script-121011?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/macOS%20%7C%20Linux-999999?style=for-the-badge&logo=apple&logoColor=white)](README.md)

**Simple, powerful backup and restore scripts for any PostgreSQL database**

Neon • Supabase • Self-hosted • AWS RDS • DigitalOcean • Railway

[Features](#-features) • [Quick Start](#quick-reference) • [Examples](#platform-specific-examples) • [Documentation](#prerequisites)

</div>

---

**Perfect for:** Database migrations, backups, cloning production to staging, disaster recovery, and cross-platform transfers.

---

## 📋 Table of Contents

- [Features](#-features)
- [Compatibility](#compatibility)
- [Quick Reference](#quick-reference)
- [Platform Examples](#platform-specific-examples)
- [Prerequisites](#prerequisites)
- [Usage](#quick-start)
- [Managing Backups](#managing-multiple-backups)
- [Troubleshooting](#common-issues--solutions)
- [Automation](#automation-example-cron-job)
- [Resources](#-resources)
- [Author](#-author)

## ✨ Features

<table>
<tr>
<td width="50%">

### 🌍 Universal Compatibility
- ✅ Neon, Supabase, AWS RDS
- ✅ Self-hosted VPS (Coolify, Docker)
- ✅ Railway, DigitalOcean, Render
- ✅ Any PostgreSQL database

### ⚡ Performance
- 🚀 Parallel restore (4 jobs)
- 📦 Compressed backups
- 🧹 Clean mode for fresh restores
- ⏱️ Fast, efficient operations

</td>
<td width="50%">

### 🎯 User-Friendly
- 💻 Command-line arguments
- 🎛️ Interactive mode
- 📝 Smart backup naming
- 📁 Organized folder structure

### 🔧 Flexible
- 🔄 PostgreSQL 14-17 support
- 🌐 Cross-platform migrations
- 🤖 Automation ready
- 🛡️ Safe with validation

</td>
</tr>
</table>

## 🌐 Compatibility

<div align="center">

| Platform | Status | Connection Example |
|:--------:|:------:|:-------------------|
| <img src="https://neon.tech/favicon.ico" width="16"/> **Neon** | ✅ Tested | `postgresql://user:pass@ep-xxx.neon.tech/db` |
| <img src="https://supabase.com/favicon.ico" width="16"/> **Supabase** | ✅ Tested | `postgresql://postgres.xxx:pass@pooler.supabase.com:5432/postgres` |
| 🖥️ **Self-hosted VPS** | ✅ Tested | `postgresql://user:pass@192.168.1.10:5432/db` |
| <img src="https://aws.amazon.com/favicon.ico" width="16"/> **AWS RDS** | ✅ Compatible | `postgresql://user:pass@xxx.rds.amazonaws.com:5432/db` |
| 🚂 **Railway** | ✅ Compatible | `postgresql://user:pass@containers.railway.app:5432/db` |
| 🌊 **DigitalOcean** | ✅ Compatible | `postgresql://user:pass@db-xxx.db.ondigitalocean.com:25060/db` |
| 💻 **Local** | ✅ Compatible | `postgresql://postgres:pass@localhost:5432/db` |

</div>

## 🚀 Quick Reference

```bash
# 1️⃣ Install PostgreSQL 17 (one-time setup)
brew install postgresql@17

# 2️⃣ Backup your database (works with ANY PostgreSQL database)
./neon_backup.sh "postgresql://user:pass@source-host/dbname?sslmode=require"

# 3️⃣ List available backups
ls -lh db_backups/

# 4️⃣ Restore a specific backup
./quick_restore.sh db_backups/Shopelize_db_20260212_131534.dump \
  "postgresql://user:pass@target-host/dbname" --clean --parallel
```

> **💡 Pro Tip:** You must specify which `.dump` file to restore. The scripts don't automatically pick the latest backup - giving you full control over your restore points.

<details>
<summary>📸 <b>Example Output</b></summary>

```
=== Neon PostgreSQL Backup ===

Using: pg_dump (PostgreSQL) 17.7 (Homebrew)

Database: Shopelize_db

Starting backup...
Output file: db_backups/Shopelize_db_20260212_131534.dump

✓ Backup completed successfully!
File: db_backups/Shopelize_db_20260212_131534.dump (363K)
```

</details>

## 💼 Platform-Specific Examples

<details open>
<summary>🟦 <b>Neon</b></summary>

```bash
# Backup from Neon
./neon_backup.sh "postgresql://neondb_owner:pass@ep-xxx.neon.tech/dbname?sslmode=require"

# Restore to Neon
./quick_restore.sh db_backups/dbname_20260212_131534.dump \
  "postgresql://neondb_owner:pass@ep-xxx.neon.tech/dbname?sslmode=require" \
  --clean --parallel
```

</details>

<details>
<summary>🟩 <b>Supabase</b></summary>

> 📍 Get connection string from: **Project Settings → Database → Connection string → URI**

```bash
# Backup from Supabase
./neon_backup.sh "postgresql://postgres.projectref:pass@aws-0-region.pooler.supabase.com:5432/postgres"

# Restore to Supabase
./quick_restore.sh db_backups/postgres_20260212_131534.dump \
  "postgresql://postgres.projectref:pass@aws-0-region.pooler.supabase.com:5432/postgres" \
  --clean --parallel
```

</details>

<details>
<summary>🖥️ <b>Self-Hosted PostgreSQL (VPS, Coolify, Docker)</b></summary>

```bash
# Backup from your VPS
./neon_backup.sh "postgresql://postgres:yourpassword@your-vps-ip:5432/mydb"

# Or if using Docker on VPS with domain
./neon_backup.sh "postgresql://postgres:yourpassword@vps.yourdomain.com:5432/mydb"

# Restore to your VPS
./quick_restore.sh db_backups/mydb_20260212_131534.dump \
  "postgresql://postgres:yourpassword@your-vps-ip:5432/mydb" \
  --clean --parallel
```

</details>

<details>
<summary>🔄 <b>Cross-Platform Migration</b></summary>

Migrate data between different PostgreSQL providers:

```bash
# 1️⃣ Backup from Supabase
./neon_backup.sh "postgresql://supabase-connection-string"

# 2️⃣ Restore to Neon
./quick_restore.sh db_backups/postgres_20260212_131534.dump \
  "postgresql://neon-connection-string" --clean --parallel

# Or restore to your own VPS
./quick_restore.sh db_backups/postgres_20260212_131534.dump \
  "postgresql://vps-connection-string" --clean --parallel
```

**Use Cases:**
- 🔄 Clone production → staging
- 🏗️ Migrate between cloud providers
- 💾 Local development with production data
- 🧪 Testing with real data safely

</details>

## PostgreSQL Version Compatibility

**Important:** Your `pg_dump`/`pg_restore` version should match or be compatible with your database server version.

### Common Versions by Platform
- **Neon:** PostgreSQL 17.7
- **Supabase:** PostgreSQL 15.x (check your project settings)
- **Self-hosted:** Varies (run `psql -c "SELECT version();"` to check)

**Version mismatch errors look like this:**
```
pg_dump: error: server version: 17.7; pg_dump version: 14.20
pg_dump: error: aborting because of server version mismatch
```

### Check Your Database Version
```bash
# Check your database version
psql "postgresql://your-connection-string" -c "SELECT version();"
```

## Prerequisites

### Install PostgreSQL Client Tools

The scripts default to PostgreSQL 17 (for Neon compatibility). For other platforms, install the matching version:

**For Neon (PostgreSQL 17):**
```bash
brew install postgresql@17
```

**For Supabase (PostgreSQL 15):**
```bash
brew install postgresql@15
```

**For other versions:**
```bash
brew install postgresql@16  # PostgreSQL 16
brew install postgresql@14  # PostgreSQL 14
```

### Verify Installation

```bash
# Check installed version
/opt/homebrew/opt/postgresql@17/bin/pg_dump --version
```

### Adapt Scripts for Different Versions

If your database is **not** PostgreSQL 17, update the scripts:

**Edit these lines in all 3 scripts:**
```bash
# For PostgreSQL 15 (Supabase)
PG_DUMP="/opt/homebrew/opt/postgresql@15/bin/pg_dump"
PG_RESTORE="/opt/homebrew/opt/postgresql@15/bin/pg_restore"

# For PostgreSQL 16
PG_DUMP="/opt/homebrew/opt/postgresql@16/bin/pg_dump"
PG_RESTORE="/opt/homebrew/opt/postgresql@16/bin/pg_restore"
```

Or update your PATH to use the correct version:
```bash
# Add to ~/.zshrc
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
source ~/.zshrc
```

## Quick Start

### 1. Backup Your Database

**Method 1: Command-line argument (Recommended)**
```bash
./neon_backup.sh "postgresql://username:password@ep-xyz-123.region.aws.neon.tech/dbname?sslmode=require"
```

**Method 2: Interactive mode**
```bash
./neon_backup.sh
```
Then paste your connection string when prompted.

**Where to get your connection string:**
- Neon Dashboard → Your Project → Connection Details

**Output:**
- Backups are saved in the `db_backups/` folder
- File naming format: `{database_name}_{timestamp}.dump`
- Example: `db_backups/Shopelize_db_20260212_130615.dump`

### 2. Restore to Another Project

**First, list your available backups:**
```bash
# See all backup files with details
ls -lh db_backups/

# Output example:
# Shopelize_db_20260212_130615.dump    363K
# Shopelize_db_20260212_141030.dump    365K
# Shopelize_db_20260213_020000.dump    370K  <- Most recent
```

**Then choose a restore method:**

**Method 1: Quick restore with command-line arguments (Recommended)**
```bash
# Specify the exact backup file you want to restore
# Basic restore
./quick_restore.sh db_backups/Shopelize_db_20260213_020000.dump "postgresql://user:pass@target-host/dbname"

# With clean (drops existing tables first)
./quick_restore.sh db_backups/Shopelize_db_20260213_020000.dump "postgresql://user:pass@target-host/dbname" --clean

# With clean + parallel (recommended for large databases)
./quick_restore.sh db_backups/Shopelize_db_20260213_020000.dump "postgresql://user:pass@target-host/dbname" --clean --parallel
```

**Method 2: Interactive restore (easiest - shows you the files)**
```bash
./neon_restore.sh
```
The script will:
1. **List all available backup files** with sizes
2. Ask you to **enter the filename** you want to restore
3. Ask for target Neon connection string
4. Ask about clean mode and parallel restore

**Method 3: Non-interactive restore with neon_restore.sh**
```bash
# Specify the backup file as first argument
./neon_restore.sh db_backups/Shopelize_db_20260213_020000.dump "postgresql://user:pass@target-host/dbname" --clean --parallel
```

**💡 Tips for choosing a backup file:**
- Filename format: `{database_name}_{YYYYMMDD}_{HHMMSS}.dump`
- Most recent backup has the **latest date and time**
- Use `ls -lt db_backups/` to list by modification time (newest first)
- Check file size to ensure backup isn't corrupted (should not be 0 bytes)

## Manual Commands

If you prefer to use the PostgreSQL tools directly instead of our scripts:

### Backup (Custom Format - Recommended)

```bash
/opt/homebrew/opt/postgresql@17/bin/pg_dump -Fc -v --no-owner --no-acl \
  -d "postgresql://user:pass@source-host/dbname" \
  -f db_backups/backup.dump
```

### Backup (SQL Format - Human Readable)

```bash
/opt/homebrew/opt/postgresql@17/bin/pg_dump -v --no-owner --no-acl \
  -d "postgresql://user:pass@source-host/dbname" \
  -f db_backups/backup.sql
```

### Restore (Custom Format)

**Basic restore:**
```bash
/opt/homebrew/opt/postgresql@17/bin/pg_restore -v --no-owner --no-acl \
  -d "postgresql://user:pass@target-host/dbname" \
  db_backups/backup.dump
```

**With clean (drops existing objects first):**
```bash
/opt/homebrew/opt/postgresql@17/bin/pg_restore -v --no-owner --no-acl --clean --if-exists \
  -d "postgresql://user:pass@target-host/dbname" \
  db_backups/backup.dump
```

**With parallel restore (faster for large DBs):**
```bash
/opt/homebrew/opt/postgresql@17/bin/pg_restore -v --no-owner --no-acl --clean --if-exists -j 4 \
  -d "postgresql://user:pass@target-host/dbname" \
  db_backups/backup.dump
```

### Restore (SQL Format)

```bash
/opt/homebrew/opt/postgresql@17/bin/psql -d "postgresql://user:pass@target-host/dbname" \
  -f db_backups/backup.sql
```

## Important Flags

| Flag | Purpose |
|------|---------|
| `-Fc` | Custom compressed format (recommended for large DBs) |
| `-v` | Verbose output |
| `--no-owner` | Don't restore ownership (required for Neon) |
| `--no-acl` | Don't restore permissions (required for Neon) |
| `--clean` | Drop existing objects before restore |
| `--if-exists` | Use with --clean to avoid errors |
| `-j N` | Parallel restore with N jobs (faster for large DBs) |

## Common Issues & Solutions

### Issue: "server version mismatch"
**Error:** `pg_dump: error: server version: 17.7; pg_dump version: 14.20`

**Solution:** Install PostgreSQL 17 to match Neon's server version:
```bash
brew install postgresql@17
```
The script automatically uses the correct version from `/opt/homebrew/opt/postgresql@17/bin/pg_dump`

### Issue: "Could not extract database name" or connection string wrapping
**Error:** Connection string gets split across multiple lines in terminal

**Solution:** Use command-line argument instead of interactive mode:
```bash
./neon_backup.sh "postgresql://user:pass@host/dbname?sslmode=require"
```
The quotes ensure the entire string is treated as one argument.

### Issue: "role does not exist"
**Solution:** Use `--no-owner --no-acl` flags (already in scripts)

### Issue: "database is not empty"
**Solution:** Either:
- Drop and recreate the target database in Neon dashboard
- Use `--clean --if-exists` flags:
  ```bash
  ./quick_restore.sh db_backups/backup.dump "connection-string" --clean
  ```

### Issue: Slow restore on large databases
**Solution:** Use parallel restore:
```bash
./quick_restore.sh db_backups/backup.dump "connection-string" --parallel
```

### Issue: Connection timeout
**Solution:** Ensure `?sslmode=require` is in connection string

## Backup Only Specific Objects

### Backup only schema (no data):
```bash
pg_dump -Fc -v --no-owner --no-acl --schema-only \
  -d "connection-string" -f schema_only.dump
```

### Backup only data (no schema):
```bash
pg_dump -Fc -v --no-owner --no-acl --data-only \
  -d "connection-string" -f data_only.dump
```

### Backup specific tables:
```bash
pg_dump -Fc -v --no-owner --no-acl \
  -t table1 -t table2 \
  -d "connection-string" -f tables.dump
```

### Exclude specific tables:
```bash
pg_dump -Fc -v --no-owner --no-acl \
  -T logs -T temp_data \
  -d "connection-string" -f backup.dump
```

## Why SQL Queries Don't Work for Backups

SQL `COPY` or `SELECT INTO` commands:
- ❌ Don't capture schema (tables, indexes, constraints)
- ❌ Don't preserve foreign keys and relationships
- ❌ Don't backup functions, triggers, sequences
- ❌ Don't handle dependencies correctly

`pg_dump`:
- ✅ Complete logical backup
- ✅ Preserves all database objects
- ✅ Handles dependencies automatically
- ✅ Cross-version compatible
- ✅ Compression support

## Script Features

### neon_backup.sh
- ✅ Uses PostgreSQL 17 automatically
- ✅ Extracts database name from connection string
- ✅ Creates organized `db_backups/` folder
- ✅ Names backups: `{dbname}_{timestamp}.dump`
- ✅ Supports command-line arguments (avoids paste issues)
- ✅ Supports interactive mode

### neon_restore.sh
- ✅ Uses PostgreSQL 17 automatically
- ✅ Interactive prompts for all options
- ✅ Optional clean mode (drops existing objects)
- ✅ Optional parallel restore (4 jobs)
- ✅ Supports command-line arguments for automation
- ✅ Lists available backup files

### quick_restore.sh
- ✅ Uses PostgreSQL 17 automatically
- ✅ Non-interactive (perfect for scripts/automation)
- ✅ Command-line flags: `--clean`, `--parallel`
- ✅ Fast and straightforward

## Managing Multiple Backups

### List all backups with details
```bash
ls -lh db_backups/
```

### List backups sorted by date (newest first)
```bash
ls -lt db_backups/
```

### Find the most recent backup for a specific database
```bash
ls -lt db_backups/Shopelize_db_*.dump | head -1
```

### Find backups from a specific date
```bash
ls db_backups/*20260212*.dump
```

### Check backup file integrity
```bash
# Should show database information, not error
file db_backups/Shopelize_db_20260212_130615.dump

# Output should show: "PostgreSQL custom database dump"
```

### Clean up old backups (keep last 7 days)
```bash
# List backups older than 7 days (review before deleting)
find db_backups/ -name "*.dump" -mtime +7

# Delete backups older than 7 days
find db_backups/ -name "*.dump" -mtime +7 -delete
```

## Folder Structure

```
backup/
├── neon_backup.sh           # Backup script
├── neon_restore.sh          # Interactive restore script
├── quick_restore.sh         # Quick restore script
├── README.md               # This file
└── db_backups/             # Backup files directory (auto-created)
    ├── Shopelize_db_20260212_130615.dump  (363K)
    ├── Shopelize_db_20260212_141030.dump  (365K)
    ├── Shopelize_db_20260213_020000.dump  (370K) <- Most recent
    └── OtherDB_20260212_152045.dump       (245K)
```

## Best Practices

1. **Use custom format** (`-Fc`) - smaller, faster, more flexible
2. **Always use** `--no-owner --no-acl` for managed services like Neon
3. **Database name extracted automatically** from connection string
4. **Backups organized** in `db_backups/` folder with meaningful names
5. **Test restores** regularly to verify backups work
6. **Store backups** in multiple locations (local + cloud)
7. **Automate backups** with cron or scheduled tasks

## Automation Example (Cron Job)

### Setup Automated Daily Backups

1. **Create a secure environment file** to store your connection string:
```bash
# Create a file at ~/.neon_backup_config
cat > ~/.neon_backup_config << 'EOF'
NEON_CONNECTION_STRING="postgresql://user:pass@host/dbname?sslmode=require"
EOF

# Secure the file (only you can read it)
chmod 600 ~/.neon_backup_config
```

2. **Create a wrapper script** for cron:
```bash
cat > ~/backup_wrapper.sh << 'EOF'
#!/bin/bash
source ~/.neon_backup_config
cd /Users/raihan/Projects/postgres/backup
./neon_backup.sh "$NEON_CONNECTION_STRING" >> /tmp/neon_backup.log 2>&1
EOF

chmod +x ~/backup_wrapper.sh
```

3. **Add to crontab** for daily backups at 2 AM:
```bash
crontab -e
```

Add this line:
```
0 2 * * * /Users/raihan/backup_wrapper.sh
```

### Test Your Automated Setup

```bash
# Run the wrapper script manually
~/backup_wrapper.sh

# Check the log
cat /tmp/neon_backup.log

# Verify the backup was created
ls -lh /Users/raihan/Projects/postgres/backup/db_backups/
```

## 📚 Resources

- [PostgreSQL pg_dump Documentation](https://www.postgresql.org/docs/current/app-pgdump.html)
- [PostgreSQL pg_restore Documentation](https://www.postgresql.org/docs/current/app-pgrestore.html)
- [Neon Documentation](https://neon.tech/docs)
- [Supabase Documentation](https://supabase.com/docs)

---

<div align="center">

## 👨‍💻 Author

<table>
<tr>
<td align="center">
<img src="https://github.com/Raihan-Sharif.png" width="120px;" style="border-radius: 50%;" alt="Raihan Sharif"/>
<br />
<b>Raihan Sharif</b>
<br />
<br />
<a href="https://github.com/Raihan-Sharif">
<img src="https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white" alt="GitHub"/>
</a>
<a href="https://www.linkedin.com/in/mdraihansharif/">
<img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white" alt="LinkedIn"/>
</a>
</td>
</tr>
</table>

### 🤝 Contributing

Contributions, issues, and feature requests are welcome!

Feel free to check the [issues page](https://github.com/Raihan-Sharif/pg-backup-restore/issues) or submit a pull request.

### ⭐ Show your support

Give a ⭐️ if this project helped you!

### 📝 License

Copyright © 2026 [Raihan Sharif](https://github.com/Raihan-Sharif)

This project is [MIT](LICENSE) licensed.

---

<sub>Built with ❤️ for the PostgreSQL community</sub>

</div>
