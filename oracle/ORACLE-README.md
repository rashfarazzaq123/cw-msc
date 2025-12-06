# Oracle Database Docker Deployment for Coursework

Docker Compose setup for Oracle Database Express Edition (XE) 21c on GCP Ubuntu Server.

**Using `gvenzl/oracle-xe:21.3.0` - No Oracle account required!**

## Why gvenzl/oracle-xe?

- ✅ Available on Docker Hub (no Oracle account needed)
- ✅ Faster startup: 1-2 minutes vs 5-10 minutes
- ✅ Smaller image: ~2GB vs ~6GB
- ✅ Automatic app user creation
- ✅ Built-in health checks
- ✅ Better documentation and ease of use

## Quick Start

### 1. Install Docker on GCP Ubuntu
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
# Logout and login for group changes to take effect
```

### 2. Deploy Oracle Database
```bash
# No registry login required!
docker compose -f oracle-db-docker-compose.yaml up -d

# Monitor startup (takes 1-2 minutes)
docker compose -f oracle-db-docker-compose.yaml logs -f oracle-db
# Wait for "DATABASE IS READY TO USE!" message
```

### 3. Connect to Database
```bash
# From the GCP server
docker exec -it oracle-xe-21c sqlplus system/OraclePassword123@//localhost:1521/XE

# Connect as the coursework user (automatically created)
docker exec -it oracle-xe-21c sqlplus coursework/CourseworkPass123@//localhost:1521/XE
```

## Files Included

| File | Description |
|------|-------------|
| [oracle-db-docker-compose.yaml](oracle-db-docker-compose.yaml) | Main Docker Compose configuration |
| [ORACLE-DEPLOYMENT-GUIDE.md](ORACLE-DEPLOYMENT-GUIDE.md) | Comprehensive deployment guide |
| [.env.oracle](.env.oracle) | Environment variables template |
| `oracle-init/` | SQL scripts to run on first startup |
| `backups/` | Directory for database backups |

## What's Deployed

The docker-compose file includes:

1. **Oracle Database XE 21c** - Main database (gvenzl/oracle-xe:21.3.0)
2. **Adminer** - Web-based database management tool
3. **Backup Service** - For manual database backups

## Connection Information

### Default Credentials

| User | Password | Purpose |
|------|----------|---------|
| system | OraclePassword123 | Database admin |
| sys | OraclePassword123 | System admin |
| coursework | CourseworkPass123 | App user (auto-created) |

**IMPORTANT**: Change these passwords before deployment!

### Connection Details

| Parameter | Value |
|-----------|-------|
| Hostname | GCP VM External IP |
| Port | 1521 |
| SID | XE |
| Service Name | XE |

### JDBC Connection String
```
jdbc:oracle:thin:@//[GCP-VM-IP]:1521/XE
```

### SQLPlus Connection
```bash
sqlplus coursework/CourseworkPass123@//[GCP-VM-IP]:1521/XE
```

### Python Connection
```python
import cx_Oracle
connection = cx_Oracle.connect('coursework/CourseworkPass123@[GCP-VM-IP]:1521/XE')
```

## Web Interfaces

| Service | URL | Port |
|---------|-----|------|
| Adminer | http://[GCP-VM-IP]:8080 | 8080 |
| Oracle EM Express | https://[GCP-VM-IP]:5500/em | 5500 |

## GCP Firewall Setup

```bash
# Allow Oracle Database connections
gcloud compute firewall-rules create allow-oracle-db \
  --allow tcp:1521 \
  --source-ranges YOUR_IP/32 \
  --description "Allow Oracle DB"

# Allow Adminer web interface
gcloud compute firewall-rules create allow-adminer \
  --allow tcp:8080 \
  --source-ranges YOUR_IP/32 \
  --description "Allow Adminer"
```

Replace `YOUR_IP` with your actual IP address.

## Features

### Automatic App User Creation

The docker-compose file creates a `coursework` user automatically with:
- CONNECT privilege
- RESOURCE privilege
- UNLIMITED TABLESPACE

Configure via environment variables:
```yaml
environment:
  - APP_USER=coursework
  - APP_USER_PASSWORD=CourseworkPass123
```

### Custom Initialization Scripts

Place SQL scripts in `./oracle-init/` - they run automatically on first startup:

**Example: `oracle-init/01-create-schema.sql`**
```sql
-- Create tables
CREATE TABLE students (
    student_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) UNIQUE
);

