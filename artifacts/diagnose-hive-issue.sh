#!/bin/bash

# =============================================================================
# Diagnose Hive Metastore Init Issue
# =============================================================================

echo "=========================================="
echo "Diagnosing Hive Metastore Init Issue"
echo "=========================================="
echo ""

echo "1. Checking hive-metastore-init logs:"
echo "─────────────────────────────────────────"
docker compose -f task2-docker-compose.yaml logs hive-metastore-init | tail -50
echo ""

echo "2. Checking hive-metastore-init exit code:"
echo "─────────────────────────────────────────"
EXIT_CODE=$(docker inspect hive-metastore-init --format='{{.State.ExitCode}}' 2>/dev/null)
echo "Exit code: $EXIT_CODE"

if [ "$EXIT_CODE" == "4" ]; then
    echo ""
    echo "Exit code 4 typically means the schema already exists or there's a connection issue."
    echo ""
    echo "Possible solutions:"
    echo "1. Clean start - Remove volumes and restart:"
    echo "   docker compose -f task2-docker-compose.yaml down -v"
    echo "   docker compose -f task2-docker-compose.yaml up -d"
    echo ""
    echo "2. Check PostgreSQL is accessible:"
    echo "   docker compose -f task2-docker-compose.yaml logs hive-metastore-postgresql"
fi

echo ""
echo "3. Checking PostgreSQL status:"
echo "─────────────────────────────────────────"
docker compose -f task2-docker-compose.yaml ps hive-metastore-postgresql

echo ""
echo "4. Testing PostgreSQL connection:"
echo "─────────────────────────────────────────"
docker exec hive-metastore-postgresql pg_isready -U hive 2>/dev/null && echo "✓ PostgreSQL is ready" || echo "✗ PostgreSQL is not ready"

echo ""
echo "5. Checking if metastore schema exists:"
echo "─────────────────────────────────────────"
docker exec hive-metastore-postgresql psql -U hive -d metastore -c "\dt" 2>/dev/null | head -20

echo ""
echo "=========================================="
echo "Diagnostic complete"
echo "=========================================="
