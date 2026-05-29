#!/bin/bash
# Freelance Act (フリーランス・事業者間取引適正化等法) compliance examples
# Effective 2024-11-01 — validates all 7 mandatory disclosure items
# Set TORIFY_API_KEY or use X-Trial-Key for trial access

BASE="https://torify.dev/v1"
API_KEY="${TORIFY_API_KEY:-your-api-key}"

echo "=== Freelance work order validation (compliant example) ==="
curl -s -X POST "$BASE/freelance/order/validate" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d '{"order":{"description":"Webデザイン","amount":500000,"paymentDueDays":30,"deliveryDate":"2026-06-30","deliveryLocation":"メール納品","paymentMethod":"銀行振込"}}' | jq .
# {
#   "ok": true,
#   "data": {
#     "compliant": true,
#     "checks": [{ "item": "業務内容", "status": "ok" }],
#     "violations": [],
#     "warnings": [],
#     "missing": [],
#     "summary": "compliant"
#   }
# }
