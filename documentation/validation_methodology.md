# Public-data validation methodology

## Why this public dataset is included

The paid-media ecommerce dataset is synthetic so the dashboard can demonstrate spend, orders, and attributed revenue without implying access to a real company's data. The [UCI Bank Marketing dataset](https://archive.ics.uci.edu/dataset/222/bank%2Bmarketing) supplies independent real historical campaign outcome records for a second calculation check.

## Validation result

The UCI `bank-additional-full.csv` source has **41,188 campaign records** and **4,640 subscriptions**, so the overall subscription response rate is **4,640 ÷ 41,188 = 11.27%**. This result is also shown in the optional `dashboard/historical.html` view.

## What is checked

- Aggregate the positive outcomes across all records.
- Divide by the total eligible records to produce a weighted response rate.
- Recompute the same numerator/denominator pattern for segments such as contact method, month category, and prior outcome.
- Avoid averaging segment percentages to produce an overall rate.

The main synthetic dashboard follows the same aggregation principle for orders/sessions, spend/clicks, and revenue/spend. This validates the analysis method and metric implementation pattern.

## What is not checked

The public dataset is telephone marketing for term-deposit subscriptions. It does not include paid advertising impressions, clicks, media spend, ecommerce orders, order value, or profit. Its response rate is **not the same metric** as an ecommerce session conversion rate, and it cannot independently validate ROAS, CPA, campaign efficiency rankings, or simulated findings. The two dashboards must remain clearly separated.

## Reproduce with SQL

Load `data/curated/real_bank_marketing/bank_marketing_contacts.csv` into SQLite as `bank_marketing_contacts`, then run `sql/00_import_and_quality.sql`. The expected source total is 41,188 and the expected positive outcome count is 4,640. Source credit and limits are documented in `documentation/real_dataset.md`.
