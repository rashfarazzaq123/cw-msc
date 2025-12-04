-- Query 2: Calculate average evapotranspiration for agricultural seasons by district
-- This query joins weather data with location data and extracts month from date

SELECT
    l.city_name as district,
    CASE
        WHEN CAST(SUBSTR(w.date_col, 1, LOCATE('/', w.date_col) - 1) AS INT) IN (9, 10, 11, 12, 1, 2, 3)
        THEN 'Maha Season (Sep-Mar)'
        WHEN CAST(SUBSTR(w.date_col, 1, LOCATE('/', w.date_col) - 1) AS INT) IN (4, 5, 6, 7, 8)
        THEN 'Yala Season (Apr-Aug)'
        ELSE 'Unknown'
    END as agricultural_season,
    SUBSTR(w.date_col, LOCATE('/', w.date_col, LOCATE('/', w.date_col) + 1) + 1) as year,
    AVG(w.evapotranspiration) as avg_evapotranspiration,
    COUNT(*) as days_count,
    MIN(w.evapotranspiration) as min_evapotranspiration,
    MAX(w.evapotranspiration) as max_evapotranspiration
FROM weather_data_raw w
JOIN location_data l ON w.location_id = l.location_id
WHERE w.evapotranspiration IS NOT NULL
GROUP BY
    l.city_name,
    CASE
        WHEN CAST(SUBSTR(w.date_col, 1, LOCATE('/', w.date_col) - 1) AS INT) IN (9, 10, 11, 12, 1, 2, 3)
        THEN 'Maha Season (Sep-Mar)'
        WHEN CAST(SUBSTR(w.date_col, 1, LOCATE('/', w.date_col) - 1) AS INT) IN (4, 5, 6, 7, 8)
        THEN 'Yala Season (Apr-Aug)'
        ELSE 'Unknown'
    END,
    SUBSTR(w.date_col, LOCATE('/', w.date_col, LOCATE('/', w.date_col) + 1) + 1)
ORDER BY district, year, agricultural_season;
