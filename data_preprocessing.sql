-- Write your query here
-- Questions & Queries for app_t:

-- [1] How many rows do we have?

SELECT COUNT(*) FROM app_t;

-- [2] How many unique applications do we have?

SELECT COUNT(DISTINCT app_id) FROM app_t;

-- [3] How many unique app categories do we have?

SELECT COUNT(DISTINCT app_category) FROM app_t;

-- [4] How many free and paid apps do we have?

SELECT free_or_paid, COUNT(DISTINCT app_id) no_of_apps
FROM app_t
GROUP BY free_or_paid;

-- [5] Let’s check to see if there are any duplicates in the table

SELECT app_id, COUNT(*)
FROM app_t
GROUP BY app_id
HAVING COUNT(*) > 1;

-- Questions & Queries for revenue_t:

-- [1] How many weeks of data do we have?

SELECT COUNT(DISTINCT updated_date) FROM revenue_t;

-- [2] How many apps support advertisements?

SELECT COUNT(DISTINCT app_id) FROM revenue_t WHERE adv_supported = 1;

-- [3] What is the total revenue across weeks?

SELECT updated_date, SUM(adv_revenue) revenue
FROM revenue_t
GROUP BY 1;

-- [4] What are the top five apps with the highest average screen time?

SELECT app_id, MAX(average_screen_time)
FROM revenue_t
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- [5] Which of the top five apps has the highest average number of installs?

SELECT app_id, MAX(number_of_installs)
FROM revenue_t
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- [6] Check to see if there are any duplicate rows in the revenue_t table.

SELECT app_id, updated_date, COUNT(*)
FROM revenue_t
GROUP BY 1,2
HAVING COUNT(*) > 1;

-- Data Pre-processing:

SELECT
    a.app_id,
    a.app_name,
    TRIM(REPLACE(a.app_category, '_', ' ')) AS app_category,
    REPLACE(a.app_size_in_mb, 'M', '') AS app_size_in_mb,
    a.free_or_paid,
    REPLACE(a.price_in_usd, '$', '') AS price_in_usd,
    a.content_rating,
    r.number_of_installs,
    r.average_screen_time,
    r.adv_supported,
    r.active_users,
    r.no_of_short_ads_per_hour,
    r.no_of_long_ads_per_hour,
    r.adv_revenue,
    r.updated_date,
    CASE
        WHEN r.average_screen_time >= 1 AND r.average_screen_time <= 50 THEN 'Low'
        WHEN r.average_screen_time > 50 AND r.average_screen_time <= 200 THEN 'Medium'
        ELSE 'High'
    END AS screentime_category
FROM
    app_t AS a
LEFT JOIN
    revenue_t AS r ON r.app_id = a.app_id
WHERE
    r.adv_supported = 1
GROUP BY
    a.app_id, a.app_name, a.app_category, a.app_size_in_mb, a.free_or_paid, a.price_in_usd, a.content_rating;
