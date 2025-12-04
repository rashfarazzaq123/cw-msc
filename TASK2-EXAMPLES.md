# Task 2 - Code Examples and Templates

## Task 2.1 - MapReduce Examples

### Mapper Example (PrecipitationMapper.java)
```java
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;
import java.io.IOException;

public class PrecipitationMapper extends Mapper<LongWritable, Text, Text, Text> {

    @Override
    public void map(LongWritable key, Text value, Context context)
            throws IOException, InterruptedException {

        // Skip header
        if (key.get() == 0) return;

        String line = value.toString();
        String[] fields = line.split(",");

        if (fields.length >= 4) {
            String date = fields[0];          // e.g., "2020-01-15"
            String district = fields[1];       // e.g., "Colombo"
            String precipitation = fields[2];  // total precipitation
            String temperature = fields[3];    // mean temperature

            // Extract year and month from date
            String[] dateParts = date.split("-");
            String year = dateParts[0];
            String month = dateParts[1];

            // Key: District-Year-Month
            String compositeKey = district + "-" + year + "-" + month;

            // Value: precipitation,temperature
            String compositeValue = precipitation + "," + temperature;

            context.write(new Text(compositeKey), new Text(compositeValue));
        }
    }
}
```

### Reducer Example (PrecipitationReducer.java)
```java
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;
import java.io.IOException;

public class PrecipitationReducer extends Reducer<Text, Text, Text, Text> {

    @Override
    public void reduce(Text key, Iterable<Text> values, Context context)
            throws IOException, InterruptedException {

        double totalPrecipitation = 0.0;
        double sumTemperature = 0.0;
        int count = 0;

        for (Text value : values) {
            String[] fields = value.toString().split(",");
            totalPrecipitation += Double.parseDouble(fields[0]);
            sumTemperature += Double.parseDouble(fields[1]);
            count++;
        }

        double meanTemperature = sumTemperature / count;

        // Output format: District-Year-Month -> Total_Precipitation, Mean_Temperature
        String result = String.format("%.2f,%.2f", totalPrecipitation, meanTemperature);

        context.write(key, new Text(result));
    }
}
```

### Driver Example (WeatherAnalysisDriver.java)
```java
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class WeatherAnalysisDriver {

    public static void main(String[] args) throws Exception {

        if (args.length != 2) {
            System.err.println("Usage: WeatherAnalysisDriver <input path> <output path>");
            System.exit(-1);
        }

        Configuration conf = new Configuration();
        Job job = Job.getInstance(conf, "Weather Analysis");

        job.setJarByClass(WeatherAnalysisDriver.class);
        job.setMapperClass(PrecipitationMapper.class);
        job.setReducerClass(PrecipitationReducer.class);

        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(Text.class);

        FileInputFormat.addInputPath(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));

        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }
}
```

### Compile and Run
```bash
# Compile
javac -classpath `hadoop classpath` *.java
jar cf weather-analysis.jar *.class

# Copy to container
docker cp weather-analysis.jar namenode:/opt/mapreduce-jars/

# Run
docker exec -it namenode bash
hadoop jar /opt/mapreduce-jars/weather-analysis.jar \
  WeatherAnalysisDriver \
  /user/input/weather_data.csv \
  /user/output/task2_1
```

---

## Task 2.2 - Hive Examples

### Create Tables (hive-scripts/create_tables.hql)
```sql
-- Drop existing tables if they exist
DROP TABLE IF EXISTS weather_data;

-- Create external table for weather data
CREATE EXTERNAL TABLE weather_data (
    date_col STRING,
    district STRING,
    temperature_2m_max DOUBLE,
    temperature_2m_mean DOUBLE,
    temperature_2m_min DOUBLE,
    precipitation_hours DOUBLE,
    precipitation_sum DOUBLE,
    rain_sum DOUBLE,
    snowfall_sum DOUBLE,
    sunshine_duration DOUBLE,
    daylight_duration DOUBLE,
    wind_speed_10m_max DOUBLE,
    wind_gusts_10m_max DOUBLE,
    wind_direction_10m_dominant INT,
    shortwave_radiation_sum DOUBLE,
    evapotranspiration DOUBLE
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/hive/warehouse/weather_data'
TBLPROPERTIES ('skip.header.line.count'='1');

-- Create table for location data if needed
CREATE EXTERNAL TABLE location_data (
    district STRING,
    latitude DOUBLE,
    longitude DOUBLE,
    elevation DOUBLE
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/hive/warehouse/location_data'
TBLPROPERTIES ('skip.header.line.count'='1');
```

