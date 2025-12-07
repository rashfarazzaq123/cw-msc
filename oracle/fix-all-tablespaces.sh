#!/bin/bash
# Fix all tablespace issues - expand USERS and grant quota

echo "=========================================="
echo "Fixing All Tablespace Issues"
echo "=========================================="
echo ""

echo "Running as SYS user to fix tablespaces..."
docker exec oracle-xe-21c bash -c "sqlplus -s sys/OraclePassword123@XEPDB1 as sysdba <<EOF
SET HEADING ON
SET PAGESIZE 100
SET LINESIZE 200

-- Check current tablespace status
PROMPT ===== Current Tablespace Status =====
SELECT tablespace_name, file_name,
       bytes/1024/1024 as size_mb,
       maxbytes/1024/1024 as max_size_mb,
       autoextensible
FROM dba_data_files
WHERE tablespace_name IN ('USERS', 'SYSAUX')
ORDER BY tablespace_name;

-- Enable autoextend on USERS tablespace
PROMPT ===== Enabling Autoextend on USERS =====
ALTER DATABASE DATAFILE '/opt/oracle/oradata/XE/XEPDB1/users01.dbf'
AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED;

-- Enable autoextend on SYSAUX tablespace
PROMPT ===== Enabling Autoextend on SYSAUX =====
ALTER DATABASE DATAFILE '/opt/oracle/oradata/XE/XEPDB1/sysaux01.dbf'
AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED;

-- Grant unlimited quota to coursework user on both tablespaces
PROMPT ===== Granting Quota to Coursework User =====
ALTER USER coursework QUOTA UNLIMITED ON USERS;
ALTER USER coursework QUOTA UNLIMITED ON SYSAUX;

-- Verify changes
PROMPT ===== Tablespace Status After Changes =====
SELECT tablespace_name, file_name,
       bytes/1024/1024 as size_mb,
       maxbytes/1024/1024 as max_size_mb,
       autoextensible
FROM dba_data_files
WHERE tablespace_name IN ('USERS', 'SYSAUX')
ORDER BY tablespace_name;

PROMPT ===== User Quotas =====
SELECT username, tablespace_name,
       CASE
         WHEN max_bytes = -1 THEN 'UNLIMITED'
         ELSE TO_CHAR(max_bytes/1024/1024) || ' MB'
       END as quota
FROM dba_ts_quotas
WHERE username = 'COURSEWORK'
ORDER BY tablespace_name;

EXIT;
EOF"

echo ""
echo "=========================================="
echo "All tablespace issues fixed!"
echo "You can now retry your table creation and inserts."
echo "=========================================="
