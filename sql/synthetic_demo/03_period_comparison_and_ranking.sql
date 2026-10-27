-- Advanced analysis examples (SQLite 3.25+ for window functions).
-- Period-over-period trend: compare each platform-month with its prior month.
WITH monthly AS (
    SELECT substr(report_date, 1, 7) AS month,
           platform,
           SUM(spend) AS spend,
           SUM(orders) AS orders,
           SUM(attributed_revenue) AS revenue
    FROM fact_campaign_performance_daily
    GROUP BY substr(report_date, 1, 7), platform
), period_metrics AS (
    SELECT month, platform, spend, orders, revenue,
           revenue / NULLIF(spend, 0) AS roas,
           spend / NULLIF(orders, 0) AS cpa,
           LAG(spend) OVER (PARTITION BY platform ORDER BY month) AS prior_spend,
           LAG(revenue) OVER (PARTITION BY platform ORDER BY month) AS prior_revenue,
           LAG(revenue / NULLIF(spend, 0)) OVER (PARTITION BY platform ORDER BY month) AS prior_roas
    FROM monthly
)
SELECT month, platform, spend, revenue, orders, roas, cpa,
       (spend - prior_spend) / NULLIF(prior_spend, 0) AS spend_mom_change,
       (revenue - prior_revenue) / NULLIF(prior_revenue, 0) AS revenue_mom_change,
       roas - prior_roas AS roas_point_change
FROM period_metrics
ORDER BY month, platform;

-- Dense ranking supports a fair tie-aware campaign leaderboard.
WITH campaign_totals AS (
    SELECT campaign_id, platform, SUM(spend) AS spend,
           SUM(orders) AS orders, SUM(attributed_revenue) AS revenue
    FROM fact_campaign_performance_daily
    GROUP BY campaign_id, platform
)
SELECT campaign_id, platform, spend, orders, revenue,
       revenue / NULLIF(spend, 0) AS roas,
       spend / NULLIF(orders, 0) AS cpa,
       DENSE_RANK() OVER (ORDER BY revenue / NULLIF(spend, 0) DESC) AS roas_rank,
       DENSE_RANK() OVER (ORDER BY spend / NULLIF(orders, 0) ASC) AS cpa_rank
FROM campaign_totals
ORDER BY roas_rank, cpa_rank;

-- Customer cohort summary: observed repeat behavior only within this dataset window.
WITH customer_first_order AS (
    SELECT customer_id, MIN(order_date) AS first_order_date
    FROM orders GROUP BY customer_id
), customer_orders AS (
    SELECT o.customer_id, f.first_order_date,
           substr(f.first_order_date, 1, 7) AS cohort_month,
           COUNT(DISTINCT o.order_id) AS observed_orders,
           SUM(o.order_revenue) AS observed_revenue
    FROM orders o JOIN customer_first_order f USING (customer_id)
    GROUP BY o.customer_id, f.first_order_date
)
SELECT cohort_month,
       COUNT(*) AS customers,
       SUM(CASE WHEN observed_orders > 1 THEN 1 ELSE 0 END) AS observed_repeat_customers,
       1.0 * SUM(CASE WHEN observed_orders > 1 THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0) AS observed_repeat_rate,
       AVG(observed_revenue) AS observed_revenue_per_customer
FROM customer_orders
GROUP BY cohort_month ORDER BY cohort_month;
