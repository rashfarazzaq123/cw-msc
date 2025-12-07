#!/bin/bash
# Grant tablespace quota to coursework user

echo "=========================================="
echo "Granting Tablespace Quota to Coursework User"
echo "=========================================="
echo ""

echo "Running as SYS user to grant quota..."
docker exec oracle-xe-21c bash -c "sqlplus -s sys/OraclePassword123@XEPDB1 as sysdba <<EOF
SET HEADING ON
SET PAGESIZE 100
SET LINESIZE 200

-- Grant unlimited quota on USERS tablespace
ALTER USER coursework QUOTA UNLIMITED ON USERS;

-- Grant unlimited quota on SYSAUX tablespace
ALTER USER coursework QUOTA UNLIMITED ON SYSAUX;

-- Verify quota
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
echo "Quota granted! You can now retry your table creation."
echo "=========================================="
