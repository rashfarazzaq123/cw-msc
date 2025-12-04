# -*- coding: utf-8 -*-
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, count, when, round as spark_round, split

# Create Spark session
spark = SparkSession.builder \
    .appName("Task 2.3.1 - Shortwave Radiation Analysis") \
    .master("spark://spark-master:7077") \
    .config("spark.sql.legacy.timeParserPolicy", "LEGACY") \
    .getOrCreate()

print("=" * 80)
print("Query 1: Percentage of shortwave radiation > 15MJ/m2 per month")
print("=" * 80)

# Read weather data from HDFS
weather_df = spark.read.option("header", "true").option("inferSchema", "true") \
    .csv("hdfs://namenode:8020/user/hive/warehouse/weather_data/weatherData.csv")

location_df = spark.read.option("header", "true").option("inferSchema", "true") \
    .csv("hdfs://namenode:8020/user/hive/warehouse/location_data/locationData.csv")

# Join to get city names
df = weather_df.join(location_df, "location_id")

# Extract year and month from date (format: M/D/YYYY)
df = df.withColumn("date_parts", split(col("date"), "/"))
df = df.withColumn("month", col("date_parts")[0].cast("int"))
df = df.withColumn("year", col("date_parts")[2].cast("int"))

# Get the radiation column name (adjust based on actual column name)
radiation_col = "shortwave_radiation_sum (MJ/m2)"

# Check if column exists, if not try alternative names
available_cols = df.columns
if radiation_col not in available_cols:
    # Try to find the radiation column
    for col_name in available_cols:
        if "radiation" in col_name.lower():
            radiation_col = col_name
            print(f"Using column: {radiation_col}")
            break

# Calculate percentage of radiation > 15MJ/m2 per month across all districts
monthly_radiation = df.groupBy("year", "month").agg(
    count(when(col(radiation_col) > 15, True)).alias("high_radiation_days"),
    count("*").alias("total_days")
).withColumn(
    "percentage",
    spark_round((col("high_radiation_days") / col("total_days") * 100), 2)
).orderBy("year", "month")

print("\nPercentage of shortwave radiation > 15MJ/m2 per month:")
monthly_radiation.show(50, truncate=False)

# Save results to HDFS
monthly_radiation.write.mode("overwrite") \
    .option("header", "true") \
    .csv("hdfs://namenode:8020/user/output/task2_radiation")

print("\nResults saved to: hdfs://namenode:8020/user/output/task2_radiation")

spark.stop()
