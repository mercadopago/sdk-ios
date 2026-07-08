# PaymentBrick Nativo — Selector de Meios

**Feature**: `001-selector-de-meios`
**Jira**: [SMFINTECH-32897](https://mercadolibre.atlassian.net/browse/SMFINTECH-32897)
**Owner**: Danielle Ogawa / William Santos (Core Frontend)
**Quarter**: 2026-Q2
**Site**: MLA (Argentina)

---

## O que foi especificado

SDK de checkout nativo (Android + iOS) com tela de seleção de meios de pagamento integrada à Order API no modelo Order Builder Mode.

- **Seller** cria a Order com `payment_settings` no backend
- **SDK** recebe `orderId` + `clientToken` e renderiza a tela seletora via BFF
- **BFF** (`fury_bricks-api`) processa o pagamento — `card_token` nunca exposto ao seller
- **Seller** recebe o resultado via callback (`onSuccess` / `onError` / `onUserCancelled`)

## Escopo Q2.26

| Entregável | Plataformas |
|---|---|
| Tela seletora de meios (cartões salvos, novo cartão, offline) | Android + iOS |
| Fluxo de CVV | Android + iOS (spec separada: `002-cvv-screen`) |
| Fluxos de pagamento (novo cartão, cartão salvo, offline) | Android + iOS (spec separada: `003-payment-flows`) |
| Tela de Revisa e Confirma | Android + iOS (spec separada: `20260622-payment-review-confirm`) |
| BFF endpoints `/cho-off/v1/*` | `fury_bricks-api` (Go) |

## Repositórios de implementação

| Repositório | Linguagem | Papel |
|---|---|---|
| `fury_openplatform-sdk-android` | Kotlin | SDK Android — módulo `mercadopagocheckout` |
| `fury_openplatform-sdk-ios` | Swift | SDK iOS — módulo `mercadopagocheckout` |
| `fury_bricks-api` | Go | BFF — endpoints `cho-off/v1/*` |

## Specs

- [Functional Spec](1-functional/spec.md)
- [Technical Spec](2-technical/spec.md)
- [Tasks Android](3-tasks/android.md)
- [Tasks iOS](3-tasks/ios.md)
- [Tasks BFF](3-tasks/bricks-api.md)

## Decisões arquiteturais chave

- **Order Builder Mode**: configurações sensíveis (`amount`, `customerId`, `cardIds`, filtros) nunca passam pelo SDK — resolvidos via Order API no BFF
- **iOS**: `MPOrder` tem shape final `orderId` + `clientToken` (endgame antecipado)
- **Android**: `MPOrder` com `orderId`, `clientToken`, `amount`, `payer` — remoção de `amount`/`payer` planejada
- **Callbacks type-safe**: generics garantem que o tipo de `MPPaymentData` é inferido do `CheckoutType`
- **Sem retry no `/process`**: evita duplo processamento da Order
