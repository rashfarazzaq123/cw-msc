# Task 2 - Data Analysis Setup

## Overview
This docker-compose setup provides a unified environment for completing Task 2 of the Big Data Programming coursework. It integrates:
- **Hadoop MapReduce** for distributed data processing
- **Hive** for SQL-like data warehousing queries
- **Apache Spark** for fast, distributed data processing

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Task 2 Analytics Stack                   │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌────────────┐  ┌────────────┐  ┌────────────────────┐    │
│  │  MapReduce │  │    Hive    │  │   Spark (Master +  │    │
│  │   Jobs     │  │  Queries   │  │     2 Workers)     │    │
│  └─────┬──────┘  └─────┬──────┘  └─────────┬──────────┘    │
│        │               │                    │                │
│        └───────────────┴────────────────────┘                │
│                        │                                      │
│              ┌─────────▼──────────┐                          │
│              │   HDFS Storage     │                          │
│              │  (NameNode +       │                          │
│              │   DataNode)        │                          │
│              └────────────────────┘                          │
│                                                               │
│              ┌────────────────────┐                          │
│              │  Hive Metastore    │                          │
│              │   (PostgreSQL)     │                          │
│              └────────────────────┘                          │
└─────────────────────────────────────────────────────────────┘
```

## Prerequisites
- Docker Desktop installed and running
- At least 8GB RAM allocated to Docker
- 20GB free disk space

## Directory Structure

Create the following directories before starting:

```bash
mkdir -p data
mkdir -p resources
mkdir -p mapreduce-jars
mkdir -p hive-scripts
mkdir -p spark-scripts
```

## Starting the Environment

1. **Start all services:**
   ```bash
   docker-compose -f task2-docker-compose.yaml up -d
   ```

2. **Check service health:**
   ```bash
   docker-compose -f task2-docker-compose.yaml ps
   ```

3. **View logs:**
   ```bash
   docker-compose -f task2-docker-compose.yaml logs -f [service-name]
   ```

## Task 2 Requirements

### [1] Hadoop MapReduce Analysis

**Requirements:**
1. Calculate the total precipitation and mean temperature for each district per month over the past decade
2. Find the month and year with the highest total precipitation

**Steps:**
1. Compile your MapReduce Java code
2. Package as JAR file
3. Place JAR in `mapreduce-jars/` directory
4. Upload data to HDFS:
   ```bash
   docker exec -it namenode bash
   hdfs dfs -mkdir -p /user/input
   hdfs dfs -put /opt/data/weather_data.csv /user/input/
   ```
5. Run MapReduce job:
   ```bash
   hadoop jar /opt/mapreduce-jars/your-job.jar \
     com.yourpackage.MainClass \
     /user/input /user/output
   ```
6. View results:
   ```bash
   hdfs dfs -cat /user/output/part-r-00000
   ```

### [2] Hive/Pig Analysis

**Requirements:**
1. Rank top 10 most temperate cities (using temperature_2m_max)
2. Calculate average evapotranspiration for agricultural seasons by district

**Steps:**
1. Connect to HiveServer2:
   ```bash
   docker exec -it hive-server bash
   beeline -u jdbc:hive2://localhost:10000
   ```

2. Create external table:
   ```sql
   CREATE EXTERNAL TABLE weather_data (
     date STRING,
     district STRING,
     temperature_2m_max DOUBLE,
     temperature_2m_mean DOUBLE,
     precipitation_hours DOUBLE,
     evapotranspiration DOUBLE,
     -- add other columns
   )
   ROW FORMAT DELIMITED
   FIELDS TERMINATED BY ','
   STORED AS TEXTFILE
   LOCATION '/user/hive/warehouse/weather_data';
   ```

3. Load data:
   ```sql
   LOAD DATA INPATH '/user/input/weather_data.csv'
   INTO TABLE weather_data;
   ```

4. Run analysis queries (save in `hive-scripts/` directory)

### [3] Spark Analysis

**Requirements:**
1. Calculate percentage of months with shortwave radiation > 15MJ/m²
2. Calculate weekly maximum temperatures for hottest months

**Steps:**
1. Access Spark Master:
   ```bash
   docker exec -it spark-master bash
   ```

2. Start PySpark shell:
   ```bash
   pyspark --master spark://spark-master:7077
   ```

3. Or submit Spark job:
   ```bash
   spark-submit --master spark://spark-master:7077 \
     /opt/spark-scripts/your_analysis.py
   ```

4. Example PySpark code structure:
   ```python
   from pyspark.sql import SparkSession

   spark = SparkSession.builder \
       .appName("Task2Analysis") \
       .getOrCreate()

   # Read from HDFS
   df = spark.read.csv("hdfs://namenode:8020/user/input/weather_data.csv",
                       header=True, inferSchema=True)

   # Your analysis here

   spark.stop()
   ```

## Web UIs

Access the following web interfaces:

- **HDFS NameNode UI**: http://localhost:50070
- **Spark Master UI**: http://localhost:8080
- **Spark Worker 1 UI**: http://localhost:8081
- **Spark Worker 2 UI**: http://localhost:8082

## Data Format

Expected weather data columns:
- date
- district
- temperature_2m_max (°C)
- temperature_2m_mean (°C)
- precipitation_hours
- sunshine_duration
- shortwave_radiation (MJ/m²)
- evapotranspiration (mm)
- wind_speed
- wind_gusts_10m_max

## Useful Commands

### HDFS Operations
```bash
# List HDFS directories
docker exec -it namenode hdfs dfs -ls /

