#!/bin/bash
# Test Oracle Database Connection

echo "=========================================="
echo "Testing Oracle Database Connection"
echo "=========================================="
echo ""

# Test 1: Connect as SYS user
echo "Test 1: Connecting as SYS user..."
docker exec oracle-xe-21c sqlplus -s sys/OraclePassword123@XE as sysdba <<EOF
SELECT 'Connection successful!' as STATUS FROM dual;
SELECT instance_name, status, database_status FROM v\$instance;
EXIT;
EOF

echo ""
echo "=========================================="

# Test 2: Connect as coursework user
echo "Test 2: Connecting as coursework user..."
docker exec oracle-xe-21c sqlplus -s coursework/CourseworkPass123@XEPDB1 <<EOF
SELECT 'Coursework user connected!' as STATUS FROM dual;
SELECT USER, SYS_CONTEXT('USERENV', 'CON_NAME') as PDB_NAME FROM dual;
EXIT;
EOF

echo ""
echo "=========================================="

# Test 3: Check listener status
echo "Test 3: Checking listener status..."
docker exec oracle-xe-21c lsnrctl status

echo ""
echo "=========================================="
echo "Connection tests completed!"
echo "=========================================="
