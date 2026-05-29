#!/bin/bash
# Japanese consumption tax calculation examples
# Supports dual rate: 10% (standard) and 8% (reduced / food)
# Set TORIFY_API_KEY or use X-Trial-Key for trial access

BASE="https://torify.dev/v1"
API_KEY="${TORIFY_API_KEY:-your-api-key}"

echo "=== Single item: standard 10% (tax-exclusive) ==="
curl -s "$BASE/tax/calculate?amount=1000&category=standard" | jq .

echo ""
echo "=== Single item: reduced 8% / food (tax-exclusive) ==="
curl -s "$BASE/tax/calculate?amount=1000&category=food" | jq .

echo ""
echo "=== Bulk calculation — up to 1,000 line items in one POST ==="
curl -s -X POST "$BASE/tax/calculate/bulk" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d '{"items":[{"amount":1000,"rate":10,"type":"exclusive"},{"amount":540,"rate":8,"type":"inclusive"}]}' | jq .
# {
#   "ok": true,
#   "data": {
#     "total": 2,
#     "results": [
#       { "amount": 1000, "rate": 10, "type": "exclusive", "tax": 100, "totalWithTax": 1100, "amountExcludingTax": 1000 },
#       { "amount": 540, "rate": 8, "type": "inclusive", "tax": 40, "totalWithTax": 540, "amountExcludingTax": 500 }
#     ],
#     "summary": { "totalAmount": 1540, "totalTax": 140, "totalWithTax": 1640, "totalExcludingTax": 1500 }
#   }
# }
