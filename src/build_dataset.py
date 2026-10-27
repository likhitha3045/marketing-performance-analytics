"""Generate a reproducible, synthetic marketing analytics case study."""
from __future__ import annotations

import csv
import random
from collections import defaultdict
from datetime import date, timedelta
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "data" / "synthetic_demo" / "source_extracts"
CURATED = ROOT / "data" / "synthetic_demo" / "curated"
START, END = date(2025, 1, 1), date(2025, 6, 30)
RNG = random.Random(71)

CAMPAIGNS = [
    {"campaign_id": "META_PROSPECTING_US", "campaign_name": "US Prospecting | Broad", "platform": "Meta", "objective": "Purchase", "audience": "Prospecting", "region": "US", "daily_budget": 900, "base_cpc": 1.18, "base_cvr": .031, "aov": 86},
    {"campaign_id": "META_RETARGETING_US", "campaign_name": "US Retargeting | 30 Day", "platform": "Meta", "objective": "Purchase", "audience": "Retargeting", "region": "US", "daily_budget": 420, "base_cpc": .82, "base_cvr": .072, "aov": 93},
    {"campaign_id": "META_PROSPECTING_UK", "campaign_name": "UK Prospecting | Broad", "platform": "Meta", "objective": "Purchase", "audience": "Prospecting", "region": "UK", "daily_budget": 380, "base_cpc": .91, "base_cvr": .027, "aov": 78},
    {"campaign_id": "GOOGLE_BRAND_US", "campaign_name": "US Search | Brand", "platform": "Google", "objective": "Purchase", "audience": "Brand Search", "region": "US", "daily_budget": 350, "base_cpc": 1.42, "base_cvr": .105, "aov": 91},
    {"campaign_id": "GOOGLE_NONBRAND_US", "campaign_name": "US Search | Nonbrand", "platform": "Google", "objective": "Purchase", "audience": "Nonbrand Search", "region": "US", "daily_budget": 720, "base_cpc": 2.14, "base_cvr": .041, "aov": 101},
    {"campaign_id": "GOOGLE_SHOPPING_US", "campaign_name": "US Shopping | Core", "platform": "Google", "objective": "Purchase", "audience": "Shopping", "region": "US", "daily_budget": 610, "base_cpc": 1.06, "base_cvr": .052, "aov": 97},
]


def write_csv(path: Path, rows: list[dict]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if not rows:
        return
    with path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)


def date_range():
    current = START
    while current <= END:
        yield current
        current += timedelta(days=1)


def main() -> None:
    RAW.mkdir(parents=True, exist_ok=True)
    CURATED.mkdir(parents=True, exist_ok=True)
    write_csv(CURATED / "dim_campaign.csv", CAMPAIGNS)
    ads, sessions, orders = [], [], []
    order_num = 1
    for day in date_range():
        seasonality = 1.0 + .12 * ((day.month - 1) / 5) + (.13 if day.weekday() >= 5 else 0)
        for c in CAMPAIGNS:
            spend = round(c["daily_budget"] * seasonality * RNG.uniform(.82, 1.08), 2)
            cpc = c["base_cpc"] * RNG.uniform(.88, 1.14)
            clicks = max(1, round(spend / cpc))
            impressions = round(clicks / RNG.uniform(.012, .035))
            ad_conversions = max(0, round(clicks * c["base_cvr"] * seasonality * RNG.uniform(.72, 1.30)))
            ads.append({"report_date": day.isoformat(), "campaign_id": c["campaign_id"], "platform": c["platform"], "impressions": impressions, "clicks": clicks, "spend": f"{spend:.2f}", "platform_reported_conversions": ad_conversions})
            # Sessions are a separate web analytics extract, with modest non-paid/background volume.
            # A small share of ad clicks fail to become a tracked session.
            web_sessions = max(0, round(clicks * RNG.uniform(.88, .99)))
            sessions.append({"session_date": day.isoformat(), "campaign_id": c["campaign_id"], "sessions": web_sessions, "engaged_sessions": round(web_sessions * RNG.uniform(.53, .78))})
            actual_orders = max(0, round(web_sessions * c["base_cvr"] * seasonality * RNG.uniform(.72, 1.30)))
            for _ in range(actual_orders):
                revenue = round(max(18, RNG.gauss(c["aov"], c["aov"] * .27)), 2)
                orders.append({"order_id": f"ORD-{order_num:07d}", "order_date": day.isoformat(), "campaign_id": c["campaign_id"], "customer_id": f"CUST-{RNG.randint(1, 8200):05d}", "order_revenue": f"{revenue:.2f}", "discount_amount": f"{RNG.choice([0, 0, 0, 5, 10, 15]):.2f}", "currency": "USD"})
                order_num += 1
    write_csv(RAW / "paid_media_daily.csv", ads)
    write_csv(RAW / "web_sessions_daily.csv", sessions)
    write_csv(RAW / "ecommerce_orders.csv", orders)

    ad_map = {(r["report_date"], r["campaign_id"]): r for r in ads}
    session_map = {(r["session_date"], r["campaign_id"]): r for r in sessions}
    order_map: dict[tuple[str, str], list[dict]] = defaultdict(list)
    for row in orders:
        order_map[(row["order_date"], row["campaign_id"])].append(row)
    fact = []
    for key in sorted(ad_map):
        ad, web, daily_orders = ad_map[key], session_map[key], order_map[key]
        revenue = sum(float(o["order_revenue"]) for o in daily_orders)
        fact.append({"report_date": key[0], "campaign_id": key[1], "platform": ad["platform"], "impressions": ad["impressions"], "clicks": ad["clicks"], "spend": ad["spend"], "sessions": web["sessions"], "engaged_sessions": web["engaged_sessions"], "orders": len(daily_orders), "attributed_revenue": f"{revenue:.2f}"})
    write_csv(CURATED / "fact_campaign_performance_daily.csv", fact)
    customer_orders: dict[str, list[dict]] = defaultdict(list)
    for order in orders:
        customer_orders[order["customer_id"]].append(order)
    customer_profiles = []
    for customer_id, customer_rows in customer_orders.items():
        customer_rows.sort(key=lambda row: (row["order_date"], row["order_id"]))
        first = customer_rows[0]
        customer_profiles.append({
            "customer_id": customer_id,
            "first_order_month": first["order_date"][:7],
            "first_campaign_id": first["campaign_id"],
            "orders": len(customer_rows),
            "observed_revenue": round(sum(float(row["order_revenue"]) for row in customer_rows), 2),
            "returning": len(customer_rows) > 1,
        })
    dashboard_payload = {"campaigns": CAMPAIGNS, "daily": fact, "customers": customer_profiles,
                         "data_label": "Synthetic portfolio dataset"}
    (ROOT / "dashboard" / "synthetic_data.js").write_text(
        "window.MARKETING_DATA = " + __import__("json").dumps(dashboard_payload, separators=(",", ":")) + ";\n",
        encoding="utf-8",
    )
    print(f"Generated {len(ads):,} synthetic ad rows, {len(sessions):,} session rows, {len(orders):,} orders, and {len(fact):,} curated daily rows under data/synthetic_demo/.")


if __name__ == "__main__":
    main()
