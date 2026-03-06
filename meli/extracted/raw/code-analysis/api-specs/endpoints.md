# API Endpoints — openplatform-sdk-ios

Endpoints REST consumidos pelo SDK. Nao ha OpenAPI spec — extraido do codigo-fonte.

## Base URLs

| Alias | URL | Uso |
|-------|-----|-----|
| `mercadopago` | `https://api.mercadopago.com` | Tokenizacao |
| `cho-off` | `https://api.mercadopago.com/cho-off` | Checkout Off (payment methods, installments) |
| `cho-off-beta` | `https://api.mercadopago.com/cho-off/beta` | 3DS |
| `apple-pay` | `https://api.mercadopago.com/platforms/pci/applepay` | Apple Pay |
| `analytics` | `https://api.mercadolibre.com` | Analytics |

## Endpoints por Feature

### Card Tokenization
| Method | Path | Headers obrigatorios |
|--------|------|---------------------|
| POST | `/v1/card_tokens` | `X-Product-id`, `Meli-Session-id`, `SDK-version` |

Query params: `public_key`

Body: `CardTokenBody` (numero cartao via device fingerprint + campos encriptados)

Response: `CardTokenResponse` → mapeado para `CardToken`

---

### Identification Types
| Method | Path |
|--------|------|
| GET | `cho-off/v1/identification_types` |

Query params: `public_key`

Response: array de `IdentificationType`

---

### Installments
| Method | Path |
|--------|------|
| GET | `cho-off/v1/installments` |

Query params: `public_key`, `amount`, `bin`, `processing_mode`

Response: array de `Installment` (via `InstallmentsMapper`)

---

### Payment Methods
| Method | Path |
|--------|------|
| GET | `cho-off/v1/payment_methods` |

Query params: `public_key`, `bin`, `processing_mode`

Response: array de `PaymentMethod` (via `PaymentMethodMapper`)

---

### Issuers
| Method | Path |
|--------|------|
| GET | `cho-off/v1/card_issuers` |

Query params: `public_key`, `bin`, `payment_method_id`

Response: array de `Issuer`

---

### 3DS — Send Device Data
| Method | Path |
|--------|------|
| POST | `cho-off/beta/v1/challenges/threeds/device` |

Headers: `X-Public-Key`

Body: `MPThreeDSAuthRequestParameters`

---

### 3DS — Get Challenge Parameters
| Method | Path |
|--------|------|
| GET | `cho-off/beta/v1/challenges/threeds/{id}/authenticate` |

Headers: `X-Public-Key`

Response: `MPThreeDSChallengeResponse` → mapeado para `MPThreeDSChallengeParameters`

---

### 3DS — Update Challenge Status
| Method | Path |
|--------|------|
| PATCH | `cho-off/beta/v1/challenges/threeds/{id}/authenticate` |

Headers: `X-Public-Key`

Body: `MPThreeDSUpdateStatusBody` (status: finish/cancel/error/timeout)

---

### Apple Pay — Tokenize
| Method | Path |
|--------|------|
| POST | `apple-pay/v1/tokenize` |

Headers: `X-Public-Key`, `X-Product-id`, `X-Test-Status` (opcional)

Query params: `public_key`

Body: `ApplePayTokenBody` (paymentToken PKPaymentToken serializado)

Response: `MPTokenResponse` → mapeado para `MPApplePayToken`

---

### Analytics
| Method | Path |
|--------|------|
| POST | `https://api.mercadolibre.com/tracks` |

Body: evento de analytics com device info, SDK version, bundle ID, UID

---

## Autenticacao

Todos os endpoints requerem `public_key` como query parameter.

Headers adicionais por endpoint:
- `X-Public-Key`: endpoints 3DS e Apple Pay
- `X-Product-id`: tokenizacao e Apple Pay (valor do SDK)
- `Meli-Session-id`: tokenizacao
- `SDK-version`: tokenizacao
- `X-Test-Status`: Apple Pay (testes)
