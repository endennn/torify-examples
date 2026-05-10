/**
 * API Key subscription example ($49/mo — 10,000 calls, no crypto wallet needed)
 *
 * Setup:
 *   npm install
 *   export TORIFY_API_KEY="your-key"
 */

const API_KEY = process.env.TORIFY_API_KEY ?? "";
const BASE = "https://torify.dev/v1";

const headers = { "X-API-Key": API_KEY };

async function get(path: string) {
  const res = await fetch(`${BASE}${path}`, { headers });
  return res.json();
}

async function main() {
  // Wareki conversion (no API key required for this endpoint)
  const wareki = await fetch(`${BASE}/wareki/convert?direction=g2w&date=2024-05-01`).then(r => r.json());
  console.log("Wareki:", wareki.data);
  // { era: '令和', eraYear: 6, formatted: '令和6年5月1日' }

  // Postal lookup (no API key required)
  const postal = await fetch(`${BASE}/postal/lookup?zipcode=1000013`).then(r => r.json());
  console.log("Postal:", postal.data);
  // { prefecture: '東京都', city: '千代田区', town: '霞が関' }

  // Invoice format validation (no API key required)
  const validated = await fetch(`${BASE}/invoice/validate?number=T8010401050783`).then(r => r.json());
  console.log("Invoice valid:", validated.data.valid); // true

  // These require API key:

  // Address normalization
  const address = await get(`/address/normalize?address=${encodeURIComponent("東京都千代田区霞が関3丁目1番1号")}`);
  console.log("Address:", address.data);

  // Name romanization (Hepburn style, passport-compatible)
  const name = await get(`/name/romanize?name=山田太郎`);
  console.log("Romanized:", name.data);
  // { romaji: 'Yamada Taro', style: 'hepburn' }

  // Kanji → Hiragana
  const kana = await get(`/kanji/to-kana?text=東京都千代田区`);
  console.log("Kana:", kana.data);
  // { result: 'とうきょうとちよだく' }

  // Bank code lookup
  const bank = await get(`/bank/lookup?bankCode=0001`);
  console.log("Bank:", bank.data);
}

main().catch(console.error);
