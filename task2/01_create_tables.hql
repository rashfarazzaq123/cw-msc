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