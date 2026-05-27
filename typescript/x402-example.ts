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

// v0.3.0+ address normalize response schema
interface NormalizeResponse {
  ok: boolean;
  data?: {
    prefecture: string | null;
    city: string | null;
    town: string | null;
    streetNumber: string | null;
    streetNumberHyphen: string | null;
    streetNumberFormal: string | null;
    addressType: "block" | "street" | "rural" | "other"; // NEW: first-class enum
    streetRef: {                                          // NEW: Kyoto intersection
      intersection: string;
      direction: "上る" | "下る" | "東入" | "西入" | null;
    } | null;
    addressee: string | null;                             // NEW: 様方/気付/c/o separated
  };
}

const account = privateKeyToAccount(process.env.PRIVATE_KEY as `0x${string}`);
const wallet = createWalletClient({ account, chain: base, transport: http() });
const fetch402 = wrapFetchWithPayment(fetch, wallet);

async function main() {
  const BASE = "https://torify.dev/v1";

  // Invoice registry lookup ($0.02 per call)
  const invoiceRes = await fetch402(`${BASE}/invoice/verify?number=T1180301018771`);
  const invoice = await invoiceRes.json();
  console.log("Invoice verify:", invoice.data);
  // { registered: true, registrantName: 'トヨタ自動車株式会社', confidence: 0.99 }

  // Corporate number lookup ($0.02 per call)
  const houjinRes = await fetch402(`${BASE}/houjin/lookup?number=7000012050002`);
  const houjin = await houjinRes.json();
  console.log("Corporate lookup:", houjin.data);
  // { name: '国税庁', address: '東京都千代田区...', status: 'active' }

  // Address normalization — 通常住所 (block) ($0.02 per call)
  const addrRes = await fetch402(
    `${BASE}/address/normalize?address=${encodeURIComponent("東京都千代田区霞が関3丁目1番1号")}`
  );
  const addr = (await addrRes.json()) as NormalizeResponse;
  console.log("Address (block):", addr.data);
  // { prefecture: '東京都', city: '千代田区', town: '霞が関',
  //   addressType: 'block', streetRef: null, addressee: null }

  // NEW: 京都通り名 — addressType=street, streetRef populated ($0.02 per call)
  const kyotoRes = await fetch402(
    `${BASE}/address/normalize?address=${encodeURIComponent("京都府京都市中京区烏丸通三条上る場之町")}`
  );
  const kyoto = (await kyotoRes.json()) as NormalizeResponse;
  console.log("Address (street / Kyoto):", kyoto.data);
  // { prefecture: '京都府', city: '京都市中京区',
  //   addressType: 'street',
  //   streetRef: { intersection: '烏丸通三条上る', direction: '上る' },
  //   addressee: null }

  // NEW: 方書 (様方) — addressee 分離 ($0.02 per call)
  const kataRes = await fetch402(
    `${BASE}/address/normalize?address=${encodeURIComponent("東京都港区赤坂2-3-4 山田様方")}`
  );
  const kata = (await kataRes.json()) as NormalizeResponse;
  console.log("Address (方書):", kata.data);
  // { prefecture: '東京都', city: '港区', town: '赤坂',
  //   addressType: 'block', streetRef: null, addressee: '山田' }

  // NEW: 漢数字 → Arabic 自動変換 ($0.02 per call)
  const kanjiRes = await fetch402(
    `${BASE}/address/normalize?address=${encodeURIComponent("東京都港区赤坂二丁目")}`
  );
  const kanji = (await kanjiRes.json()) as NormalizeResponse;
  console.log("Address (漢数字→Arabic):", kanji.data?.town);
  // '赤坂2丁目'  ← '二' → '2' auto-converted
}

main().catch(console.error);
