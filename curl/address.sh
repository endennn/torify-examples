#!/usr/bin/env bash
# Address normalization examples (v0.3.0+)
# Schema: addressType / streetRef (Kyoto intersection) / addressee (方書)
#
# Setup:
#   export TRIAL_KEY="tk_..."      # free 100 calls/month: https://torify.dev/trial
#   export TORIFY_API_KEY="your-key"  # Pro $49/mo or Enterprise $499/mo
#   bash curl/address.sh

API="${TORIFY_API:-https://torify.dev/v1}"
TRIAL_KEY="${TRIAL_KEY:-}"
API_KEY="${TORIFY_API_KEY:-}"

# Use Trial key if available, otherwise API key
if [ -n "$TRIAL_KEY" ]; then
  AUTH_HEADER="X-Trial-Key: $TRIAL_KEY"
elif [ -n "$API_KEY" ]; then
  AUTH_HEADER="X-API-Key: $API_KEY"
else
  echo "ERROR: Set TRIAL_KEY or TORIFY_API_KEY environment variable"
  echo "  Free trial signup: curl -X POST https://torify.dev/v1/trial/signup -H 'Content-Type: application/json' -d '{\"email\":\"you@example.com\"}'"
  exit 1
fi

echo "=== Postal code lookup (no auth required) ==="
curl -s "$API/postal/lookup?zipcode=1000013" | python3 -c "import json,sys; d=json.load(sys.stdin); print(json.dumps(d, ensure_ascii=False, indent=2))"

echo ""
echo "=== Address normalization: 通常住所 — addressType=block ==="
curl -s "$API/address/normalize" \
  --get --data-urlencode "address=東京都千代田区霞が関3丁目1番1号" \
  -H "$AUTH_HEADER" | python3 -c "
import json,sys
d=json.load(sys.stdin)
if d.get('ok'):
  data = d['data']
  print(json.dumps({
    'prefecture': data.get('prefecture'),
    'city': data.get('city'),
    'town': data.get('town'),
    'addressType': data.get('addressType'),
    'streetRef': data.get('streetRef'),
    'addressee': data.get('addressee'),
  }, ensure_ascii=False, indent=2))
else:
  print(json.dumps(d, ensure_ascii=False, indent=2))
"

echo ""
echo "=== NEW: 京都通り名 — addressType=street, streetRef populated ==="
curl -s "$API/address/normalize" \
  --get --data-urlencode "address=京都府京都市中京区烏丸通三条上る場之町" \
  -H "$AUTH_HEADER" | python3 -c "
import json,sys
d=json.load(sys.stdin)
if d.get('ok'):
  data = d['data']
  print(json.dumps({
    'prefecture': data.get('prefecture'),
    'city': data.get('city'),
    'town': data.get('town'),
    'addressType': data.get('addressType'),
    'streetRef': data.get('streetRef'),
    'addressee': data.get('addressee'),
  }, ensure_ascii=False, indent=2))
else:
  print(json.dumps(d, ensure_ascii=False, indent=2))
"
# Expected: addressType=street, streetRef={intersection:'烏丸通三条上る', direction:'上る'}

echo ""
echo "=== NEW: 方書 (様方) — addressee 分離 ==="
curl -s "$API/address/normalize" \
  --get --data-urlencode "address=東京都港区赤坂2-3-4 山田様方" \
  -H "$AUTH_HEADER" | python3 -c "
import json,sys
d=json.load(sys.stdin)
if d.get('ok'):
  data = d['data']
  print(json.dumps({
    'prefecture': data.get('prefecture'),
    'city': data.get('city'),
    'town': data.get('town'),
    'addressType': data.get('addressType'),
    'streetRef': data.get('streetRef'),
    'addressee': data.get('addressee'),
  }, ensure_ascii=False, indent=2))
else:
  print(json.dumps(d, ensure_ascii=False, indent=2))
"
# Expected: addressType=block, addressee='山田', streetRef=null

echo ""
echo "=== NEW: 漢数字 1-99 → Arabic 自動変換 ==="
curl -s "$API/address/normalize" \
  --get --data-urlencode "address=東京都港区赤坂二丁目" \
  -H "$AUTH_HEADER" | python3 -c "
import json,sys
d=json.load(sys.stdin)
if d.get('ok'):
  data = d['data']
  print(json.dumps({
    'prefecture': data.get('prefecture'),
    'city': data.get('city'),
    'town': data.get('town'),
    'addressType': data.get('addressType'),
    'streetRef': data.get('streetRef'),
    'addressee': data.get('addressee'),
  }, ensure_ascii=False, indent=2))
else:
  print(json.dumps(d, ensure_ascii=False, indent=2))
"
# Expected: town='赤坂2丁目' (kanji '二' → '2' auto-converted)

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
curl -s "$API/region/lookup?prefecture=東京都" | python3 -c "import json,sys; d=json.load(sys.stdin); print(json.dumps(d, ensure_ascii=False, indent=2))"

echo ""
echo "=== Phone number validation (variable-length area codes) ==="
# Tokyo: 2-digit area code (03)
curl -s "$API/phone/validate?phone=03-1234-5678" | python3 -c "import json,sys; d=json.load(sys.stdin); print(json.dumps(d, ensure_ascii=False, indent=2))"

# Rural: 4-digit area code (0266)
curl -s "$API/phone/validate?phone=0266-12-3456" | python3 -c "import json,sys; d=json.load(sys.stdin); print(json.dumps(d, ensure_ascii=False, indent=2))"
