# Task 2 - Quick Commands Reference

## View Container Logs

### View All Logs
```bash
# All containers
docker compose -f task2-docker-compose.yaml logs

# All containers with timestamps
docker compose -f task2-docker-compose.yaml logs -t

# Last 50 lines from all containers
docker compose -f task2-docker-compose.yaml logs --tail=50
```

### Follow Logs (Real-time)
```bash
# Follow all logs
docker compose -f task2-docker-compose.yaml logs -f

# Follow specific container
docker compose -f task2-docker-compose.yaml logs -f namenode
docker compose -f task2-docker-compose.yaml logs -f hive-server
docker compose -f task2-docker-compose.yaml logs -f spark-master

# Follow multiple containers
docker compose -f task2-docker-compose.yaml logs -f namenode datanode
```

### View Specific Container Logs
```bash
# HDFS containers
docker compose -f task2-docker-compose.yaml logs namenode
docker compose -f task2-docker-compose.yaml logs datanode

# Hive containers
docker compose -f task2-docker-compose.yaml logs hive-metastore-postgresql
docker compose -f task2-docker-compose.yaml logs hive-metastore-init
docker compose -f task2-docker-compose.yaml logs hive-metastore
docker compose -f task2-docker-compose.yaml logs hive-server

# Spark containers
docker compose -f task2-docker-compose.yaml logs spark-master
docker compose -f task2-docker-compose.yaml logs spark-worker-1
docker compose -f task2-docker-compose.yaml logs spark-worker-2
```

### Filter Logs by Time
```bash
# Logs from last 10 minutes
docker compose -f task2-docker-compose.yaml logs --since=10m namenode

# Logs from last 1 hour
docker compose -f task2-docker-compose.yaml logs --since=1h

# Logs since specific time
docker compose -f task2-docker-compose.yaml logs --since=2025-12-04T06:00:00
```

### Using the Log Viewing Script
```bash
# Make script executable
chmod +x view-task2-logs.sh

# View namenode logs
./view-task2-logs.sh namenode

# Follow hive-server logs
./view-task2-logs.sh -f hive-server

# Show last 50 lines
./view-task2-logs.sh -n 50 spark-master

# Show all HDFS logs
./view-task2-logs.sh --hdfs

# Show all Hive logs
./view-task2-logs.sh --hive

# Show all Spark logs
./view-task2-logs.sh --spark
```

## Check Container Status

### Basic Status
```bash
# All containers
docker compose -f task2-docker-compose.yaml ps

# Specific container
docker compose -f task2-docker-compose.yaml ps namenode

# Show all (including stopped)
docker compose -f task2-docker-compose.yaml ps -a
```

### Using Verification Script
```bash
# Make script executable
chmod +x verify-task2-containers.sh

# Run verification
./verify-task2-containers.sh
```

## Troubleshoot Hive Metastore Issue

The most common issue is `hive-metastore-init` exiting with code 4.

### Check the Issue
```bash
# Run diagnostic script
chmod +x diagnose-hive-issue.sh
./diagnose-hive-issue.sh
```

### Solution: Clean Restart
```bash
# Stop all containers and remove volumes
docker compose -f task2-docker-compose.yaml down -v

# Start fresh
docker compose -f task2-docker-compose.yaml up -d

# Watch logs
docker compose -f task2-docker-compose.yaml logs -f
```

### Alternative: Restart Specific Services
```bash
# Restart Hive services
docker compose -f task2-docker-compose.yaml restart hive-metastore-postgresql
docker compose -f task2-docker-compose.yaml restart hive-metastore-init
docker compose -f task2-docker-compose.yaml up -d hive-metastore hive-server
```

## Container Management

### Start/Stop Services
```bash
# Start all services
docker compose -f task2-docker-compose.yaml up -d

# Stop all services
docker compose -f task2-docker-compose.yaml stop

# Stop and remove containers (keeps volumes)
docker compose -f task2-docker-compose.yaml down

# Stop and remove everything including volumes
docker compose -f task2-docker-compose.yaml down -v
```

### Restart Services
```bash
# Restart all
docker compose -f task2-docker-compose.yaml restart

# Restart specific service
docker compose -f task2-docker-compose.yaml restart namenode
docker compose -f task2-docker-compose.yaml restart hive-server
docker compose -f task2-docker-compose.yaml restart spark-master
```

