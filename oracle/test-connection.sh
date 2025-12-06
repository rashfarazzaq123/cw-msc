#!/bin/bash
# Test Oracle Database Connection

echo "=========================================="
echo "Testing Oracle Database Connection"
echo "=========================================="
echo ""

# Test 1: Connect as SYS user
echo "Test 1: Connecting as SYS user to XE..."
docker exec oracle-xe-21c bash -c "echo \"
SET HEADING ON
SET PAGESIZE 100
SELECT 'Connection successful!' as STATUS FROM dual;
SELECT instance_name, status, database_status FROM v\\\$instance;
SELECT banner FROM v\\\$version WHERE ROWNUM = 1;
EXIT;
\" | sqlplus -s sys/OraclePassword123@XE as sysdba"

echo ""
echo "=========================================="

# Test 2: Connect as coursework user to PDB
echo "Test 2: Connecting as coursework user to XEPDB1..."
docker exec oracle-xe-21c bash -c "echo \"
SET HEADING ON
SET PAGESIZE 100
SELECT 'Coursework user connected!' as STATUS FROM dual;
SELECT USER as USERNAME, SYS_CONTEXT('USERENV', 'CON_NAME') as DATABASE FROM dual;
CREATE TABLE test_table (id NUMBER, name VARCHAR2(50));
INSERT INTO test_table VALUES (1, 'Test successful');
SELECT * FROM test_table;
DROP TABLE test_table;
EXIT;
\" | sqlplus -s coursework/CourseworkPass123@XEPDB1"

echo ""
echo "=========================================="

# Test 3: Test from external connection (if you have sqlplus on host)
echo "Test 3: Connection details for external clients..."
echo ""
echo "Connection String: <server-ip>:1521/XEPDB1"
echo "Username: coursework"
echo "Password: CourseworkPass123"
echo ""
echo "Example connection commands:"
echo "  sqlplus coursework/CourseworkPass123@<server-ip>:1521/XEPDB1"
echo "  SQL Developer: Host=<server-ip>, Port=1521, Service=XEPDB1"
echo ""

echo "=========================================="
echo "Adminer Web UI:"
echo "  URL: http://<server-ip>:8080"
echo "  System: Oracle"
echo "  Server: oracle-db"
echo "  Username: coursework"
echo "  Password: CourseworkPass123"
echo "  Database: XEPDB1"
echo "=========================================="
