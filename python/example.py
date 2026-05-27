"""
Torify API examples — Python
Setup: pip install requests
       export TORIFY_API_KEY="your-key"
       # Or use the free trial (100 calls/month):
       export TRIAL_KEY="tk_..."   # https://torify.dev/trial
"""

import os
import requests

BASE = "https://torify.dev/v1"
API_KEY = os.environ.get("TORIFY_API_KEY", "")
TRIAL_KEY = os.environ.get("TRIAL_KEY", "")

# Prefer Trial key for demos; fall back to API key
if TRIAL_KEY:
    headers = {"X-Trial-Key": TRIAL_KEY}
elif API_KEY:
    headers = {"X-API-Key": API_KEY}
else:
    headers = {}


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

# --- Address normalization v0.3.0+ (requires API key or Trial key) ---
# New schema fields: addressType / streetRef (Kyoto intersection) / addressee (方書)

def normalize_address(address_str: str) -> dict:
    """Normalize Japanese address with v0.3.0+ schema."""
    r = requests.get(
        f"{BASE}/address/normalize",
        params={"address": address_str},
        headers=headers,
    )
    r.raise_for_status()
    return r.json()["data"]

# 通常住所 — addressType=block
block = normalize_address("東京都千代田区霞が関3丁目1番1号")
print(f"Address (block): {block['prefecture']} {block['city']} {block['town']}")
print(f"  addressType={block['addressType']}, streetRef={block['streetRef']}, addressee={block['addressee']}")
# 東京都 千代田区 霞が関
# addressType=block, streetRef=None, addressee=None

# NEW: 京都通り名 — addressType=street, streetRef populated
kyoto = normalize_address("京都府京都市中京区烏丸通三条上る場之町")
print(f"Address (street): {kyoto['prefecture']} {kyoto['city']} {kyoto['town']}")
print(f"  addressType={kyoto['addressType']}, streetRef={kyoto['streetRef']}, addressee={kyoto['addressee']}")
# addressType=street
# streetRef={'intersection': '烏丸通三条上る', 'direction': '上る'}

# NEW: 方書 (様方) — addressee 分離
kata = normalize_address("東京都港区赤坂2-3-4 山田様方")
print(f"Address (方書): {kata['prefecture']} {kata['city']} {kata['town']}")
print(f"  addressType={kata['addressType']}, streetRef={kata['streetRef']}, addressee={kata['addressee']}")
# addressType=block, streetRef=None, addressee='山田'

# NEW: 漢数字 1-99 → Arabic 自動変換
kanji = normalize_address("東京都港区赤坂二丁目")
print(f"Address (漢数字→Arabic): town={kanji['town']}")
# town='赤坂2丁目'  ← '二' → '2' auto-converted

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
