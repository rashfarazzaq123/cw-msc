# Oracle Database Dev/Test Deployment Guide - GCP Ubuntu Server

## Using gvenzl/oracle-xe:21.3.0 Image

This guide uses the `gvenzl/oracle-xe` image which offers:
- ✅ No Oracle account required (available on Docker Hub)
- ✅ Faster startup (~1-2 minutes vs 5-10 minutes)
- ✅ Smaller image size
- ✅ Easier configuration
- ✅ Automatic app user creation
- ✅ Better health checks

## Prerequisites

### 1. System Requirements
- GCP Ubuntu Server 20.04 or 22.04 LTS
- Minimum 4GB RAM (8GB recommended)
- 20GB available disk space
- Docker Engine 20.10+ installed
- Docker Compose 2.0+ installed

### 2. Install Docker on GCP Ubuntu Server

```bash
# Update package index
sudo apt-get update

# Install required packages
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add current user to docker group (logout/login required)
sudo usermod -aG docker $USER

# Verify installation
docker --version
docker compose version
```

## Deployment Steps

### 1. Create Directory Structure

```bash
# Create project directory
mkdir -p ~/oracle-db-deployment
cd ~/oracle-db-deployment

# Create initialization scripts directory
mkdir -p oracle-init backups
```

### 2. Download the Docker Compose File

Copy the `oracle-db-docker-compose.yaml` file to your GCP server, or create it directly.

### 3. Configure Environment (Optional)

Edit the docker-compose file to change default passwords:

```yaml
environment:
  - ORACLE_PASSWORD=YourSecurePassword123
  - APP_USER=coursework
  - APP_USER_PASSWORD=YourAppPassword123
```

### 4. Deploy the Stack

```bash
# Pull the image (optional - will auto-pull on first start)
docker pull gvenzl/oracle-xe:21.3.0

# Start Oracle Database
docker compose -f oracle-db-docker-compose.yaml up -d

# Monitor startup (first start takes 1-2 minutes)
docker compose -f oracle-db-docker-compose.yaml logs -f oracle-db

# Wait for "DATABASE IS READY TO USE!" message
```

### 5. Verify Installation

```bash
# Check if Oracle is healthy
docker compose -f oracle-db-docker-compose.yaml ps

# Connect to SQL*Plus
docker exec -it oracle-xe-21c sqlplus system/OraclePassword123@//localhost:1521/XE

# Inside SQL*Plus:
SELECT 'Database is ready!' FROM DUAL;
EXIT;
```

## Connection Details

### Database Connection Info

| Parameter | Value |
|-----------|-------|
| **Hostname** | GCP VM External IP or `localhost` |
| **Port** | 1521 |
| **SID** | XE |
| **Service Name** | XE or XEPDB1 |
| **SYS/SYSTEM Password** | OraclePassword123 |
| **App User** | coursework |
| **App User Password** | CourseworkPass123 |

### Connect Strings

```bash
# Connect as SYSTEM user
sqlplus system/OraclePassword123@//hostname:1521/XE

# Connect as app user (coursework)
sqlplus coursework/CourseworkPass123@//hostname:1521/XE

# Using XEPDB1 (Pluggable Database)
sqlplus system/OraclePassword123@//hostname:1521/XEPDB1
```

### JDBC Connection String

```
# For XE database
jdbc:oracle:thin:@//hostname:1521/XE

# For app user
jdbc:oracle:thin:coursework/CourseworkPass123@//hostname:1521/XE
```

### Python (cx_Oracle) Connection

```python
import cx_Oracle

# Connection string
dsn = cx_Oracle.makedsn('hostname', 1521, service_name='XE')
connection = cx_Oracle.connect(user='coursework', password='CourseworkPass123', dsn=dsn)

# Or use Easy Connect syntax
connection = cx_Oracle.connect('coursework/CourseworkPass123@hostname:1521/XE')
```

## Web Interfaces

### Oracle Enterprise Manager (EM) Express
- URL: `https://[GCP-VM-IP]:5500/em`
- Username: `SYSTEM`
- Password: `OraclePassword123`
- Note: You may get SSL certificate warnings (safe to proceed for dev/test)

### Adminer (Database Management)
- URL: `http://[GCP-VM-IP]:8080`
- System: Oracle
- Server: oracle-db
- Username: system (or coursework)
- Password: OraclePassword123 (or CourseworkPass123)
- Database: Leave blank or use XE

