-- Load the CSV files as SQLite tables before running these checks.
-- Expected tables: campaigns, ad_platform_daily, web_sessions_daily, orders,
-- fact_campaign_performance_daily.

-- Duplicate daily campaign grain in source extracts
SELECT report_date, campaign_id, COUNT(*) AS row_count
FROM ad_platform_daily GROUP BY 1, 2 HAVING COUNT(*) > 1;

SELECT session_date, campaign_id, COUNT(*) AS row_count
FROM web_sessions_daily GROUP BY 1, 2 HAVING COUNT(*) > 1;

-- Missing campaign references
SELECT a.campaign_id, COUNT(*) AS rows_without_dimension
FROM ad_platform_daily a LEFT JOIN campaigns c USING (campaign_id)
WHERE c.campaign_id IS NULL GROUP BY a.campaign_id;

-- Invalid or negative measures
SELECT * FROM ad_platform_daily
WHERE impressions < 0 OR clicks < 0 OR spend < 0 OR clicks > impressions;

SELECT * FROM orders WHERE order_revenue < 0 OR discount_amount < 0;

-- Nulls and unexpected campaign/date values
SELECT COUNT(*) AS missing_campaign_ids FROM ad_platform_daily WHERE campaign_id IS NULL;
SELECT MIN(report_date) AS first_day, MAX(report_date) AS last_day FROM ad_platform_daily;
