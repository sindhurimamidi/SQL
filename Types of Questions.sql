/* 1. Top N / Top N per Category */
WITH ranked_data AS (
    SELECT category, item, metric,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY metric DESC) AS rn
    FROM table_name
)
SELECT *
FROM ranked_data
WHERE rn <= N;

/* 2. Ratios / Percentages */
SELECT category,
       SUM(CASE WHEN condition THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS ratio
FROM table_name
GROUP BY category;

/* 3. Data Categorization */
SELECT user_id,
       CASE 
           WHEN amount < 100 THEN 'Low'
           WHEN amount BETWEEN 100 AND 500 THEN 'Medium'
           ELSE 'High'
       END AS spending_category
FROM transactions;

/* 4. Time Duration */
SELECT user_id,
       DATEDIFF(day, start_date, end_date) AS duration_days
FROM table_name;

/* 5. Moving Averages / Rolling Metrics */
SELECT date,
       AVG(metric) OVER (ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS moving_avg_7d
FROM table_name;

/* 6. Median / Percentiles */
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY amount) AS median_amount
FROM transactions;

/* 7. Status Change / Event Tracking */
SELECT user_id, event_date, status,
       LAG(status) OVER (PARTITION BY user_id ORDER BY event_date) AS prev_status
FROM user_events;

/* 8. WoW / MoM / YoY Analysis */
SELECT DATE_TRUNC('week', order_date) AS week,
       SUM(amount) AS weekly_sales,
       SUM(amount) - LAG(SUM(amount)) OVER (ORDER BY DATE_TRUNC('week', order_date)) AS WoW_change
FROM orders
GROUP BY week
ORDER BY week;

/* 9. Ads / Campaign Performance */
SELECT campaign_id,
       SUM(clicks) * 1.0 / SUM(impressions) AS ctr,
       SUM(conversions) * 1.0 / SUM(clicks) AS conversion_rate
FROM ads_data
GROUP BY campaign_id;

/* 10. Social / Friend Requests */
SELECT user_id,
       COUNT(*) AS pending_requests
FROM friend_requests
WHERE status = 'pending'
GROUP BY user_id;

/* 11. Average Duration Between Visits */
WITH visit_diff AS (
    SELECT user_id,
           visit_date,
           DATEDIFF(day, LAG(visit_date) OVER (PARTITION BY user_id ORDER BY visit_date), visit_date) AS days_between
    FROM visits
)
SELECT user_id,
       AVG(days_between) AS avg_days_between_visits
FROM visit_diff
GROUP BY user_id;

