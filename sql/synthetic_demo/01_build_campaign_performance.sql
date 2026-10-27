-- Daily campaign fact. Aggregate each source independently before joining to
-- prevent row multiplication from orders and daily delivery records.
WITH ads AS (
    SELECT report_date, campaign_id, platform,
           SUM(impressions) AS impressions, SUM(clicks) AS clicks,
           SUM(spend) AS spend
    FROM ad_platform_daily
    GROUP BY report_date, campaign_id, platform
), web AS (
    SELECT session_date AS report_date, campaign_id,
           SUM(sessions) AS sessions, SUM(engaged_sessions) AS engaged_sessions
    FROM web_sessions_daily GROUP BY session_date, campaign_id
), sales AS (
    SELECT order_date AS report_date, campaign_id,
           COUNT(DISTINCT order_id) AS orders,
           SUM(order_revenue) AS attributed_revenue
    FROM orders GROUP BY order_date, campaign_id
)
SELECT a.report_date, a.campaign_id, a.platform,
       a.impressions, a.clicks, a.spend,
       COALESCE(w.sessions, 0) AS sessions,
       COALESCE(w.engaged_sessions, 0) AS engaged_sessions,
       COALESCE(s.orders, 0) AS orders,
       COALESCE(s.attributed_revenue, 0) AS attributed_revenue
FROM ads a
LEFT JOIN web w ON w.report_date = a.report_date AND w.campaign_id = a.campaign_id
LEFT JOIN sales s ON s.report_date = a.report_date AND s.campaign_id = a.campaign_id;
