# Task 2 - Quick Start Summary

## What Has Been Created

I've created a unified Docker Compose environment for Task 2 based on the IIT lab tutorials (lab3_4, lab5, and lab7). Here's what you have:

### 📁 Files Created

1. **[task2-docker-compose.yaml](task2-docker-compose.yaml)** - Main docker-compose file
   - Integrates Hadoop MapReduce, Hive, and Spark
   - Uses correct images from IIT labs (ramilu90/* images)
   - Properly configured service dependencies

2. **[task2-hadoop.env](task2-hadoop.env)** - Environment configuration
   - Hadoop/HDFS settings
   - Hive metastore configuration
   - YARN and MapReduce settings
   - Based on lab5 and lab7 configurations

3. **[TASK2-README.md](TASK2-README.md)** - Complete documentation
   - Architecture overview
   - Setup instructions
   - Task requirements breakdown
   - Useful commands
   - Troubleshooting guide

4. **[TASK2-EXAMPLES.md](TASK2-EXAMPLES.md)** - Code templates
   - MapReduce Java examples (Mapper, Reducer, Driver)
   - Hive SQL query examples
   - PySpark script examples
   - Data loading examples

5. **[setup-task2.sh](setup-task2.sh)** - Setup automation script
   - Creates required directories
   - Checks Docker status
   - Displays next steps

---

## 🚀 Quick Start (5 Steps)

### Step 1: Run Setup
```bash
cd /Users/minura/projects/msc-cw
./setup-task2.sh
```

### Step 2: Place Your Data
```bash
# Copy your weather dataset CSV files to the data directory
cp /path/to/your/weather_data.csv data/
```

### Step 3: Start Services
```bash
docker-compose -f task2-docker-compose.yaml up -d
```

### Step 4: Wait for Services (2-3 minutes)
```bash
# Watch the logs
docker-compose -f task2-docker-compose.yaml logs -f

# Check status
docker-compose -f task2-docker-compose.yaml ps
```

### Step 5: Load Data to HDFS
```bash
# Copy data to namenode container
docker cp data/weather_data.csv namenode:/tmp/

# Create HDFS directory and load data
docker exec -it namenode bash -c "
  hdfs dfs -mkdir -p /user/input
  hdfs dfs -put /tmp/weather_data.csv /user/input/
  hdfs dfs -ls /user/input/
"
```

---

## 📊 Task 2 Requirements Breakdown

### Task 2.1 - Hadoop MapReduce
**What to do:**
- Calculate total precipitation and mean temperature per district per month
- Find month/year with highest total precipitation

**How to do it:**
1. Write MapReduce Java code (see TASK2-EXAMPLES.md)
2. Compile and package as JAR
3. Place JAR in `mapreduce-jars/` directory
4. Run job on HDFS data
5. Collect results

**Reference:** Based on IIT lab3_4_map_reduce

---

### Task 2.2 - Hive/Pig Analysis
**What to do:**
- Rank top 10 most temperate cities (by temperature_2m_max)
- Calculate average evapotranspiration by agricultural season per district

**How to do it:**
1. Create Hive tables (see TASK2-EXAMPLES.md)
2. Load data into Hive
3. Write and execute Hive queries
4. Save query scripts in `hive-scripts/` directory
5. Export results

**Reference:** Based on IIT lab5 (Hive)

---

### Task 2.3 - Spark Analysis
**What to do:**
- Calculate % of months with shortwave radiation > 15MJ/m²
- Calculate weekly max temperatures for hottest months

**How to do it:**
1. Write PySpark scripts (see TASK2-EXAMPLES.md)
2. Place scripts in `spark-scripts/` directory
3. Submit jobs to Spark cluster
4. Collect and analyze results

**Reference:** Based on IIT lab7 (Spark)

---

## 🔧 Services & Ports

| Service | Port | URL | Purpose |
|---------|------|-----|---------|
| HDFS NameNode | 50070 | http://localhost:50070 | HDFS Web UI |
| HDFS RPC | 8020 | - | HDFS API |
| HiveServer2 | 10000 | - | Hive queries |
| Hive Metastore | 9083 | - | Metadata service |
| PostgreSQL | 5432 | - | Metastore DB |
| Spark Master | 8080 | http://localhost:8080 | Spark UI |
| Spark Master | 7077 | - | Spark API |
| Spark Worker 1 | 8081 | http://localhost:8081 | Worker UI |
| Spark Worker 2 | 8082 | http://localhost:8082 | Worker UI |

---

## 📂 Directory Structure

```
msc-cw/
├── task2-docker-compose.yaml    # Main docker-compose file
├── task2-hadoop.env             # Environment configuration
├── setup-task2.sh               # Setup script
├── TASK2-README.md              # Full documentation
├── TASK2-EXAMPLES.md            # Code examples
├── TASK2-SUMMARY.md             # This file
│
├── data/                        # Place your CSV data here
│   └── weather_data.csv
│
├── mapreduce-jars/              # Place compiled MapReduce JARs here
│   └── task2/
│       └── weather-analysis.jar
│
├── hive-scripts/                # Place Hive SQL scripts here
│   └── task2/
│       ├── create_tables.hql
│       ├── top_temperate_cities.hql
│       └── evapotranspiration_season.hql
│
├── spark-scripts/               # Place PySpark scripts here
│   └── task2/
│       ├── radiation_analysis.py
│       └── weekly_temperature.py
│
└── resources/                   # Additional resources if needed
```

---

## ⚙️ Architecture Overview

```
┌────────────────────────────────────────────────────────┐
│                   Task 2 Analytics                      │
├────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐    │
│  │MapReduce │  │   Hive   │  │  Spark Cluster   │    │
│  │  (YARN)  │  │(HiveServer2)│  │(1M + 2W)    │    │
│  └────┬─────┘  └────┬─────┘  └────────┬─────────┘    │
│       │             │                  │               │
│       └─────────────┴──────────────────┘               │
│                     │                                   │
│           ┌─────────▼─────────┐                        │
│           │   HDFS Storage    │                        │
│           │ (NameNode + DN)   │                        │
│           └───────────────────┘                        │
│                                                         │
│           ┌───────────────────┐                        │
│           │ Hive Metastore    │                        │
│           │   (PostgreSQL)    │                        │
│           └───────────────────┘                        │
└────────────────────────────────────────────────────────┘
```

---

## 🎯 Next Steps

1. **Understand the Task Requirements**
   - Read Task 2 in the assessment brief
   - Review TASK2-README.md for detailed requirements

2. **Set Up Environment**
   - Run `./setup-task2.sh`
   - Start services with docker-compose
   - Verify all services are running

3. **Develop Solutions**
   - **Task 2.1:** Write MapReduce code
   - **Task 2.2:** Write Hive queries
   - **Task 2.3:** Write Spark scripts

4. **Test Each Component**
   - Test MapReduce job
   - Test Hive queries
   - Test Spark scripts

5. **Document Results**
   - Capture output from each task
   - Take screenshots of web UIs
   - Save results for report

6. **Prepare Submission**
   - Compile all code
   - Write report
   - Include all required deliverables

---

## 💡 Tips

1. **Start Small**
   - Test with a small dataset first
   - Verify each component works before running full analysis

2. **Use Web UIs**
   - Monitor HDFS at http://localhost:50070
   - Monitor Spark jobs at http://localhost:8080
   - These help debug issues

3. **Check Logs**
   - Use `docker logs <container-name>` to debug
   - Common issues: out of memory, connection timeouts

4. **Save Intermediate Results**
   - Save outputs at each stage
   - Don't overwrite previous results

5. **Test Incrementally**
   - Test MapReduce first
   - Then Hive
   - Finally Spark
   - Each builds on HDFS data

---

## 🆘 Common Issues

### Services won't start
- Ensure Docker has 8GB+ RAM
- Check ports aren't in use
- View logs: `docker-compose -f task2-docker-compose.yaml logs`

### Can't connect to HDFS
```bash
docker exec -it namenode hdfs dfsadmin -report
```

### Hive metastore issues
```bash
docker-compose -f task2-docker-compose.yaml restart hive-metastore-init
```

### Spark workers not connecting
```bash
docker logs spark-master
docker-compose -f task2-docker-compose.yaml restart spark-worker-1
```

---

## 📚 References

- **IIT Lab 3_4:** MapReduce patterns and design
- **IIT Lab 5:** Hive setup and queries
- **IIT Lab 7:** Spark distributed processing
- **Assessment Brief:** Task 2 requirements

---

## ✅ Verification Checklist

Before submitting, ensure:

- [ ] All services start successfully
- [ ] Data loaded to HDFS
- [ ] MapReduce job runs and produces output
- [ ] Hive tables created and queries execute
- [ ] Spark jobs run successfully
- [ ] All outputs captured and documented
- [ ] Code organized in correct directories
- [ ] Screenshots of web UIs captured
- [ ] Report includes all required sections

---

Good luck with your Task 2 implementation! 🚀