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
echo "=== Region lookup by prefecture ==="
curl -s "$BASE/region/lookup?prefecture=東京都" | jq .

echo ""
echo "=== Phone number validation (variable-length area codes) ==="
# Tokyo: 2-digit area code (03)
curl -s "$BASE/phone/validate?phone=03-1234-5678" | jq .

# Rural: 4-digit area code (0266)
curl -s "$BASE/phone/validate?phone=0266-12-3456" | jq .
