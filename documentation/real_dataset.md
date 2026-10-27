# Real historical dataset

## Source

This project uses the **Bank Marketing** dataset from the [UCI Machine Learning Repository](https://archive.ics.uci.edu/dataset/222/bank%2Bmarketing), specifically `bank-additional-full.csv` (41,188 records). UCI describes it as direct telephone marketing by a Portuguese banking institution. The dataset is licensed CC BY 4.0.

Citation: Moro, S., Rita, P., & Cortez, P. (2014). *Bank Marketing* [Dataset]. UCI Machine Learning Repository. https://doi.org/10.24432/C5K306.

## What a row means

One row is a campaign contact case with client attributes, contact context, current-campaign contact count, prior campaign context, and whether the person subscribed to a term deposit (`subscribed = yes/no`). The source has no customer identifier, spend, impressions, order value, or profit.

## Project questions

- What is the overall subscription response rate?
- How does response differ by contact method and month category?
- How does the observed response rate vary with the number of contacts during a campaign?
- How does previous campaign outcome relate to current subscription?
- What quality and interpretation limits should a decision-maker know?

## Metric definitions

- **Subscriptions:** records where `subscribed = yes`.
- **Response rate:** subscriptions divided by campaign records.
- **Current campaign contacts:** the `campaign` field, a count of calls made to a client during the current campaign (includes the last contact).
- **Prior contact:** `pdays = 999` means the client was not previously contacted; otherwise it is days since a previous contact.
- **Prior outcome:** `poutcome` describes the outcome of the previous campaign.

## Important limits

- This is historical real data, not live data.
- The source is described as spanning May 2008 to November 2010, but this CSV has month and weekday categories and no exact date or year. Month charts are category comparisons, not a chronological trend.
- Do not calculate ROAS, CPA, CAC, revenue, or profit: their required fields are absent.
- `duration` is intentionally excluded from analysis because it is only known after a call and can leak outcome information into a predictive model.
- Response-rate differences are observational. They do not prove that contact channel, frequency, month, or client characteristics caused a subscription.
- No customer identifier is supplied, so deduplication and customer-level retention cannot be calculated reliably.
- Demographics are shown only as descriptive context, not as targeting recommendations.
