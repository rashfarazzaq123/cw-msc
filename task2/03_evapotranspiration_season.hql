-- Calculate average evapotranspiration for agricultural seasons by district
SELECT
    district,
    CASE
        WHEN CAST(SUBSTR(date_col, 6, 2) AS INT) IN (9, 10, 11, 12, 1, 2, 3)
        THEN 'Maha Season (Sep-Mar)'
        WHEN CAST(SUBSTR(date_col, 6, 2) AS INT) IN (4, 5, 6, 7, 8)
        THEN 'Yala Season (Apr-Aug)'
        ELSE 'Unknown'
    END as agricultural_season,
    SUBSTR(date_col, 1, 4) as year,
    AVG(evapotranspiration) as avg_evapotranspiration,
    COUNT(*) as days_count,
    MIN(evapotranspiration) as min_evapotranspiration,
    MAX(evapotranspiration) as max_evapotranspiration
FROM weather_data
WHERE evapotranspiration IS NOT NULL
GROUP BY
    district,
    CASE
        WHEN CAST(SUBSTR(date_col, 6, 2) AS INT) IN (9, 10, 11, 12, 1, 2, 3)
        THEN 'Maha Season (Sep-Mar)'
        WHEN CAST(SUBSTR(date_col, 6, 2) AS INT) IN (4, 5, 6, 7, 8)
        THEN 'Yala Season (Apr-Aug)'
        ELSE 'Unknown'
    END,
    SUBSTR(date_col, 1, 4)
ORDER BY district, year, agricultural_season;