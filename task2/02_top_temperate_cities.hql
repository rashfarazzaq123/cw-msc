-- Query 1: Rank top 10 most temperate cities based on average maximum temperature
-- This query joins weather data with location data to get city names

SELECT
    l.city_name as district,
    AVG(w.temperature_2m_max) as avg_max_temperature,
    COUNT(*) as total_records,
    MIN(w.temperature_2m_max) as min_temp,
    MAX(w.temperature_2m_max) as max_temp
FROM weather_data_raw w
JOIN location_data l ON w.location_id = l.location_id
WHERE w.temperature_2m_max IS NOT NULL
GROUP BY l.city_name
ORDER BY avg_max_temperature DESC
LIMIT 10;
