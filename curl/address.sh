#!/bin/bash
# Address and location examples
# Set TORIFY_API_KEY for address normalization

BASE="https://torify.dev/v1"
API_KEY="${TORIFY_API_KEY:-your-api-key}"

echo "=== Postal code lookup ==="
curl -s "$BASE/postal/lookup?zipcode=1000013" | jq .

echo ""
echo "=== Address normalization (largest-to-smallest order) ==="
curl -s "$BASE/address/normalize" \
  --get --data-urlencode "address=東京都千代田区霞が関3丁目1番1号" \
  -H "X-API-Key: $API_KEY" | jq .

echo ""
echo "=== Address normalization — Kyoto tori-na (通り名) example (address Phase 2.5) ==="
# Kyoto uses a street-grid system with named tōri (通り) instead of block numbers.
# addressType=kyoto_torichi is returned, plus streetRef (the intersection) and addressee.
curl -s "$BASE/address/normalize" \
  --get --data-urlencode "address=京都府京都市中京区烏丸通三条上る場之町" \
  -H "X-API-Key: $API_KEY" | jq .
# {
#   "ok": true,
#   "data": {
#     "prefecture": "京都府", "city": "京都市", "ward": "中京区",
#     "addressType": "kyoto_torichi",
#     "streetRef": "烏丸通三条上る",
#     "addressee": "場之町"
#   }
# }

echo ""
echo "=== Region lookup by prefecture ==="
curl -s "$BASE/region/lookup?prefecture=東京都" | jq .

echo ""
echo "=== Phone number validation (variable-length area codes) ==="
# Tokyo: 2-digit area code (03)
curl -s "$BASE/phone/validate?phone=03-1234-5678" | jq .

# Rural: 4-digit area code (0266)
curl -s "$BASE/phone/validate?phone=0266-12-3456" | jq .