-- Insert data
INSERT INTO students VALUES (1, 'John', 'Doe', 'john@example.com');
COMMIT;
```

### Data Persistence

Database data is stored in a Docker volume that persists across container restarts:
- Volume name: `oracle_data`
- Location: `/opt/oracle/oradata` (inside container)

## Common Commands

```bash
# Start services
docker compose -f oracle-db-docker-compose.yaml up -d

# Stop services (data persists)
docker compose -f oracle-db-docker-compose.yaml down

# View logs
docker compose -f oracle-db-docker-compose.yaml logs -f oracle-db

# Restart database
docker compose -f oracle-db-docker-compose.yaml restart oracle-db

# Connect to SQL*Plus
docker exec -it oracle-xe-21c sqlplus system/OraclePassword123@//localhost:1521/XE

# Run backup
docker compose -f oracle-db-docker-compose.yaml run oracle-backup

# Check database status
docker compose -f oracle-db-docker-compose.yaml ps
```

## Backup & Restore

### Quick Backup
```bash
# Using Data Pump
docker exec -it oracle-xe-21c expdp system/OraclePassword123@XE \
  directory=DATA_PUMP_DIR \
  dumpfile=backup_$(date +%Y%m%d).dmp \
  full=y
```

### Quick Restore
```bash
docker exec -it oracle-xe-21c impdp system/OraclePassword123@XE \
  directory=DATA_PUMP_DIR \
  dumpfile=backup_YYYYMMDD.dmp \
  full=y
```

## Security Checklist

- [ ] Change default passwords in docker-compose file
- [ ] Restrict GCP firewall rules to your IP only
- [ ] Don't use `0.0.0.0/0` in firewall rules
- [ ] Add `.env.oracle` to `.gitignore`
- [ ] Disable Adminer in production
- [ ] Use SSL/TLS for production deployments
- [ ] Enable regular automated backups

## Troubleshooting

### Database won't start
```bash
docker logs oracle-xe-21c
docker stats oracle-xe-21c
df -h  # Check disk space
```

### Can't connect
```bash
docker exec -it oracle-xe-21c lsnrctl status
docker port oracle-xe-21c 1521
telnet localhost 1521
```

### Reset password
```sql
docker exec -it oracle-xe-21c sqlplus / as sysdba
ALTER USER system IDENTIFIED BY NewPassword123;
EXIT;
```

### Complete reset (deletes all data!)
```bash
docker compose -f oracle-db-docker-compose.yaml down -v
docker compose -f oracle-db-docker-compose.yaml up -d
```

## Resource Requirements

### Minimum
- 2 CPU cores
- 4GB RAM
- 20GB disk space

### Recommended
- 4 CPU cores
- 8GB RAM
- 50GB disk space

Adjust resource limits in docker-compose file:
```yaml
deploy:
  resources:
    limits:
      cpus: '2.0'
      memory: 4G
```

## Directory Structure

```
.
├── oracle-db-docker-compose.yaml    # Docker Compose file
├── ORACLE-DEPLOYMENT-GUIDE.md       # Detailed guide
├── ORACLE-README.md                 # This file
├── .env.oracle                      # Environment variables
├── oracle-init/                     # Initialization SQL scripts
│   ├── 01-create-tables.sql
│   └── 02-create-procedures.sql
└── backups/                         # Database backups
```

## Full Documentation

See [ORACLE-DEPLOYMENT-GUIDE.md](ORACLE-DEPLOYMENT-GUIDE.md) for:
- Detailed installation steps
- Connection examples (JDBC, Python, SQL*Plus)
- Advanced configuration
- Performance tuning
- Security best practices
- Backup/restore procedures
- Troubleshooting guide

## Comparison: gvenzl vs Official Oracle Image

| Feature | gvenzl/oracle-xe | Official Oracle |
|---------|------------------|-----------------|
| Registry | Docker Hub | Oracle Container Registry |
| Account Required | No | Yes |
| Startup Time | 1-2 minutes | 5-10 minutes |
| Image Size | ~2GB | ~6GB |
| Auto App User | ✅ Yes | ❌ No |
| Built-in Health Check | ✅ Yes | ❌ No |
| Ease of Use | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |

## Resources

- [gvenzl/oracle-xe GitHub](https://github.com/gvenzl/oci-oracle-xe)
- [Oracle XE Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/21/)
- [Full Deployment Guide](ORACLE-DEPLOYMENT-GUIDE.md)

## License

Oracle Database Express Edition is free for development, testing, and production use.

## Support

- **Coursework questions**: Contact your instructor/TA
- **Oracle issues**: Oracle documentation and forums
- **Image issues**: [gvenzl/oracle-xe GitHub Issues](https://github.com/gvenzl/oci-oracle-xe/issues)