## GCP Firewall Configuration

```bash
# Allow Oracle Database port
gcloud compute firewall-rules create allow-oracle-db \
  --allow tcp:1521 \
  --source-ranges YOUR_IP/32 \
  --description "Allow Oracle Database connections"

# Allow EM Express (optional - HTTPS)
gcloud compute firewall-rules create allow-oracle-em \
  --allow tcp:5500 \
  --source-ranges YOUR_IP/32 \
  --description "Allow Oracle EM Express access"

# Allow Adminer (optional)
gcloud compute firewall-rules create allow-adminer \
  --allow tcp:8080 \
  --source-ranges YOUR_IP/32 \
  --description "Allow Adminer access"
```

**Security Note**: Replace `YOUR_IP` with your specific IP address (e.g., `203.0.113.42/32`). Never use `0.0.0.0/0` in production.

## Automatic App User Creation

The `gvenzl/oracle-xe` image automatically creates an app user if you specify these environment variables:

```yaml
environment:
  - APP_USER=coursework
  - APP_USER_PASSWORD=CourseworkPass123
```

This user is automatically granted:
- CONNECT privilege
- RESOURCE privilege
- UNLIMITED TABLESPACE

## Custom Initialization Scripts

Place SQL scripts in `./oracle-init/` directory. They will run automatically on first startup:

### Example: `oracle-init/01-create-tables.sql`

```sql
-- This script runs as the APP_USER (coursework)
-- Create sample tables for coursework

CREATE TABLE students (
    student_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) UNIQUE,
    enrollment_date DATE DEFAULT SYSDATE
);

CREATE TABLE courses (
    course_id NUMBER PRIMARY KEY,
    course_name VARCHAR2(100) NOT NULL,
    credits NUMBER(2) CHECK (credits > 0),
    department VARCHAR2(50)
);

CREATE TABLE enrollments (
    enrollment_id NUMBER PRIMARY KEY,
    student_id NUMBER REFERENCES students(student_id),
    course_id NUMBER REFERENCES courses(course_id),
    enrollment_date DATE DEFAULT SYSDATE,
    grade VARCHAR2(2)
);

-- Create sequences
CREATE SEQUENCE student_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE course_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE enrollment_seq START WITH 1 INCREMENT BY 1;

-- Insert sample data
INSERT INTO students VALUES (student_seq.NEXTVAL, 'John', 'Doe', 'john.doe@university.edu', SYSDATE);
INSERT INTO students VALUES (student_seq.NEXTVAL, 'Jane', 'Smith', 'jane.smith@university.edu', SYSDATE);

INSERT INTO courses VALUES (course_seq.NEXTVAL, 'Database Systems', 3, 'Computer Science');
INSERT INTO courses VALUES (course_seq.NEXTVAL, 'Data Structures', 4, 'Computer Science');

COMMIT;
```

### Example: `oracle-init/02-create-procedures.sql`

```sql
-- Create a stored procedure
CREATE OR REPLACE PROCEDURE enroll_student (
    p_student_id IN NUMBER,
    p_course_id IN NUMBER
) AS
BEGIN
    INSERT INTO enrollments (enrollment_id, student_id, course_id)
    VALUES (enrollment_seq.NEXTVAL, p_student_id, p_course_id);
    COMMIT;
END;
/
```

## Environment Variables Reference

### gvenzl/oracle-xe Supported Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `ORACLE_PASSWORD` | Password for SYS, SYSTEM, PDBADMIN | (required) |
| `ORACLE_RANDOM_PASSWORD` | Generate random password | false |
| `APP_USER` | Application username to create | (none) |
| `APP_USER_PASSWORD` | Application user password | (required if APP_USER set) |
| `ORACLE_DATABASE` | Database name | XE |
| `ORACLE_CHARACTERSET` | Character set | AL32UTF8 |

## Backup and Restore

### Manual Data Pump Export