### Query 1: Top 10 Most Temperate Cities (hive-scripts/top_temperate_cities.hql)
```sql
-- Top 10 most temperate cities (highest average max temperature)
SELECT
    district,
    AVG(temperature_2m_max) as avg_max_temperature,
    COUNT(*) as record_count
FROM weather_data
WHERE temperature_2m_max IS NOT NULL
GROUP BY district
ORDER BY avg_max_temperature DESC
LIMIT 10;
```

### Query 2: Average Evapotranspiration by Season (hive-scripts/evapotranspiration_season.hql)
```sql
-- Calculate average evapotranspiration for agricultural seasons
SELECT
    district,
    CASE
        WHEN CAST(SUBSTR(date_col, 6, 2) AS INT) BETWEEN 9 AND 12
             OR CAST(SUBSTR(date_col, 6, 2) AS INT) BETWEEN 1 AND 3
        THEN 'September-March'
        ELSE 'April-August'
    END as agricultural_season,
    SUBSTR(date_col, 1, 4) as year,
    AVG(evapotranspiration) as avg_evapotranspiration
FROM weather_data
WHERE evapotranspiration IS NOT NULL
GROUP BY
    district,
    CASE
        WHEN CAST(SUBSTR(date_col, 6, 2) AS INT) BETWEEN 9 AND 12
             OR CAST(SUBSTR(date_col, 6, 2) AS INT) BETWEEN 1 AND 3
        THEN 'September-March'
        ELSE 'April-August'
    END,
    SUBSTR(date_col, 1, 4)
ORDER BY district, year, agricultural_season;
```

### Run Hive Scripts
```bash
# Load data first
docker exec -it namenode hdfs dfs -put /opt/data/weather_data.csv /user/hive/warehouse/weather_data/

# Execute Hive scripts
docker exec -it hive-server beeline -u jdbc:hive2://localhost:10000 \
  -f /opt/hive-scripts/create_tables.hql

docker exec -it hive-server beeline -u jdbc:hive2://localhost:10000 \
  -f /opt/hive-scripts/top_temperate_cities.hql

docker exec -it hive-server beeline -u jdbc:hive2://localhost:10000 \
  -f /opt/hive-scripts/evapotranspiration_season.hql
```

---

## Task 2.3 - Spark Examples

### PySpark Script Example (spark-scripts/radiation_analysis.py)
```python
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, month, year, when, count, sum as _sum

def analyze_radiation():
    # Create Spark session
    spark = SparkSession.builder \
        .appName("Task2.3 - Radiation Analysis") \
        .master("spark://spark-master:7077") \
        .getOrCreate()

    # Read data from HDFS
    df = spark.read.csv(
        "hdfs://namenode:8020/user/input/weather_data.csv",
        header=True,
        inferSchema=True
    )

    # Question 1: Percentage of total shortwave radiation > 15MJ/m² per month
    print("=" * 70)
    print("Question 1: Percentage of shortwave radiation > 15MJ/m² per month")
    print("=" * 70)

    radiation_analysis = df.groupBy(
        year(col("date_col")).alias("year"),
        month(col("date_col")).alias("month"),
        col("district")
    ).agg(
        count(when(col("shortwave_radiation_sum") > 15, True)).alias("high_radiation_days"),
        count("*").alias("total_days")
    ).withColumn(
        "percentage",
        (col("high_radiation_days") / col("total_days") * 100)
    ).orderBy("year", "month", "district")

    radiation_analysis.show(50)

    # Save results
    radiation_analysis.write.mode("overwrite").csv(
        "hdfs://namenode:8020/user/output/radiation_analysis"
    )

    spark.stop()

if __name__ == "__main__":
    analyze_radiation()
```

