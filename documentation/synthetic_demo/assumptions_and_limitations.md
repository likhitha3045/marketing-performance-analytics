# Assumptions and limitations

- This is synthetic demonstration data, not a real company dataset.
- An order's campaign ID is treated as its last-touch attribution. The dataset does not model cross-device journeys, view-through conversions, or organic assists.
- Revenue is gross order value. Product margin, refunds, shipping, taxes, and media fees are not available, so ROAS is not profit or contribution margin.
- Ad platform reported conversions may differ from ecommerce orders; they are included as an independent platform field and excluded from order-based CPA/ROAS.
- There is no randomized holdout or incrementality experiment. Performance comparisons are descriptive and do not prove advertising caused sales.
- The generated dataset is intentionally regularized for a portfolio walkthrough; real exports often have timezone mismatches, late-arriving data, campaign naming drift, and missing IDs.
