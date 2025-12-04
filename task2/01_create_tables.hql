-- Drop existing tables if they exist
DROP TABLE IF EXISTS weather_data_raw;
DROP TABLE IF EXISTS location_data;

-- Create table for location data
CREATE EXTERNAL TABLE location_data (
    location_id INT,
    latitude DOUBLE,
    longitude DOUBLE,
    elevation DOUBLE,
    utc_offset_seconds INT,
    timezone STRING,
    timezone_abbreviation STRING,
    city_name STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/hive/warehouse/location_data'
TBLPROPERTIES ('skip.header.line.count'='1');

-- Create table for weather data
CREATE EXTERNAL TABLE weather_data_raw (
    location_id INT,
    date_col STRING,
    weather_code INT,
    temperature_2m_max DOUBLE,
    temperature_2m_min DOUBLE,
    temperature_2m_mean DOUBLE,
    apparent_temperature_max DOUBLE,
    apparent_temperature_min DOUBLE,
    apparent_temperature_mean DOUBLE,
    daylight_duration DOUBLE,
    sunshine_duration DOUBLE,
    precipitation_sum DOUBLE,
    rain_sum DOUBLE,
    precipitation_hours DOUBLE,
    wind_speed_10m_max DOUBLE,
    wind_gusts_10m_max DOUBLE,
    wind_direction_10m_dominant INT,
    shortwave_radiation_sum DOUBLE,
    evapotranspiration DOUBLE,
    sunrise STRING,
    sunset STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/hive/warehouse/weather_data'
TBLPROPERTIES ('skip.header.line.count'='1');
