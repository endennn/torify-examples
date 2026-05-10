#!/bin/bash
# Wareki (Japanese era date) conversion examples

BASE="https://torify.dev/v1"

echo "=== Gregorian → Wareki ==="
curl -s "$BASE/wareki/convert?direction=g2w&date=2024-05-01" | jq .

echo ""
echo "=== Wareki → Gregorian (Showa 64 edge case) ==="
curl -s "$BASE/wareki/convert?direction=w2g&era=showa&year=64&month=1&day=7" | jq .

echo ""
echo "=== Wareki → Gregorian (Heisei 1 same day) ==="
curl -s "$BASE/wareki/convert?direction=w2g&era=heisei&year=1&month=1&day=7" | jq .

echo ""
echo "=== Holiday check ==="
curl -s "$BASE/holiday/check?date=2024-01-01" | jq .
