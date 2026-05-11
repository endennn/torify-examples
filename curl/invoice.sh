#!/bin/bash
# Japan qualified invoice (インボイス制度) examples
# Set TORIFY_API_KEY for registry lookup (invoice/verify)

BASE="https://torify.dev/v1"
API_KEY="${TORIFY_API_KEY:-your-api-key}"

echo "=== Invoice format + check digit validation (free) ==="
curl -s "$BASE/invoice/validate?number=T7000012050002" | jq .

echo ""
echo "=== Invalid check digit ==="
curl -s "$BASE/invoice/validate?number=T1234567890123" | jq .

echo ""
echo "=== NTA registry lookup (requires API key) ==="
curl -s "$BASE/invoice/verify?number=T7000012050002" \
  -H "X-API-Key: $API_KEY" | jq .

echo ""
echo "=== Consumption tax calculation (dual rate: 8% food / 10% standard) ==="
curl -s "$BASE/tax/calculate?amount=1000&category=food" | jq .
curl -s "$BASE/tax/calculate?amount=1000&category=standard" | jq .
