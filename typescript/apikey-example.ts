/**
 * API Key subscription example ($49/mo Pro — 10,000 calls/month, no crypto wallet needed)
 *
 * Setup:
 *   npm install
 *   export TORIFY_API_KEY="your-key"
 *   # Or use free trial (100 calls/month):
 *   export TRIAL_KEY="tk_..."   # https://torify.dev/trial
 */

const API_KEY = process.env.TORIFY_API_KEY ?? "";
const TRIAL_KEY = process.env.TRIAL_KEY ?? "";
const BASE = "https://torify.dev/v1";

// Prefer Trial key for demos; fall back to API key
const authHeaders: Record<string, string> = TRIAL_KEY
  ? { "X-Trial-Key": TRIAL_KEY }
  : API_KEY
  ? { "X-API-Key": API_KEY }
  : {};

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

async function get(path: string) {
  const res = await fetch(`${BASE}${path}`, { headers: authHeaders });
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
  const validated = await fetch(`${BASE}/invoice/validate?number=T7000012050002`).then(r => r.json());
  console.log("Invoice valid:", validated.data.valid); // true

  // These require API key or Trial key:

  // Address normalization — 通常住所 (block)
  const address = (await get(
    `/address/normalize?address=${encodeURIComponent("東京都千代田区霞が関3丁目1番1号")}`
  )) as NormalizeResponse;
  console.log("Address (block):", address.data);
  // { prefecture: '東京都', city: '千代田区', town: '霞が関',
  //   addressType: 'block', streetRef: null, addressee: null }

  // NEW: 京都通り名 — addressType=street, streetRef populated
  const kyoto = (await get(
    `/address/normalize?address=${encodeURIComponent("京都府京都市中京区烏丸通三条上る場之町")}`
  )) as NormalizeResponse;
  console.log("Address (street / Kyoto):", kyoto.data);
  // { prefecture: '京都府', city: '京都市中京区',
  //   addressType: 'street',
  //   streetRef: { intersection: '烏丸通三条上る', direction: '上る' },
  //   addressee: null }

  // NEW: 方書 (様方) — addressee 分離
  const kata = (await get(
    `/address/normalize?address=${encodeURIComponent("東京都港区赤坂2-3-4 山田様方")}`
  )) as NormalizeResponse;
  console.log("Address (方書):", kata.data);
  // { prefecture: '東京都', city: '港区', town: '赤坂',
  //   addressType: 'block', streetRef: null, addressee: '山田' }

  // NEW: 漢数字 1-99 → Arabic 自動変換
  const kanji = (await get(
    `/address/normalize?address=${encodeURIComponent("東京都港区赤坂二丁目")}`
  )) as NormalizeResponse;
  console.log("Address (漢数字→Arabic):", kanji.data?.town);
  // '赤坂2丁目'  ← '二' → '2' auto-converted

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
