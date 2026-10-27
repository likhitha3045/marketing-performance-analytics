-- Campaign-level scorecard. Rates are calculated from summed numerators and
-- denominators, never averaged from daily rates.
SELECT campaign_id, platform,
       SUM(impressions) AS impressions,
       SUM(clicks) AS clicks,
       ROUND(SUM(spend), 2) AS spend,
       SUM(sessions) AS sessions,
       SUM(orders) AS attributed_orders,
       ROUND(SUM(attributed_revenue), 2) AS attributed_revenue,
       ROUND(1.0 * SUM(clicks) / NULLIF(SUM(impressions), 0), 4) AS ctr,
       ROUND(1.0 * SUM(orders) / NULLIF(SUM(sessions), 0), 4) AS session_to_order_rate,
       ROUND(SUM(spend) / NULLIF(SUM(clicks), 0), 2) AS cpc,
       ROUND(SUM(spend) / NULLIF(SUM(orders), 0), 2) AS cpa,
       ROUND(SUM(attributed_revenue) / NULLIF(SUM(spend), 0), 2) AS roas
FROM fact_campaign_performance_daily
GROUP BY campaign_id, platform
ORDER BY roas DESC;

-- Monthly trend for pacing and performance review
SELECT substr(report_date, 1, 7) AS month, platform,
       ROUND(SUM(spend), 2) AS spend,
       SUM(orders) AS orders,
       ROUND(SUM(attributed_revenue), 2) AS attributed_revenue,
       ROUND(SUM(attributed_revenue) / NULLIF(SUM(spend), 0), 2) AS roas
FROM fact_campaign_performance_daily
GROUP BY month, platform ORDER BY month, platform;
