# Security Policy

## Supported Versions

We actively maintain and release security fixes for the following versions:

| Version | Supported |
|---------|-----------|
| Latest stable | ✅ |
| Previous minor | ✅ (critical fixes only) |
| Older versions | ❌ |

We strongly recommend always using the latest version of the SDK to receive security patches and PCI DSS compliance updates.

---

## Reporting a Vulnerability

**Do not open a public GitHub issue for security vulnerabilities.**

To report a security issue, please use one of the following channels:

- **GitHub Private Security Advisory:** [Report a vulnerability](../../security/advisories/new) *(preferred)*
- **Email:** developers@mercadopago.com (Subject: `[SECURITY] sdk-ios - <description>`)

### What to include

- Clear description of the vulnerability
- Steps to reproduce or a proof-of-concept (if safe to share)
- Potential impact and affected versions
- Suggested fix (optional)

---

## Response Timeline

| Severity | Initial Response | Fix Target |
|---|---|---|
| Critical | 24 hours | 48–72 hours |
| High | 48 hours | 1 week |
| Medium | 1 week | 2–4 weeks |
| Low | 2 weeks | Next release |

---

## Scope

Covers all modules under the `MercadoPagoSDK` Swift package:
- `CoreMethods`, `MPCore`, `MPComponents`, `MPFoundation`, `MercadoPagoCheckout`, `MPAnalytics`, `MPApplePay`, `MPExtended`

Out of scope: third-party dependencies, backend API, Example app.

---

## Security Design

Key properties (PCI DSS compliant):

- **PCI data in memory only** — card fields use `@State` / in-memory bindings, never `@AppStorage`, `UserDefaults`, or any file write
- **No plaintext card data on disk** — never written to `UserDefaults`, unencrypted `Keychain` entries, `NSFileManager`, or crash/analytics reporters
- **Public key handling** — passed via `MercadoPagoSDK.Configuration`; never committed to source code or bundled in binary resources
- **Tokenization** — card data tokenized server-side; never stored raw beyond the active checkout session
- **Network security** — HTTPS/TLS enforced via App Transport Security (ATS); `NSAllowsArbitraryLoads` must remain `false`

---

## Integrator Responsibilities

1. Keep the SDK up to date
2. Never log PCI data (PAN, CVV, expiry) via `print`, `os_log`, or third-party crash/analytics SDKs
3. Never store PCI data in `UserDefaults`, files, or unencrypted `Keychain` entries
4. Scope ViewModels appropriately — avoid retaining payment state beyond the checkout flow
5. Keep `NSAllowsArbitraryLoads = false` in your `Info.plist`
6. Review Apple's [Secure Coding Guide](https://developer.apple.com/documentation/security) for additional hardening
