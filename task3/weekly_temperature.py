from pyspark.sql import SparkSession
from pyspark.sql.functions import col, year, month, weekofyear, max as spark_max, avg
from pyspark.sql.functions import split

# Create Spark session
spark = SparkSession.builder \
    .appName("Task 2.3.2 - Weekly Maximum Temperature") \
    .master("spark://spark-master:7077") \
    .config("spark.sql.legacy.timeParserPolicy", "LEGACY") \
    .getOrCreate()

print("=" * 80)
print("Query 2: Weekly maximum temperatures for the hottest months")
print("=" * 80)

# Read weather data from HDFS
weather_df = spark.read.option("header", "true").option("inferSchema", "true") \
    .csv("hdfs://namenode:8020/user/hive/warehouse/weather_data/weatherData.csv")

location_df = spark.read.option("header", "true").option("inferSchema", "true") \
    .csv("hdfs://namenode:8020/user/hive/warehouse/location_data/locationData.csv")

# Join to get city names
df = weather_df.join(location_df, "location_id")

# Parse date (M/D/YYYY format)
df = df.withColumn("date_parts", split(col("date"), "/"))
df = df.withColumn("month_num", col("date_parts")[0].cast("int"))
df = df.withColumn("day", col("date_parts")[1].cast("int"))
df = df.withColumn("year_num", col("date_parts")[2].cast("int"))

# Create proper date for week calculation
from pyspark.sql.functions import concat_ws, to_date, lpad
df = df.withColumn("date_formatted", 
    concat_ws("-", 
        col("year_num"),
        lpad(col("month_num"), 2, "0"),
        lpad(col("day"), 2, "0")
    )
)
df = df.withColumn("date_proper", to_date(col("date_formatted"), "yyyy-MM-dd"))
df = df.withColumn("week_of_year", weekofyear(col("date_proper")))

# Step 1: Find the hottest months (by average max temperature)
monthly_avg = df.groupBy("year_num", "month_num").agg(
    avg(col("temperature_2m_max (°C)")).alias("avg_max_temp")
).orderBy(col("avg_max_temp").desc())

print("\nTop 5 Hottest Months:")
hottest_months = monthly_avg.limit(5)
hottest_months.show()

# Step 2: Get weekly max temperatures for these hottest months
hottest_months_list = hottest_months.select("year_num", "month_num").collect()

# Filter data for hottest months
from pyspark.sql.functions import lit
hottest_filter = None
for row in hottest_months_list:
    condition = (col("year_num") == row["year_num"]) & (col("month_num") == row["month_num"])
    if hottest_filter is None:
        hottest_filter = condition
    else:
        hottest_filter = hottest_filter | condition

df_hottest = df.filter(hottest_filter)

# Calculate weekly maximum temperatures
weekly_max_temp = df_hottest.groupBy(
    "city_name",
    "year_num",
    "month_num",
    "week_of_year"
).agg(
    spark_max(col("temperature_2m_max (°C)")).alias("weekly_max_temp")
).orderBy("year_num", "month_num", "week_of_year", "city_name")

print("\nWeekly Maximum Temperatures for Hottest Months:")
weekly_max_temp.show(100, truncate=False)

# Save results to HDFS
weekly_max_temp.write.mode("overwrite") \
    .option("header", "true") \
    .csv("hdfs://namenode:8020/user/output/task2_weekly_temp")

print("\n✓ Results saved to: hdfs://namenode:8020/user/output/task2_weekly_temp")

spark.stop()