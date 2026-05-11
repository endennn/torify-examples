# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in **torify-examples** or the **Torify API**
(`torify.dev`), please report it privately.

### Contact

- **Email**: contact@torify.dev
- **Subject prefix**: `[security]`
- **DO NOT** open a public GitHub issue for security reports.

### What to include

- A clear description of the vulnerability
- Steps to reproduce
- Affected endpoint(s) or example file(s)
- Your assessment of impact (information disclosure / DoS / payment bypass / etc.)
- Optional: suggested mitigation

### Response timeline

- **Acknowledgement**: within 48 hours
- **Initial assessment**: within 5 business days
- **Fix or mitigation**: depends on severity (critical issues: 7 days, others: 30 days)

### Scope

This repository (`torify-examples`) contains **example code only** — no production
credentials, no live secrets. Vulnerabilities should typically relate to:

- Example code suggesting insecure patterns
- Outdated dependencies with known CVEs
- Sample configurations exposing user data

For vulnerabilities in the **Torify API itself** (`https://torify.dev/v1/*`,
`https://torify-mcp.torify.workers.dev`), the same contact applies.

### Out of scope

- Issues caused by users modifying example code in unsafe ways
- Theoretical attacks without practical impact (e.g., timing analysis without exploit)
- Vulnerabilities in third-party services this repo references (Cloudflare,
  LemonSqueezy, NTA, Yahoo! JLP — report to those vendors directly)

### Bug bounty

No formal bounty program at this time. Researchers who report valid vulnerabilities
will be credited in release notes (with permission).

---

*Last updated: 2026-05-11*
