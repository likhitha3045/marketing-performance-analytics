"""Prepare the real UCI Bank Marketing data for the existing dashboard.

The source is historical and static. This script downloads it only if the
original source CSV is absent, then creates a smaller curated CSV and browser
payload. Standard library only.
"""
from __future__ import annotations

import csv
import io
import json
import urllib.request
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "data" / "source_extracts" / "real"
CURATED = ROOT / "data" / "curated" / "real_bank_marketing"
SOURCE = RAW / "bank-additional-full.csv"
ZIP_PATH = RAW / "uci-bank-marketing.zip"
URL = "https://archive.ics.uci.edu/static/public/222/bank+marketing.zip"

FIELDS = ["age", "job", "marital", "education", "contact", "month", "day_of_week",
          "campaign", "pdays", "previous", "poutcome", "subscribed"]
CATEGORICAL = {"job", "marital", "education", "contact", "month", "day_of_week", "poutcome", "subscribed"}


def ensure_source() -> None:
    RAW.mkdir(parents=True, exist_ok=True)
    if SOURCE.exists():
        return
    if not ZIP_PATH.exists():
        print(f"Downloading official UCI archive: {URL}")
        urllib.request.urlretrieve(URL, ZIP_PATH)
    with zipfile.ZipFile(ZIP_PATH) as outer:
        nested_name = next(n for n in outer.namelist() if n.endswith("bank-additional.zip"))
        nested_bytes = outer.read(nested_name)
    with zipfile.ZipFile(io.BytesIO(nested_bytes)) as nested:
        csv_name = next(n for n in nested.namelist() if n.endswith("bank-additional-full.csv"))
        SOURCE.write_bytes(nested.read(csv_name))


def main() -> None:
    ensure_source()
    CURATED.mkdir(parents=True, exist_ok=True)
    records: list[list[object]] = []
    with SOURCE.open(encoding="utf-8-sig", newline="") as f:
        reader = csv.DictReader(f, delimiter=";")
        source_fields = set(FIELDS) - {"subscribed"}
        missing_fields = source_fields - set(reader.fieldnames or [])
        if "y" not in (reader.fieldnames or []):
            missing_fields.add("y (source field for subscribed)")
        if missing_fields:
            raise ValueError(f"Unexpected UCI source schema; missing: {sorted(missing_fields)}")
        for row in reader:
            record: list[object] = []
            for field in FIELDS:
                value = row["y" if field == "subscribed" else field].strip()
                record.append(value if field in CATEGORICAL else int(value))
            records.append(record)

    curated_path = CURATED / "bank_marketing_contacts.csv"
    with curated_path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["case_id", *FIELDS])
        for i, record in enumerate(records, start=1):
            writer.writerow([f"CASE-{i:05d}", *record])

    payload = {"source": "UCI Bank Marketing (bank-additional-full.csv)",
               "source_url": "https://archive.ics.uci.edu/dataset/222/bank%2Bmarketing",
               "source_rows": len(records), "fields": FIELDS, "records": records,
               "license": "CC BY 4.0", "period_note": "May 2008–November 2010; exact dates/year are not included in this file"}
    output = ROOT / "dashboard" / "historical_data.js"
    output.write_text("window.MARKETING_DATA = " + json.dumps(payload, separators=(",", ":")) + ";\n", encoding="utf-8")
    yes = sum(row[-1] == "yes" for row in records)
    print(f"Prepared {len(records):,} real UCI records; {yes:,} subscribers ({yes / len(records):.1%}).")
    print(f"Curated CSV: {curated_path}")


if __name__ == "__main__":
    main()
