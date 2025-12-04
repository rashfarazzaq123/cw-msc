# Fix: Hive Metastore Init Issue (Exit Code 4)

## Problem
You're seeing:
```
service "hive-metastore-init" didn't completed successfully: exit 4
```

This means the Hive metastore initialization is failing, which prevents `hive-metastore` and `hive-server` from starting.

## Cause
Exit code 4 from `hive-metastore-init` typically means:
1. The PostgreSQL metastore schema already exists from a previous run
2. There's a connection issue to PostgreSQL
3. Schema initialization encountered an error

## Immediate Solution

### Option 1: Clean Restart (Recommended)

This removes all data and starts fresh:

```bash
# Stop all services and remove volumes
docker compose -f task2-docker-compose.yaml down -v

# Start fresh
docker compose -f task2-docker-compose.yaml up -d

# Watch the logs to see progress
docker compose -f task2-docker-compose.yaml logs -f
```

**What this does:**
- `-v` flag removes all volumes (namenode data, datanode data, metastore database)
- Allows `hive-metastore-init` to create a fresh schema
- All services start cleanly

### Option 2: Keep Data, Reset Hive Only

If you want to keep HDFS data but reset Hive:

```bash
# Stop all services
docker compose -f task2-docker-compose.yaml down

# Remove only the metastore volume
docker volume rm cw-msc_metastore_db

# Start services again
docker compose -f task2-docker-compose.yaml up -d
```

## Verify the Fix

After restart, check status:

```bash
# Check all containers (should see all running or exited with 0)
docker compose -f task2-docker-compose.yaml ps

# Specifically check hive-metastore-init exit code
docker inspect hive-metastore-init --format='{{.State.ExitCode}}'
```

**Expected output:**
- Exit code should be `0` (success)
- `hive-metastore` should be running
- `hive-server` should be running

## Detailed Diagnosis

Run the diagnostic script:

```bash
chmod +x diagnose-hive-issue.sh
./diagnose-hive-issue.sh
```

This will show you:
- Hive init logs
- Exit code
- PostgreSQL status
- Whether schema already exists

## Viewing Logs

### Quick View
```bash
# View hive-metastore-init logs
docker compose -f task2-docker-compose.yaml logs hive-metastore-init

# View all Hive-related logs
docker compose -f task2-docker-compose.yaml logs hive-metastore-postgresql hive-metastore-init hive-metastore hive-server
```

### Using the Script
```bash
chmod +x view-task2-logs.sh

# View all Hive logs
./view-task2-logs.sh --hive

# Follow hive-metastore-init logs
./view-task2-logs.sh -f hive-metastore-init
```

## Prevention

To avoid this issue in the future:

1. **First time setup:** Just run `docker compose up -d`
2. **Stopping services:** Use `docker compose stop` (keeps data) instead of `down -v`
3. **Restarting:** Use `docker compose restart` for quick restarts
4. **Clean reset:** Only use `down -v` when you want to completely reset

## What's Happening Behind the Scenes

1. **hive-metastore-postgresql** starts and creates an empty PostgreSQL database
2. **hive-metastore-init** runs `schematool -initSchema` to create Hive tables
3. If schema already exists, initSchema fails with exit code 4
4. **hive-metastore** and **hive-server** wait for init to complete successfully
5. Since init failed, they never start

## Success Indicators

When working correctly, you should see:

```bash
docker compose -f task2-docker-compose.yaml ps
```

Output showing:
```
NAME                        STATUS              PORTS
namenode                    Up (healthy)        0.0.0.0:8020->8020/tcp, 0.0.0.0:50070->50070/tcp
datanode                    Up
hive-metastore-postgresql   Up (healthy)        0.0.0.0:5432->5432/tcp
hive-metastore-init         Exited (0)
hive-metastore              Up                  0.0.0.0:9083->9083/tcp
hive-server                 Up                  0.0.0.0:10000->10000/tcp
spark-master                Up                  0.0.0.0:7077->7077/tcp, 0.0.0.0:8080->8080/tcp
spark-worker-1              Up                  0.0.0.0:8081->8081/tcp
spark-worker-2              Up                  0.0.0.0:8082->8082/tcp
```

Notice:
- `hive-metastore-init` is **Exited (0)** - this is correct!
- `hive-metastore` and `hive-server` are **Up**

## Test Hive is Working

After successful startup:

```bash
# Connect to HiveServer2
docker exec -it hive-server beeline -u jdbc:hive2://localhost:10000

# Once connected, try:
# SHOW DATABASES;
# CREATE DATABASE test;
# SHOW DATABASES;
```

If this works, Hive is running correctly!

## Need More Help?

See the complete troubleshooting guide in [TASK2-QUICK-COMMANDS.md](TASK2-QUICK-COMMANDS.md)
