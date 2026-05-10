#!/bin/bash
# Corporate number (法人番号) lookup examples
# Requires TORIFY_API_KEY

BASE="https://torify.dev/v1"
API_KEY="${TORIFY_API_KEY:-your-api-key}"

echo "=== Corporate number lookup (国税庁) ==="
curl -s "$BASE/houjin/lookup?number=8010401050783" \
  -H "X-API-Key: $API_KEY" | jq .

echo ""
echo "=== Industry classification (JSIC) ==="
curl -s "$BASE/industry/lookup?code=3911" \
  -H "X-API-Key: $API_KEY" | jq .
