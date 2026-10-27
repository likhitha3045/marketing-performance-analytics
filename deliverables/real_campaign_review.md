# Historical campaign response review

**Dataset:** UCI Bank Marketing `bank-additional-full.csv` · **Records:** 41,188 · **Window described by source:** May 2008–November 2010

## Executive summary

The file records 4,640 term-deposit subscriptions, an overall response rate of **11.27%**. The best descriptive response was among records whose previous campaign outcome was successful (**65.11%**, 894 of 1,373). Cellular contacts had a **14.74%** response rate (3,853 of 26,144) compared with **5.23%** for telephone contacts (787 of 15,044).

## Findings

| Comparison | Records | Subscriptions | Response rate |
|---|---:|---:|---:|
| Overall | 41,188 | 4,640 | 11.27% |
| Cellular | 26,144 | 3,853 | 14.74% |
| Telephone | 15,044 | 787 | 5.23% |
| Previous campaign success | 1,373 | 894 | 65.11% |
| Previous campaign failure | 4,252 | 605 | 14.23% |
| No prior campaign outcome | 35,563 | 3,141 | 8.83% |

Observed response also declines across current-campaign contact-count bands: **13.04%** for one contact (2,300/17,642), **11.22%** for two to three (1,785/15,911), **8.68%** for four to five (369/4,250), and **5.49%** for six or more (186/3,385). This is an association; people receiving more calls may already be less likely to respond.

The month field is categorical and has no year. March, December, September, and October show high sample response rates, but their record counts are much smaller than May's. Do not describe this as a seasonal or year-over-year effect.

## Recommended next steps

1. Review whether a controlled channel test can separate contact-method effects from differences in who was reached.
2. Treat prior successful campaign response as a useful operational segment to investigate, then confirm contact permissions and recency before recontact.
3. Investigate whether repeated calls are productive. Use a randomized holdout or call-policy experiment before reducing follow-up based on the observed pattern.
4. Request campaign cost and call-center effort data before making an efficiency or budget recommendation.

## Limits

The source has no spend, revenue, exact contact dates, or customer ID. It supports response-rate analysis only; it cannot support ROAS, CPA, profitability, customer-level retention, or causal conclusions. `duration` is excluded because it is post-contact information and can leak the known outcome into a predictive model.