```bash
# Export entire database
docker exec -it oracle-xe-21c expdp system/OraclePassword123@XE \
  directory=DATA_PUMP_DIR \
  dumpfile=full_backup_$(date +%Y%m%d).dmp \
  full=y \
  logfile=export_$(date +%Y%m%d).log

# Export specific schema (coursework user)
docker exec -it oracle-xe-21c expdp system/OraclePassword123@XE \
  directory=DATA_PUMP_DIR \
  dumpfile=coursework_backup_$(date +%Y%m%d).dmp \
  schemas=coursework \
  logfile=export_coursework_$(date +%Y%m%d).log
```

### Copy Dump File from Container

```bash
# Copy dump file to host
docker cp oracle-xe-21c:/opt/oracle/admin/XE/dpdump/full_backup_YYYYMMDD.dmp ./backups/
```

### Data Pump Import

```bash
# Import dump file
docker exec -it oracle-xe-21c impdp system/OraclePassword123@XE \
  directory=DATA_PUMP_DIR \
  dumpfile=full_backup_YYYYMMDD.dmp \
  full=y \
  logfile=import_$(date +%Y%m%d).log
```

### Volume Backup (Cold Backup)

```bash
# Stop the database
docker compose -f oracle-db-docker-compose.yaml down

# Backup the volume
docker run --rm -v oracle-db-deployment_oracle_data:/data \
  -v $(pwd)/backups:/backup \
  alpine tar czf /backup/oracle-volume-backup-$(date +%Y%m%d).tar.gz -C /data .

# Restart the database
docker compose -f oracle-db-docker-compose.yaml up -d
```

## Monitoring and Maintenance

### Check Database Status

```bash
# Container status
docker compose -f oracle-db-docker-compose.yaml ps

# View logs
docker compose -f oracle-db-docker-compose.yaml logs -f oracle-db

# Database health
docker exec -it oracle-xe-21c healthcheck.sh

# Database instance status
docker exec -it oracle-xe-21c sqlplus -s / as sysdba << EOF
SELECT instance_name, status, database_status FROM v\$instance;
EXIT;
EOF
```

### Resource Monitoring

```bash
# Monitor container resources
docker stats oracle-xe-21c

# Check disk usage
docker system df
df -h

# Check memory
free -h
```

### Check Tablespace Usage

```sql
-- Connect as SYSTEM
sqlplus system/OraclePassword123@//localhost:1521/XE

-- Check tablespace usage
SELECT
    tablespace_name,
    ROUND(SUM(bytes)/1024/1024, 2) AS size_mb,
    ROUND(SUM(CASE WHEN maxbytes = 0 THEN bytes ELSE maxbytes END)/1024/1024, 2) AS max_mb
FROM dba_data_files
GROUP BY tablespace_name
ORDER BY tablespace_name;

-- Check free space
SELECT
    tablespace_name,
    ROUND(SUM(bytes)/1024/1024, 2) AS free_mb
FROM dba_free_space
GROUP BY tablespace_name
ORDER BY tablespace_name;
```

## Stopping and Starting

```bash
# Stop services (data persists)
docker compose -f oracle-db-docker-compose.yaml down

# Stop and remove volumes (WARNING: deletes all data)
docker compose -f oracle-db-docker-compose.yaml down -v

# Start services
docker compose -f oracle-db-docker-compose.yaml up -d

# Restart Oracle only
docker compose -f oracle-db-docker-compose.yaml restart oracle-db

# View startup logs
docker compose -f oracle-db-docker-compose.yaml logs -f oracle-db
```

## Troubleshooting

### Database Not Starting

```bash
# Check logs for errors
docker logs oracle-xe-21c

# Check disk space
df -h

# Verify memory
free -h

# Check if port is already in use
sudo netstat -tulpn | grep 1521
```

### Cannot Connect to Database

```bash
# Verify listener is running
docker exec -it oracle-xe-21c lsnrctl status

# Check port is exposed
docker port oracle-xe-21c 1521

# Test connection from container
docker exec -it oracle-xe-21c sqlplus system/OraclePassword123@//localhost:1521/XE

# Check from host
telnet localhost 1521
```

### Reset Password

```sql
-- Connect as sysdba
docker exec -it oracle-xe-21c sqlplus / as sysdba

-- Change SYSTEM password
ALTER USER system IDENTIFIED BY NewPassword123;

-- Change app user password
ALTER USER coursework IDENTIFIED BY NewPassword123;

EXIT;
```

### Container Keeps Restarting

