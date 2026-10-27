# Marketing Performance & Growth Intelligence

**Portfolio project: synthetic paid-media data, with a separate public-data validation example.**

This project demonstrates campaign analysis using simulated ecommerce data. It includes a Python data pipeline, SQL analysis and quality checks, an interactive dashboard, and documented metric definitions. The synthetic records do not represent a real advertiser.

## Run the project (Windows PowerShell)

From this project folder:

```powershell
python src\build_dataset.py
python -m http.server 8765 --directory dashboard
```

Open **http://localhost:8765** in your browser. Stop the local server with `Ctrl+C`.

## Main dashboard modules

1. **Executive Overview:** date and channel filters, spend, attributed revenue, ROAS, orders, CPA, conversion rate, and prior-period comparisons.
2. **Campaign Performance:** channel comparison, searchable campaign table, sorting, and efficiency leaders.
3. **Funnel Analysis:** impressions to clicks to sessions to orders, with aggregate conversion rates.
4. **Customer and Retention:** observed cohorts, repeat purchase, new-customer CAC, and revenue per customer within the sample window.
5. **Budget Scenarios:** planned versus actual spend, guardrails, and an assumption-based reallocation sandbox.
6. **Insights and Quality:** calculated observations, data checks, metric definitions, and limitations.

## Public-data validation example

The [UCI Bank Marketing dataset](https://archive.ics.uci.edu/dataset/222/bank%2Bmarketing) is included as a separate historical example. Open **http://localhost:8765/historical.html**. It supports response-rate analysis; because it contains no paid-media spend or ecommerce revenue, it does not validate the synthetic project's ROAS or campaign rankings.

Prepare the UCI data with:

```powershell
python src\prepare_real_dataset.py
```

## Project files

- `data/synthetic_demo/`: synthetic paid-media source exports and curated campaign table.
- `dashboard/synthetic_data.js`: generated dashboard data.
- `data/source_extracts/real/`: public UCI source dataset.
- `data/curated/real_bank_marketing/`: prepared UCI analysis table.
- `sql/`: data-quality checks and campaign analysis queries.
- `documentation/`: source, metric, and validation methodology.

## Interpretation limits

ROAS is attributed order revenue divided by media spend; it is not profit or incremental lift. Customer metrics are synthetic and only observed within the sample window. The UCI data has response outcomes but no ad spend or sales revenue. Results are descriptive and do not establish causation.
