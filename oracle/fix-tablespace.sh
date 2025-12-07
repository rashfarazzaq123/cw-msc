#!/bin/bash
# Fix tablespace size issue

echo "=========================================="
echo "Fixing USERS Tablespace Size"
echo "=========================================="
echo ""

echo "Running as SYS user to fix tablespace..."
docker exec oracle-xe-21c bash -c "sqlplus -s sys/OraclePassword123@XEPDB1 as sysdba <<EOF
SET HEADING ON
SET PAGESIZE 100
SET LINESIZE 200

-- Check current tablespace
SELECT tablespace_name, file_name, bytes/1024/1024 as size_mb,
       maxbytes/1024/1024 as max_size_mb, autoextensible
FROM dba_data_files
WHERE tablespace_name = 'USERS';

-- Enable autoextend
ALTER DATABASE DATAFILE '/opt/oracle/oradata/XE/XEPDB1/users01.dbf'
AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED;

-- Verify
SELECT tablespace_name, file_name, bytes/1024/1024 as size_mb,
       maxbytes/1024/1024 as max_size_mb, autoextensible
FROM dba_data_files
WHERE tablespace_name = 'USERS';

EXIT;
EOF"

echo ""
echo "=========================================="
echo "Tablespace fixed! You can now retry your INSERT statements."
echo "=========================================="