### PySpark Script Example (spark-scripts/weekly_temperature.py)
```python
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, weekofyear, max as _max, month, year
from pyspark.sql.window import Window

def analyze_weekly_temperature():
    spark = SparkSession.builder \
        .appName("Task2.3 - Weekly Temperature Analysis") \
        .master("spark://spark-master:7077") \
        .getOrCreate()

    df = spark.read.csv(
        "hdfs://namenode:8020/user/input/weather_data.csv",
        header=True,
        inferSchema=True
    )

    # Question 2: Weekly maximum temperatures for hottest months
    print("=" * 70)
    print("Question 2: Weekly Maximum Temperatures for Hottest Months")
    print("=" * 70)

    # First, find the hottest months
    monthly_avg = df.groupBy(
        year(col("date_col")).alias("year"),
        month(col("date_col")).alias("month")
    ).agg(
        _max(col("temperature_2m_max")).alias("max_temp")
    )

    # Get top hottest months
    hottest_months = monthly_avg.orderBy(col("max_temp").desc()).limit(3)

    print("Hottest months identified:")
    hottest_months.show()

    # Calculate weekly max temperature for these hottest months
    df_with_week = df.withColumn("year", year(col("date_col"))) \
                     .withColumn("month", month(col("date_col"))) \
                     .withColumn("week", weekofyear(col("date_col")))

    # Join with hottest months
    weekly_temp = df_with_week.join(
        hottest_months,
        ["year", "month"]
    ).groupBy(
        col("year"),
        col("month"),
        col("week"),
        col("district")
    ).agg(
        _max(col("temperature_2m_max")).alias("weekly_max_temp")
    ).orderBy("year", "month", "week", "district")

    weekly_temp.show(100)

    # Save results
    weekly_temp.write.mode("overwrite").csv(
        "hdfs://namenode:8020/user/output/weekly_temperature"
    )

    spark.stop()

if __name__ == "__main__":
    analyze_weekly_temperature()
```

### Interactive PySpark Example
```python
# Start PySpark shell
docker exec -it spark-master pyspark --master spark://spark-master:7077

# Inside PySpark shell:
from pyspark.sql.functions import col, avg, count

# Read data
df = spark.read.csv("hdfs://namenode:8020/user/input/weather_data.csv",
                    header=True, inferSchema=True)

# Quick exploration
df.printSchema()
df.show(5)
df.describe().show()

# Example analysis
df.groupBy("district") \
  .agg(avg("temperature_2m_mean").alias("avg_temp")) \
  .orderBy(col("avg_temp").desc()) \
  .show()
```

### Submit Spark Job
```bash
# Copy script to container
docker cp spark-scripts/radiation_analysis.py spark-master:/opt/spark-scripts/

# Submit job
docker exec -it spark-master spark-submit \
  --master spark://spark-master:7077 \
  --driver-memory 2g \
  --executor-memory 2g \
  /opt/spark-scripts/radiation_analysis.py
```

---

## Data Loading Examples

### Load Data to HDFS
```bash
# Create directories
docker exec -it namenode hdfs dfs -mkdir -p /user/input
docker exec -it namenode hdfs dfs -mkdir -p /user/hive/warehouse

# Copy data file to namenode container
docker cp data/weather_data.csv namenode:/tmp/

# Load to HDFS
docker exec -it namenode hdfs dfs -put /tmp/weather_data.csv /user/input/

# Verify
docker exec -it namenode hdfs dfs -ls /user/input/
```

### Load Data to Hive
```bash
# After creating Hive tables, load data
docker exec -it hive-server beeline -u jdbc:hive2://localhost:10000 -e \
  "LOAD DATA INPATH '/user/input/weather_data.csv' INTO TABLE weather_data;"
```

---

## Testing Your Setup

### Quick Test Script
```bash
#!/bin/bash

echo "Testing Task 2 Environment..."

# Test HDFS
echo "1. Testing HDFS..."
docker exec namenode hdfs dfs -ls / && echo "✓ HDFS working" || echo "✗ HDFS failed"

# Test Hive
echo "2. Testing Hive..."
docker exec hive-server beeline -u jdbc:hive2://localhost:10000 -e "SHOW DATABASES;" && echo "✓ Hive working" || echo "✗ Hive failed"

# Test Spark
echo "3. Testing Spark..."
docker exec spark-master spark-submit --version && echo "✓ Spark working" || echo "✗ Spark failed"

echo "Testing complete!"
```