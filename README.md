# torify-examples

Code examples for [Torify](https://torify.dev) — Japanese locale APIs for AI agents.

39 endpoints for wareki (era dates), invoice validation, corporate lookup, address normalization, bank/branch search (full Zengin database — 1,152 institutions), legal holiday (Labor Standards Act), school code, and more.

[![torify.dev](https://img.shields.io/badge/API-torify.dev-60a5fa)](https://torify.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Smithery](https://img.shields.io/badge/Smithery-100%2F100-purple)](https://smithery.ai/servers/endenibrk/torify)
[![Glama](https://img.shields.io/badge/Glama-listed-blue)](https://glama.ai/mcp/servers/endennn/torify-examples)
[![MCP.so](https://img.shields.io/badge/MCP.so-listed-green)](https://mcp.so/server/torify-%E2%80%94-japanese-locale-apis-for-ai-agents/hiroki-sonoda)

## Listed on

- **x402scan** — https://www.x402scan.com
- **Smithery** — https://smithery.ai/servers/endenibrk/torify
- **Glama** — https://glama.ai/mcp/servers/endennn/torify-examples
- **MCP.so** — https://mcp.so/server/torify-%E2%80%94-japanese-locale-apis-for-ai-agents/hiroki-sonoda
- **Anthropic Official MCP Registry** — https://registry.modelcontextprotocol.io/v0.1/servers?search=dev.torify
- **a2aregistry.org** — https://a2aregistry.org
- **Google Search Console** — https://search.google.com/search-console

---

## Quick Start

### Free tier (MCP — no wallet, no signup)

Add to `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "torify": {
      "type": "http",
      "url": "https://torify-mcp.torify.workers.dev"
    }
  }
}
```

100 requests/day/IP free. Works in Claude Desktop and Cursor.

### x402 per-call ($0.02 USDC on Base L2)

```bash
npm install x402-fetch viem
export PRIVATE_KEY="0x..."
npx ts-node typescript/x402-example.ts
```

### API Key subscription ($49/mo)

```bash
export TORIFY_API_KEY="your-key"
npx ts-node typescript/apikey-example.ts
```

---

## Examples

### Wareki (era date) conversion

```bash
# Gregorian → Wareki
curl "https://torify.dev/v1/wareki/convert?direction=g2w&date=2024-05-01"
# { "ok": true, "data": { "era": "令和", "eraYear": 6, "formatted": "令和6年5月1日" } }

# Wareki → Gregorian (edge case: Showa ended Jan 7, 1989; Heisei started Jan 8, 1989)
curl "https://torify.dev/v1/wareki/convert?direction=w2g&era=showa&eraYear=64&month=1&day=7"
# { "ok": true, "data": { "gregorian": "1989-01-07" } }
```

### Invoice number validation

```bash
# Format + check digit validation (no payment needed)
curl "https://torify.dev/v1/invoice/validate?number=T7000012050002"
# { "ok": true, "data": { "valid": true } }
```

> **Status**: NTA registry integration is pending external API approval. Coming soon.

```bash
# NTA registry lookup — is this T-number actually registered?
curl "https://torify.dev/v1/invoice/verify?number=T7000012050002" \
  -H "X-API-Key: $TORIFY_API_KEY"
# { "ok": true, "data": { "registered": true, "registrantName": "国税庁", "confidence": 0.99 } }
```

### Corporate number lookup

> **Status**: Corporate number lookup is pending external API approval. Coming soon.

```bash
curl "https://torify.dev/v1/houjin/lookup?number=7000012050002" \
  -H "X-API-Key: $TORIFY_API_KEY"
# { "ok": true, "data": { "name": "国税庁", "address": "東京都千代田区霞が関3丁目1番1号", "status": "active" } }
```

### Postal code lookup

```bash
curl "https://torify.dev/v1/postal/lookup?zipcode=1000013"
# { "ok": true, "data": { "prefecture": "東京都", "city": "千代田区", "town": "霞が関" } }
```

### Phone number validation

```bash
# Tokyo (2-digit area code 03)
curl "https://torify.dev/v1/phone/validate?phone=03-1234-5678"
# { "ok": true, "data": { "valid": true, "type": "landline", "region": "東京" } }

# Rural (4-digit area code 0266)
curl "https://torify.dev/v1/phone/validate?phone=0266-12-3456"
# { "ok": true, "data": { "valid": true, "type": "landline", "region": "長野" } }
```

### Address normalization

```bash
curl "https://torify.dev/v1/address/normalize" \
  --get --data-urlencode "address=東京都千代田区霞が関3丁目1番1号" \
  -H "X-API-Key: $TORIFY_API_KEY"
# { "ok": true, "data": { "prefecture": "東京都", "city": "千代田区", "town": "霞が関", "block": "3丁目1番1号" } }
```

### Bank lookup, search, and list (full Zengin database, 1,150+ banks)

```bash
# Look up by bank code + branch code
curl "https://torify.dev/v1/bank/lookup?bankCode=0001&branchCode=001" \
  -H "X-API-Key: $TORIFY_API_KEY"
# { "ok": true, "data": { "bankName": "みずほ銀行", "bankNameEn": "Mizuho Bank",
#                          "branchName": "東京営業部", "found": true, "branchFound": true } }

# Search banks by partial name (kanji / kana / romaji)
curl "https://torify.dev/v1/bank/search" --get --data-urlencode "name=みずほ" \
  -H "X-API-Key: $TORIFY_API_KEY"
# { "ok": true, "data": { "mode": "bank", "hits": [...], "total": 2 } }

# Search branches within a specific bank
curl "https://torify.dev/v1/bank/search?bankCode=0001" --get --data-urlencode "name=東京" \
  -H "X-API-Key: $TORIFY_API_KEY"
# { "ok": true, "data": { "mode": "branch", "hits": [...] } }

# Paginated full bank list
curl "https://torify.dev/v1/bank/list?limit=5" \
  -H "X-API-Key: $TORIFY_API_KEY"
# { "ok": true, "data": { "total": 1152, "banks": [...] } }
```

### Bank transfer validation (Zengin format)

```bash
curl "https://torify.dev/v1/bank/transfer/validate?bankCode=0001&branchCode=001&accountType=1&accountNumber=1234567" \
  -H "X-API-Key: $TORIFY_API_KEY"
# { "ok": true, "data": { "valid": true, "accountTypeName": "普通", "isYucho": false } }
```

### Legal holiday check (Labor Standards Act Art. 35)

```bash
# Standard 5-day work week (Sun = legal holiday, Sat = non-legal rest day)
curl "https://torify.dev/v1/legal-holiday/check?date=2024-05-05&restDays=sun,sat" \
  -H "X-API-Key: $TORIFY_API_KEY"
# { "ok": true, "data": { "isLegalHoliday": true, "overtimePremiumRate": 0.35,
#                          "overtimePremiumRateLegalNonHoliday": 0.25,
#                          "legalReference": "Labor Standards Act Article 35 (労働基準法第35条)" } }
```

### MEXT school code validation (13-char)

```bash
curl "https://torify.dev/v1/school-code/validate?code=B213123456X00" \
  -H "X-API-Key: $TORIFY_API_KEY"
# { "ok": true, "data": { "valid": true, "schoolType": "elementary",
#                          "establishment": "public_prefectural", "prefectureJa": "東京都" } }
```

### Self IP address (free, no auth)

```bash
curl "https://torify.dev/v1/whoami"
# { "ok": true, "data": { "ip": "...", "country": "JP", "userAgent": "..." } }
```

---

## TypeScript with x402 (autonomous payment)

```typescript
import { wrapFetchWithPayment } from "x402-fetch";
import { createWalletClient, http } from "viem";
import { base } from "viem/chains";
import { privateKeyToAccount } from "viem/accounts";

const wallet = createWalletClient({
  account: privateKeyToAccount(process.env.PRIVATE_KEY as `0x${string}`),
  chain: base,
  transport: http()
});
const fetch402 = wrapFetchWithPayment(fetch, wallet);

// Agent pays $0.02 USDC automatically — no API key needed
const res = await fetch402("https://torify.dev/v1/invoice/verify?number=T7000012050002");
const { ok, data } = await res.json();
console.log(data.registered, data.confidence); // true, 0.99
```

## Python with API Key

```python
import os, requests

headers = {"X-API-Key": os.environ["TORIFY_API_KEY"]}

r = requests.get(
    "https://torify.dev/v1/address/normalize",
    params={"address": "東京都千代田区霞が関3丁目1番1号"},
    headers=headers
)
data = r.json()["data"]
print(data["prefecture"], data["city"], data["town"])
# 東京都 千代田区 霞が関
```

---

## All Endpoints

Full docs: [torify.dev/docs](https://torify.dev/docs)

All 39 endpoints (paid $0.02/call + free MCP / whoami):

| Category | Endpoints |
|----------|-----------|
| Era & Date | wareki/convert, holiday/check, age/calculate, legal-holiday/check |
| Legal & Tax | invoice/validate, invoice/verify, tax/calculate, eltax/check (POST) |
| Corporate | houjin/lookup, industry/lookup |
| Address | postal/lookup, address/normalize, region/lookup, coordinate/convert |
| Geo | geo/geocode (address → lat/lng via GSI, PDL 1.0), geo/reverse-geocode (lat/lng → municipality + town via GSI, PDL 1.0) |
| Legal Search | law/search (Japanese law search via e-Gov API v2, 政府標準利用規約) |
| Text | name/romanize, name/split, name/validate, kana/convert, text/normalize, kanji/to-kana, kanji/normalize (POST) |
| Finance | bank/lookup, bank/search, bank/list, bank/transfer/validate, yucho/convert, payment/3ds/check |
| Identity | mynumber/validate, passport/validate, license/validate, insurance/validate, plate/validate, barcode/validate, phone/validate |
| Education | school-code/validate |
| Diagnostic | whoami (free, no auth required) |
| Bulk (free) | wareki/convert/bulk, invoice/validate/bulk (60 req/min/IP) |

---

## License

MIT — examples only. The Torify API service is proprietary.
