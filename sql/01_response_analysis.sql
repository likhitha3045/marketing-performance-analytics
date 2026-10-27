-- Response by communication channel. These are observational associations.
SELECT contact,
       COUNT(*) AS records,
       SUM(CASE WHEN subscribed = 'yes' THEN 1 ELSE 0 END) AS subscriptions,
       ROUND(1.0 * SUM(CASE WHEN subscribed = 'yes' THEN 1 ELSE 0 END) / COUNT(*), 4) AS response_rate
FROM bank_marketing_contacts
GROUP BY contact ORDER BY response_rate DESC;

-- Month categories are not a time series: exact year and date are absent.
SELECT month,
       COUNT(*) AS records,
       SUM(CASE WHEN subscribed = 'yes' THEN 1 ELSE 0 END) AS subscriptions,
       ROUND(1.0 * SUM(CASE WHEN subscribed = 'yes' THEN 1 ELSE 0 END) / COUNT(*), 4) AS response_rate
FROM bank_marketing_contacts
GROUP BY month ORDER BY records DESC;

-- Attempt-count buckets
WITH bucketed AS (
    SELECT CASE WHEN campaign = 1 THEN '1 contact'
                WHEN campaign BETWEEN 2 AND 3 THEN '2-3 contacts'
                WHEN campaign BETWEEN 4 AND 5 THEN '4-5 contacts'
                ELSE '6+ contacts' END AS attempt_band,
           subscribed
    FROM bank_marketing_contacts
)
SELECT attempt_band, COUNT(*) AS records,
       SUM(CASE WHEN subscribed = 'yes' THEN 1 ELSE 0 END) AS subscriptions,
       ROUND(1.0 * SUM(CASE WHEN subscribed = 'yes' THEN 1 ELSE 0 END) / COUNT(*), 4) AS response_rate
FROM bucketed GROUP BY attempt_band;

-- Response by previous campaign result and contact history
SELECT poutcome,
       COUNT(*) AS records,
       SUM(CASE WHEN subscribed = 'yes' THEN 1 ELSE 0 END) AS subscriptions,
       ROUND(1.0 * SUM(CASE WHEN subscribed = 'yes' THEN 1 ELSE 0 END) / COUNT(*), 4) AS response_rate
FROM bank_marketing_contacts
GROUP BY poutcome ORDER BY response_rate DESC;