```bash
# Check logs
docker logs oracle-xe-21c --tail 100

# Check container events
docker events --filter container=oracle-xe-21c

# Inspect health check
docker inspect oracle-xe-21c | grep -A 10 Health
```

### Database Corruption Recovery

```bash
# Stop container
docker compose -f oracle-db-docker-compose.yaml down

# Remove corrupted volume
docker volume rm oracle-db-deployment_oracle_data

# Restart (fresh database)
docker compose -f oracle-db-docker-compose.yaml up -d

# Restore from backup
# (Use volume backup or Data Pump import)
```

## Security Recommendations

1. **Change Default Passwords**
   ```sql
   ALTER USER system IDENTIFIED BY "StrongP@ssw0rd!";
   ALTER USER sys IDENTIFIED BY "StrongP@ssw0rd!";
   ALTER USER coursework IDENTIFIED BY "StrongP@ssw0rd!";
   ```

2. **Restrict Firewall Rules**
   - Use specific IP addresses, not `0.0.0.0/0`
   - Example: `YOUR_IP/32` for single IP

3. **Disable Unused Services**
   - Remove Adminer in production
   - Disable EM Express if not needed

4. **Use SSL/TLS**
   - Configure Oracle Native Network Encryption
   - Use HTTPS for EM Express

5. **Regular Backups**
   - Schedule automated exports
   - Test restore procedures

6. **Update Regularly**
   ```bash
   docker pull gvenzl/oracle-xe:21.3.0
   docker compose -f oracle-db-docker-compose.yaml up -d
   ```

7. **Use Secrets Management**
   - GCP Secret Manager for production
   - Never commit passwords to git

## Performance Tuning for Dev/Test

```sql
-- Connect as sysdba
sqlplus / as sysdba

-- Increase SGA (System Global Area) - adjust based on available RAM
ALTER SYSTEM SET sga_max_size=2G SCOPE=SPFILE;
ALTER SYSTEM SET sga_target=2G SCOPE=SPFILE;

-- Increase PGA (Program Global Area)
ALTER SYSTEM SET pga_aggregate_target=512M SCOPE=BOTH;

-- Check current memory parameters
SHOW PARAMETER memory;
SHOW PARAMETER sga;
SHOW PARAMETER pga;

-- Restart required for SPFILE changes
SHUTDOWN IMMEDIATE;
STARTUP;
EXIT;
```

## Useful SQL Queries

### Check Database Version
```sql
SELECT * FROM v$version;
```

### List All Users
```sql
SELECT username, account_status, created FROM dba_users ORDER BY created DESC;
```

### Check Active Sessions
```sql
SELECT username, status, COUNT(*)
FROM v$session
WHERE username IS NOT NULL
GROUP BY username, status;
```

### View User Privileges
```sql
SELECT * FROM dba_sys_privs WHERE grantee = 'COURSEWORK';
SELECT * FROM dba_role_privs WHERE grantee = 'COURSEWORK';
```

## Clean Up

```bash
# Stop and remove containers
docker compose -f oracle-db-docker-compose.yaml down

# Remove volumes (deletes all data)
docker volume rm oracle-db-deployment_oracle_data

# Remove images (optional)
docker rmi gvenzl/oracle-xe:21.3.0
docker rmi adminer:latest

# Clean up system
docker system prune -a
```

## Differences: gvenzl/oracle-xe vs Official Oracle Image

| Feature | gvenzl/oracle-xe | Official Oracle |
|---------|------------------|-----------------|
| Registry | Docker Hub | container-registry.oracle.com |
| Account Required | No | Yes |
| Startup Time | 1-2 minutes | 5-10 minutes |
| Image Size | ~2GB | ~6GB |
| Auto App User | Yes | No |
| Health Check | Built-in | Manual |
| Ease of Use | High | Medium |
| Documentation | Excellent | Good |

## Additional Resources

- [gvenzl/oracle-xe GitHub](https://github.com/gvenzl/oci-oracle-xe)
- [Oracle XE Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/21/)
- [Oracle SQL Language Reference](https://docs.oracle.com/en/database/oracle/oracle-database/21/sqlrf/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

## Support

For coursework-related questions, contact your instructor or TA.
For Oracle-specific issues, refer to Oracle documentation and community forums.
For `gvenzl/oracle-xe` image issues, visit the [GitHub repository](https://github.com/gvenzl/oci-oracle-xe).
