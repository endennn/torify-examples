# torify-examples

Code examples for [Torify](https://torify.dev) — Japanese locale APIs for AI agents.

31 endpoints for wareki (era dates), invoice validation, corporate lookup, address normalization, and more.

[![torify.dev](https://img.shields.io/badge/API-torify.dev-60a5fa)](https://torify.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

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

### API Key subscription ($99/mo)

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
curl "https://torify.dev/v1/invoice/validate?number=T8010401050783"
# { "ok": true, "data": { "valid": true } }
```

> **Status**: NTA registry integration is pending external API approval. Coming soon.

```bash
# NTA registry lookup — is this T-number actually registered?
curl "https://torify.dev/v1/invoice/verify?number=T8010401050783" \
  -H "X-API-Key: $TORIFY_API_KEY"
# { "ok": true, "data": { "registered": true, "registrantName": "国税庁", "confidence": 0.99 } }
```

### Corporate number lookup

> **Status**: Corporate number lookup is pending external API approval. Coming soon.

```bash
curl "https://torify.dev/v1/houjin/lookup?number=8010401050783" \
  -H "X-API-Key: $TORIFY_API_KEY"
# { "ok": true, "data": { "name": "国税庁", "address": "東京都千代田区霞が関3丁目1番1号", "status": "active" } }
```

### Postal code lookup

```bash
curl "https://torify.dev/v1/postal/lookup?code=1000013"
# { "ok": true, "data": { "prefecture": "東京都", "city": "千代田区", "town": "霞が関" } }
```

### Phone number validation

```bash
# Tokyo (2-digit area code 03)
curl "https://torify.dev/v1/phone/validate?number=03-1234-5678"
# { "ok": true, "data": { "valid": true, "type": "landline", "region": "東京" } }

# Rural (4-digit area code 0266)
curl "https://torify.dev/v1/phone/validate?number=0266-12-3456"
# { "ok": true, "data": { "valid": true, "type": "landline", "region": "長野" } }
```

### Address normalization

```bash
curl "https://torify.dev/v1/address/normalize" \
  --get --data-urlencode "address=東京都千代田区霞が関3丁目1番1号" \
  -H "X-API-Key: $TORIFY_API_KEY"
# { "ok": true, "data": { "prefecture": "東京都", "city": "千代田区", "town": "霞が関", "block": "3丁目1番1号" } }
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
const res = await fetch402("https://torify.dev/v1/invoice/verify?number=T8010401050783");
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

| Category | Endpoints |
|----------|-----------|
| Era & Date | wareki/convert, holiday/check, age/calculate |
| Legal & Tax | invoice/validate, invoice/verify, tax/calculate |
| Corporate | houjin/lookup, industry/lookup |
| Address | postal/lookup, address/normalize, region/lookup |
| Text | name/romanize, kanji/to-kana, kana/convert, text/normalize |
| Finance | bank/lookup, bank/transfer/validate, yucho/convert |
| Identity | mynumber/validate, phone/validate, passport/validate |

---

## License

MIT — examples only. The Torify API service is proprietary.
