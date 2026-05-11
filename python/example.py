"""
Torify API examples — Python
Setup: pip install requests
       export TORIFY_API_KEY="your-key"
"""

import os
import requests

BASE = "https://torify.dev/v1"
API_KEY = os.environ.get("TORIFY_API_KEY", "")
headers = {"X-API-Key": API_KEY} if API_KEY else {}


def get(path: str, params: dict = None, require_key: bool = False) -> dict:
    h = headers if require_key else {}
    r = requests.get(f"{BASE}{path}", params=params, headers=h)
    r.raise_for_status()
    return r.json()


# --- Era date conversion (no API key required) ---

wareki = get("/wareki/convert", {"direction": "g2w", "date": "2024-05-01"})
print("Wareki:", wareki["data"])
# {'era': '令和', 'eraYear': 6, 'formatted': '令和6年5月1日'}

# Edge case: Showa ended Jan 7 1989, Heisei started Jan 8 1989 (different days)
showa64 = get("/wareki/convert", {"direction": "w2g", "era": "showa", "eraYear": 64, "month": 1, "day": 7})
print("Showa 64:", showa64["data"])
# {'gregorian': '1989-01-07'}

# --- Postal code lookup (no API key required) ---

postal = get("/postal/lookup", {"zipcode": "1000013"})
print("Postal:", postal["data"])
# {'prefecture': '東京都', 'city': '千代田区', 'town': '霞が関'}

# --- Invoice validation (no API key required) ---

invoice = get("/invoice/validate", {"number": "T7000012050002"})
print("Invoice valid:", invoice["data"]["valid"])
# True

# --- Address normalization (requires API key) ---

address = get(
    "/address/normalize",
    {"address": "東京都千代田区霞が関3丁目1番1号"},
    require_key=True
)
data = address["data"]
print(f"Address: {data['prefecture']} {data['city']} {data['town']}")
# 東京都 千代田区 霞が関

# --- Phone validation (no API key required) ---

# Tokyo: 2-digit area code 03
phone_tokyo = get("/phone/validate", {"phone": "03-1234-5678"})
print("Phone (Tokyo):", phone_tokyo["data"])

# Rural: 4-digit area code 0266
phone_rural = get("/phone/validate", {"phone": "0266-12-3456"})
print("Phone (rural):", phone_rural["data"])

# --- Tax calculation (no API key required) ---

# Reduced rate (食料品 8%)
tax_food = get("/tax/calculate", {"amount": 1000, "category": "food"})
print("Tax (food):", tax_food["data"])
# {'taxAmount': 80, 'totalAmount': 1080, 'rate': 0.08}

# Standard rate (10%)
tax_std = get("/tax/calculate", {"amount": 1000, "category": "standard"})
print("Tax (standard):", tax_std["data"])
# {'taxAmount': 100, 'totalAmount': 1100, 'rate': 0.10}
