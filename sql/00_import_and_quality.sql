-- Import data/curated/real_bank_marketing/bank_marketing_contacts.csv into
-- SQLite as bank_marketing_contacts. The curated CSV is comma-delimited.
-- The upstream UCI source is semicolon-delimited.

-- Expected schema:
-- case_id, age, job, marital, education, contact, month, day_of_week,
-- campaign, pdays, previous, poutcome, subscribed

-- Overall source profile and response rate
SELECT COUNT(*) AS campaign_records,
       SUM(CASE WHEN subscribed = 'yes' THEN 1 ELSE 0 END) AS subscriptions,
       ROUND(1.0 * SUM(CASE WHEN subscribed = 'yes' THEN 1 ELSE 0 END) / COUNT(*), 4) AS response_rate
FROM bank_marketing_contacts;

-- Domain checks: expect zero rows
SELECT * FROM bank_marketing_contacts
WHERE age < 17 OR age > 100 OR campaign < 1 OR previous < 0
   OR (pdays <> 999 AND pdays < 0)
   OR subscribed NOT IN ('yes', 'no');

-- Check for blank values in the analysis fields
SELECT COUNT(*) AS blank_analysis_fields
FROM bank_marketing_contacts
WHERE job = '' OR contact = '' OR month = '' OR poutcome = '' OR subscribed = '';

-- Unknown is a documented category in this dataset, not a SQL NULL.
SELECT job, COUNT(*) AS records
FROM bank_marketing_contacts GROUP BY job ORDER BY records DESC;
