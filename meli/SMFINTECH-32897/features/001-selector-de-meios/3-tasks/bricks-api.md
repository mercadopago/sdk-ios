# `fury_bricks-api` — Implementation Tasks: PaymentBrick Nativo (SMFINTECH-32897)

**Jira**: [SMFINTECH-32897](https://mercadolibre.atlassian.net/browse/SMFINTECH-32897)
**Status**: Partial — TASK 1.5 and TASK 6 are blocked (see Blockers section)
**Specs**: [functional](../1-functional/spec.md) · [technical](../2-technical/spec.md)

---

## Blockers

| Blocker | Needed by | Status |
|---|---|---|
| [`fury_bricks-api` PR #433](https://github.com/melisource/fury_bricks-api/pull/433) — `POST /orders/{order_id}/process` base implementation | TASK 1.5 must amend this PR before merge | Open |
| [`fury_bricks-api` PR #448](https://github.com/melisource/fury_bricks-api/pull/448) — excluded filter + MLA accessibility label on `/card_payment_brick/card` | TASK 6 (`/payment_brick/card`) delegates to this service; must be merged first | Open |
| `fury_bricks-api` release/1.47.2 — `Quota` struct with `primary_label`, `secondary_label`, `state`, `tertiary_label`, `accessibility_label` and builder logic | TASK 2 (`initializationservice`) needs the `installmentformat` shared package extracted from this release | Released |

---

## Endpoint Contracts

### 1. `POST /cho-off/v1/orders/{order_id}/process` — MODIFIED (TASK 1.5)

Amends PR #433 to support offline methods (ticket) and saved cards. The existing implementation treats `token` and `installments` as always-required, which breaks for offline payments.

**Path param**: `order_id` (string, required)

**Headers**: `X-Client-Id`, `X-Caller-Id`, `X-Caller-SiteID`, `X-Idempotency-Key`

**Request — card payment (new card or saved card)**:
```json
{
  "amount": "500.00",
  "payment_method_id": "visa",
  "payment_method_type": "credit_card",
  "token": "677859ef5f18ea7e3a87c41d02c3fbe3",
  "installments": 3
}
```

**Request — offline payment (ticket)**:
```json
{
  "amount": "500.00",
  "payment_method_id": "rapipago",
  "payment_method_type": "ticket",
  "payer_email": "comprador@email.com"
}
```

> `token` and `installments` are absent for ticket. `payer_email` is required for ticket, absent for cards.

**Response — card approved** (HTTP 200):
```json
{
  "id": "ORD01J6TC8BYRR0T4ZKY0QR39WGYE",
  "status": "approved",
  "status_detail": "accredited",
  "total_amount": "500.00",
  "transactions": {
    "payments": [
      {
        "id": "PAY01J6TC8BYRR0T4ZKY0QRTZ0E24",
        "amount": "500.00",
        "status": "approved",
        "status_detail": "accredited",
        "payment_method": {
          "id": "visa",
          "type": "credit_card",
          "installments": 3
        }
      }
    ]
  }
}
```

**Response — offline pending** (HTTP 200):
```json
{
  "id": "ORD01J6TC8BYRR0T4ZKY0QR39WGYE",
  "status": "action_required",
  "status_detail": "waiting_payment",
  "total_amount": "500.00",
  "transactions": {
    "payments": [
      {
        "id": "PAY01J6TC8BYRR0T4ZKY0QRTZ0E24",
        "amount": "500.00",
        "status": "action_required",
        "status_detail": "waiting_payment",
        "expiration_time": "P1D",
        "date_of_expiration": "2026-05-26T22:04:01.000-03:00",
        "payment_method": {
          "id": "rapipago",
          "type": "ticket",
          "barcode_content": "3335008800000000006004835002100020000242462010",
          "ticket_url": "https://www.mercadopago.com.ar/payments/..."
        }
      }
    ]
  }
}
```

**Error responses**:
- `400` — missing required fields or invalid amount
- `422` — amount mismatch with Order
- `423` — Order locked (concurrent request)
- `500` — internal error

---

### 2. `GET /cho-off/v1/payment_brick/initialization` — NEW (TASK 2 + TASK 3)

Returns all data needed for the SDK to render the payment method selector screen.

**Headers**: `X-Caller-SiteID`

**Query params**:

| Param | Required | Description |
|---|---|---|
| `public_key` | Yes | Seller public key |
| `order_id` | Yes | Order ID created server-side by the seller |
| `customer_id` | No | Buyer customer ID (enables saved cards section) |
| `cards_ids` | No | Comma-separated card IDs (used with `customer_id`) |
| `excluded_methods` | No | Comma-separated payment method IDs to exclude (e.g. `visa,master`) |
| `excluded_types` | No | Comma-separated payment types to exclude (e.g. `ticket,debit_card`) |
| `excluded_tickets` | No | Comma-separated offline methods to exclude (e.g. `rapipago`) |
| `min_installments` | No | Minimum number of installments to include in quotas (inclusive) |
| `max_installments` | No | Maximum number of installments to include in quotas (inclusive) |

**Response** (HTTP 200):
```json
{
  "header_title": "Elegí cómo pagar",
  "sections": [
    {
      "title": "Otros medios de pago",
      "methods": [
        {
          "type": "saved_card",
          "title": "Visa **** 1234",
          "subtitle": "Visa · Crédito",
          "icon_url": "https://http2.mlstatic.com/storage/mobile-on-demand-resources/image/cho_off-visa_mdpi",
          "card_data": {
            "id": "123456789",
            "bin": "503143",
            "last_four_digits": "1234",
            "payment_method_id": "visa",
            "payment_type_id": "credit_card",
            "issuer_id": 1,
            "security_code": {
              "length": 3,
              "screen": {
                "header_title": "Ingresá el código de seguridad",
                "field": {
                  "label": "Código de seguridad",
                  "placeholder": "Ej.: ***",
                  "helper": "Está en el reverso de tu tarjeta."
                },
                "continue_button_label": "Continuar"
              }
            },
            "installments": {
              "selection_type": "radio_button",
              "quotas": [
                {
                  "installments": 1,
                  "installment_amount": 500.00,
                  "total_amount": 500.00,
                  "primary_label": "1x $ 500,00",
                  "secondary_label": "",
                  "state": "none",
                  "accessibility_label": "1 cuota de 500,00 pesos, sin interés"
                },
                {
                  "installments": 3,
                  "installment_amount": 170.00,
                  "total_amount": 510.00,
                  "primary_label": "3x $ 170,00",
                  "secondary_label": "Sin interés",
                  "state": "success",
                  "accessibility_label": "3 cuotas de 170,00 pesos, sin interés"
                },
                {
                  "installments": 6,
                  "installment_amount": 95.00,
                  "total_amount": 570.00,
                  "primary_label": "6x $ 95,00",
                  "secondary_label": "$ 570,00",
                  "state": "none",
                  "accessibility_label": "6 cuotas de 95,00 pesos"
                }
              ]
            }
          }
        },
        {
          "type": "saved_card",
          "title": "Master **** 5678",
          "subtitle": "Mastercard · Débito",
          "icon_url": "https://http2.mlstatic.com/storage/mobile-on-demand-resources/image/cho_off-master_mdpi",
          "card_data": {
            "id": "987654321",
            "bin": "516105",
            "last_four_digits": "5678",
            "payment_method_id": "master",
            "payment_type_id": "debit_card",
            "issuer_id": 2,
            "security_code": {
              "length": 3
            }
          }
        },
        {
          "type": "ticket",
          "title": "Efectivo",
          "subtitle": "Pago Fácil y Rapipago",
          "options": [
            {
              "id": "pagofacil",
              "name": "Pago Fácil",
              "icon_url": "https://http2.mlstatic.com/storage/mobile-on-demand-resources/image/cho_off-pagofacil_mdpi"
            },
            {
              "id": "rapipago",
              "name": "Rapipago",
              "icon_url": "https://http2.mlstatic.com/storage/mobile-on-demand-resources/image/cho_off-rapipago_mdpi"
            }
          ]
        },
        {
          "type": "new_card",
          "title": "Nueva tarjeta",
          "subtitle": "Crédito y débito",
          "icon_url": "https://http2.mlstatic.com/storage/mobile-on-demand-resources/image/cho_off-new_card_mdpi"
        }
      ]
    }
  ],
  "footer": {
    "total_label": "Total",
    "total_amount": "$ 500,00"
  },
  "translations": {
    "installments": {
      "header": {
        "chevron": "Elegí las cuotas",
        "radio": "Elegí las cuotas",
        "title": "Elegí las cuotas"
      },
      "interest_free_label": "Sin interés",
      "total_label": "Total"
    }
  }
}
```

**Notes**:
- Second saved card (debit, `has_preapproval_scope=true`): `security_code` has no `screen` field → SDK skips CVV; no `installments` field (debit)
- Offline section only present when `order.site_id == "MLA"` (hardcoded Q2.26)
- `footer.total_amount` is `order.total_amount` passed through from Order API
- BFF merges `order.config.payment_method.not_allowed_ids` with `excluded_methods` query param
- `min_installments` / `max_installments` filter the `quotas` array for every saved card: only quotas where `installments >= min_installments` and `installments <= max_installments` are returned. `order.config.payment_method.max_installments` is applied first (server-side cap), then the query-param range is applied on top

**Error responses**:
- `400` — missing `public_key` or `order_id`
- `404` — Order not found
- `500` — internal error

---

### 3. `GET /cho-off/v1/payment_brick/review_confirm` — NEW (TASK 4 + TASK 5)

Returns labels for the "Revisá y Confirmá" screen. Pure BFF logic — no external API calls.

**Query params**:

| Param | Required | Values |
|---|---|---|
| `public_key` | Yes | |
| `order_id` | Yes | |
| `payment_method_type` | Yes | `saved_card` \| `new_card` \| `ticket` \| `wallet` \| `credits` |

**Response — `payment_method_type=ticket`** (HTTP 200):
```json
{
  "header_title": "Revisá los datos antes de crear la factura",
  "confirm_button_label": "Crear factura",
  "change_payment_method_label": "Cambiar medio de pago",
  "items": [
    {
      "type": "payment_method",
      "label": "Medio de pago"
    },
    {
      "type": "payer_email",
      "label": "Email",
      "placeholder": "Ej.: usuario@email.com",
      "is_editable": true
    }
  ]
}
```

**Response — `payment_method_type=saved_card` / `new_card` / `wallet` / `credits`** (HTTP 200):
```json
{
  "header_title": "Revisá los datos antes de pagar",
  "confirm_button_label": "Pagar",
  "change_payment_method_label": "Cambiar medio de pago",
  "items": [
    {
      "type": "payment_method",
      "label": "Medio de pago"
    }
  ]
}
```

**Error responses**:
- `400` — missing required params or unknown `payment_method_type`

---

### 4. `GET /cho-off/v1/payment_brick/card` — NEW (TASK 6) 🔴 Blocked on PR #448

Returns card form configuration when the buyer selects "Nueva tarjeta". Delegates to the existing `cardpaymentbrickservice.CardDataService` after resolving `amount` and payment restrictions from the Order.

**Headers**: `X-Public-Key` (required)

**Query params**:

| Param | Required | Description |
|---|---|---|
| `order_id` | Yes | Replaces `amount` — BFF reads amount from Order API |
| `bin` | Yes | First 6–8 digits of the card entered by the buyer |
| `product_id` | Yes | Caller product ID |

> `amount`, `excluded_payment_methods`, `excluded_payment_types`, and `processing_mode` are all resolved server-side from the Order. The SDK does not send them.

**Response** (HTTP 200) — same shape as `GET /cho-off/v1/card_payment_brick/card`:
```json
{
  "translations": {
    "card_form_title": "Ingresá tu tarjeta",
    "card_form_footer_button_label": "Pagar",
    "card_number": {
      "label": "Número de tarjeta",
      "placeholder": "1234 1234 1234 1234",
      "error_empty_field": "Completá este campo.",
      "error_incomplete_field": "Ingresá el número completo.",
      "error_invalid_field": "Ingresalo como figura en la tarjeta."
    },
    "security_code": {
      "label": "Código de seguridad",
      "placeholder": "Ej.: ***",
      "tooltip": "Es un número de 3 dígitos que está en el reverso de tu tarjeta.",
      "error_empty_field": "Completá este campo.",
      "error_incomplete_field": "Ingresá el código completo."
    },
    "expiration_date": {
      "label": "Fecha de vencimiento",
      "placeholder": "MM/AA",
      "error_empty_field": "Completá este campo.",
      "error_incomplete_field": "Ingresá la fecha completa.",
      "error_invalid_field": "Ingresá una fecha válida."
    },
    "holder_name": {
      "label": "Titular de tarjeta",
      "placeholder": "Ej.: Maria Lopez",
      "helper": "Como aparece en la tarjeta"
    },
    "installments": {
      "header": {
        "chevron": "Elegí las cuotas",
        "radio": "Elegí las cuotas",
        "title": "Elegí las cuotas"
      },
      "interest_free_label": "Sin interés",
      "total_label": "Total"
    }
  },
  "installment": {
    "selection_type": "radio_button",
    "quotas": [
      {
        "installments": 1,
        "installment_amount": 500.00,
        "total_amount": 500.00,
        "primary_label": "1x $ 500,00",
        "secondary_label": "",
        "state": "none",
        "accessibility_label": "1 cuota de $ 500,00. Total $ 500,00. Costo financiero total 0,00%. Tasa Efectiva Anual 0,00%."
      },
      {
        "installments": 3,
        "installment_amount": 170.00,
        "total_amount": 510.00,
        "primary_label": "3x $ 170,00",
        "secondary_label": "Sin interés",
        "state": "success",
        "accessibility_label": "3 cuotas de $ 170,00. Total $ 510,00. Costo financiero total 0,00%. Tasa Efectiva Anual 0,00%."
      }
    ]
  },
  "payment_methods": [
    {
      "id": "visa",
      "payment_type_id": "credit_card",
      "card_number": {
        "type": "Number",
        "length": { "min": 16, "max": 16 },
        "mask": "#### #### #### ####"
      },
      "security_code": {
        "mode": "mandatory",
        "length": 3,
        "type": "Number",
        "tooltip": "Es un número de 3 dígitos que está en el reverso de tu tarjeta.",
        "placeholder": "Ej.: ***"
      },
      "issuers": [
        { "id": "1", "name": "Visa" }
      ]
    }
  ]
}
```

**Notes**:
- MLA accessibility label uses PR #448 format: `"{N} cuota(s) de $ {amount}. Total $ {total}. Costo financiero total X%. Tasa Efectiva Anual Y%."`
- `order.config.payment_method.not_allowed_ids` forwarded as `excluded_payment_methods` to the delegate service
- `order.config.payment_method.max_installments` caps quotas in post-processing

**Error responses**:
- `400` — missing `X-Public-Key`, `order_id`, or `bin`; access token used as public key
- `404` — Order not found or payment method not found for BIN
- `500` — internal error

---

## Task Summary

| Task | Description | Status |
|---|---|---|
| TASK 1 | Extend `orders.Order` domain model (`processing_mode`, `site_id`, `config`) | Ready to implement |
| TASK 1.5 | Update `POST /process` for offline (ticket) + saved cards — amends PR #433 | Ready to implement |
| TASK 2 | `initializationservice` — orchestrates Order API, Customers API, Installments API; applies `min_installments`/`max_installments` filter on quotas | Ready to implement |
| TASK 3 | Handler `GET /payment_brick/initialization` | Ready to implement |
| TASK 4 | `reviewconfirmservice` — pure BFF labels by payment type | Ready to implement |
| TASK 5 | Handler `GET /payment_brick/review_confirm` | Ready to implement |
| TASK 6 | `paymentbrickcarddataservice` + Handler `GET /payment_brick/card` | 🔴 Blocked on PR #448 |
| TASK 7 | App wiring (`app.go`, `routes.go`, `config.go`) | ✅ Done (PR #469) |
| TASK 8 | Bruno docs + Swagger | Ready to implement |

Full implementation details: [bricks-api.md](./bricks-api.md)