# Create directory
docker exec -it namenode hdfs dfs -mkdir -p /user/data

# Upload file
docker exec -it namenode hdfs dfs -put /opt/data/file.csv /user/data/

# Download file
docker exec -it namenode hdfs dfs -get /user/output/result.txt /opt/data/

# View file content
docker exec -it namenode hdfs dfs -cat /user/output/part-r-00000

# Remove directory
docker exec -it namenode hdfs dfs -rm -r /user/output
```

### Hive Operations
```bash
# Connect to Hive
docker exec -it hive-server beeline -u jdbc:hive2://localhost:10000

# Run Hive script
docker exec -it hive-server hive -f /opt/hive-scripts/analysis.hql
```

### Spark Operations
```bash
# Check Spark workers
docker exec -it spark-master curl http://spark-master:8080/json/

# Run PySpark interactively
docker exec -it spark-master pyspark --master spark://spark-master:7077

# Submit Spark job
docker exec -it spark-master spark-submit \
  --master spark://spark-master:7077 \
  /opt/spark-scripts/job.py
```

## Stopping the Environment

```bash
# Stop all services
docker-compose -f task2-docker-compose.yaml down

# Stop and remove volumes (WARNING: deletes all data)
docker-compose -f task2-docker-compose.yaml down -v
```

## Troubleshooting

### Services won't start
- Check Docker has enough resources (8GB+ RAM)
- Ensure ports are not in use: 50070, 8020, 9083, 10000, 8080, 7077

### HDFS connection issues
```bash
# Check NameNode status
docker exec -it namenode hdfs dfsadmin -report

# Format NameNode (only if needed, destroys data)
docker exec -it namenode hdfs namenode -format
```

### Hive metastore issues
```bash
# Reinitialize metastore
docker-compose -f task2-docker-compose.yaml restart hive-metastore-init
```

### Spark worker not connecting
```bash
# Check Spark Master logs
docker logs spark-master

# Restart workers
docker-compose -f task2-docker-compose.yaml restart spark-worker-1 spark-worker-2
```

## Task Submission Checklist

- [ ] MapReduce job completed with results
- [ ] Hive/Pig queries executed with outputs
- [ ] Spark analysis completed with results
- [ ] All code saved in respective directories
- [ ] Results documented in report
- [ ] Screenshots of Web UIs captured

## References

- Based on IIT Lab 3_4 (MapReduce), Lab 5 (Hive), and Lab 7 (Spark)
- Hadoop Documentation: https://hadoop.apache.org/docs/
- Hive Documentation: https://hive.apache.org/
- Spark Documentation: https://spark.apache.org/docs/latest/