### Execute Commands in Containers
```bash
# HDFS commands
docker exec -it namenode bash
docker exec -it namenode hdfs dfs -ls /
docker exec -it namenode hdfs dfsadmin -report

# Hive commands
docker exec -it hive-server bash
docker exec -it hive-server beeline -u jdbc:hive2://localhost:10000

# Spark commands
docker exec -it spark-master bash
docker exec -it spark-master pyspark --master spark://spark-master:7077

# PostgreSQL commands
docker exec -it hive-metastore-postgresql psql -U hive -d metastore
```

## Monitor Resources

### Resource Usage
```bash
# All containers
docker stats

# Specific containers
docker stats namenode datanode spark-master

# One-time stats (no streaming)
docker stats --no-stream
```

### Disk Usage
```bash
# Show volume sizes
docker system df -v

# Show container sizes
docker ps -s
```

## Inspect Containers

### Detailed Information
```bash
# Full container details
docker inspect namenode

# Get specific fields
docker inspect --format='{{.State.Status}}' namenode
docker inspect --format='{{.State.Health.Status}}' namenode
docker inspect --format='{{.NetworkSettings.Networks}}' namenode
```

### Health Checks
```bash
# Check health status
docker inspect --format='{{.State.Health.Status}}' namenode

# View health check logs
docker inspect --format='{{json .State.Health}}' namenode | jq
```

## Debugging Tips

### Check Service Dependencies
```bash
# List all services and their status
docker compose -f task2-docker-compose.yaml ps

# Check what's preventing a service from starting
docker compose -f task2-docker-compose.yaml logs [service-name]
```

### Network Debugging
```bash
# List networks
docker network ls

# Inspect task2 network
docker network inspect cw-msc_task2-net

# Test connectivity between containers
docker exec namenode ping -c 3 datanode
docker exec spark-master curl -v namenode:50070
```

### Volume Inspection
```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect cw-msc_namenode_data

# Check volume contents
docker run --rm -v cw-msc_namenode_data:/data alpine ls -la /data
```

## Common Log Patterns to Look For

### Success Patterns
```bash
# HDFS NameNode started
docker compose -f task2-docker-compose.yaml logs namenode | grep "NameNode RPC up"

# Hive Metastore started
docker compose -f task2-docker-compose.yaml logs hive-metastore | grep "Starting hive metastore"

# Spark Master started
docker compose -f task2-docker-compose.yaml logs spark-master | grep "Master: Started"
```

### Error Patterns
```bash
# Connection refused errors
docker compose -f task2-docker-compose.yaml logs | grep "Connection refused"

# Out of memory errors
docker compose -f task2-docker-compose.yaml logs | grep -i "OutOfMemory"

# Permission denied errors
docker compose -f task2-docker-compose.yaml logs | grep "Permission denied"

# Port already in use
docker compose -f task2-docker-compose.yaml logs | grep "Address already in use"
```

## Quick Fixes

### Issue: Containers won't start
```bash
# Check if ports are in use
lsof -i :50070
lsof -i :8080
lsof -i :9083

# Clean restart
docker compose -f task2-docker-compose.yaml down -v
docker compose -f task2-docker-compose.yaml up -d
```

### Issue: Out of memory
```bash
# Check Docker memory limit
docker info | grep Memory

# Restart Docker Desktop and allocate more memory
# Preferences → Resources → Memory (increase to 8GB+)
```

### Issue: Hive metastore init fails
```bash
# Complete clean restart
docker compose -f task2-docker-compose.yaml down -v
docker volume prune -f
docker compose -f task2-docker-compose.yaml up -d
```

### Issue: Can't connect to services
```bash
# Check all services are running
docker compose -f task2-docker-compose.yaml ps

# Check specific service logs
docker compose -f task2-docker-compose.yaml logs [service-name]

# Test port accessibility
curl http://localhost:50070  # HDFS UI
curl http://localhost:8080   # Spark UI
```

## Export Logs

### Save Logs to Files
```bash
# All logs to file
docker compose -f task2-docker-compose.yaml logs > all-logs.txt

# Specific container to file
docker compose -f task2-docker-compose.yaml logs namenode > namenode-logs.txt

# With timestamps
docker compose -f task2-docker-compose.yaml logs -t > all-logs-with-timestamps.txt

# Last 1000 lines
docker compose -f task2-docker-compose.yaml logs --tail=1000 > recent-logs.txt
```

### Create Log Archive
```bash
# Save all logs with date
DATE=$(date +%Y%m%d_%H%M%S)
docker compose -f task2-docker-compose.yaml logs > task2-logs-$DATE.txt
```
