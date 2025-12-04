-- Rank top 10 most temperate cities based on average maximum temperature
SELECT
    district,
    AVG(temperature_2m_max) as avg_max_temperature,
    COUNT(*) as total_records,
    MIN(temperature_2m_max) as min_temp,
    MAX(temperature_2m_max) as max_temp
FROM weather_data
WHERE temperature_2m_max IS NOT NULL
GROUP BY district
ORDER BY avg_max_temperature DESC
LIMIT 10;