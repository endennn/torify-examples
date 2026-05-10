/**
 * x402 autonomous payment example
 * Agent pays $0.02 USDC (Base L2) automatically — no manual approval needed.
 *
 * Setup:
 *   npm install x402-fetch viem
 *   export PRIVATE_KEY="0x..."   # Base mainnet wallet with USDC
 */

import { wrapFetchWithPayment } from "x402-fetch";
import { createWalletClient, http } from "viem";
import { base } from "viem/chains";
import { privateKeyToAccount } from "viem/accounts";

const account = privateKeyToAccount(process.env.PRIVATE_KEY as `0x${string}`);
const wallet = createWalletClient({ account, chain: base, transport: http() });
const fetch402 = wrapFetchWithPayment(fetch, wallet);

async function main() {
  const BASE = "https://torify.dev/v1";

  // Invoice registry lookup ($0.02 per call)
  const invoiceRes = await fetch402(`${BASE}/invoice/verify?number=T8010401050783`);
  const invoice = await invoiceRes.json();
  console.log("Invoice verify:", invoice.data);
  // { registered: true, registrantName: '国税庁', confidence: 0.99 }

  // Corporate number lookup ($0.02 per call)
  const houjinRes = await fetch402(`${BASE}/houjin/lookup?number=8010401050783`);
  const houjin = await houjinRes.json();
  console.log("Corporate lookup:", houjin.data);
  // { name: '国税庁', address: '東京都千代田区...', status: 'active' }

  // Address normalization ($0.02 per call)
  const addrRes = await fetch402(
    `${BASE}/address/normalize?address=${encodeURIComponent("東京都千代田区霞が関3丁目1番1号")}`
  );
  const addr = await addrRes.json();
  console.log("Address:", addr.data);
}

main().catch(console.error);
