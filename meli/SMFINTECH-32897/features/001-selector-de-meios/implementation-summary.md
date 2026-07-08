# Implementation Summary — 001-selector-de-meios

**Arquivado em**: 2026-07-07
**Status final**: Specs aprovadas — implementação em andamento nos repositórios de código

---

## Timeline de especificação

| Fase | Data | Responsável |
|---|---|---|
| Functional spec iniciada | 2026-04-12 | Danielle Ogawa |
| Functional spec aprovada | 2026-05-22 | Danielle Ogawa |
| Technical spec aprovada | 2026-05-25 | Danielle Ogawa |
| Spec iterada (alinhamento com código) | 2026-07-07 | Danielle Ogawa |

## Iterações da spec técnica

- **Iteração 1** (2026-07-07): alinhamento com estado atual dos SDKs
  - Android: `MPCheckoutType.Payment` removeu `cardIds`; tipo param atualizado para `MPUserCancelledContext.Payment`
  - Android: `MPUserCancelledContext.CardTransaction` ganhou campo `screens`; `Screen` enum com 3 novos valores
  - iOS: `CheckoutType.payment` implementado; `MPOrder` com shape final `orderId` + `clientToken`
  - Decisão resolvida: `customerId` e `cardIds` também server-side

## Specs derivadas (extraídas desta)

| Feature | Conteúdo |
|---|---|
| `002-cvv-screen` | Tela de CVV — spec funcional e técnica dedicada |
| `003-payment-flows` | Fluxos de pagamento (novo cartão, cartão salvo, offline) |
| `20260622-payment-review-confirm` | Tela de Revisa e Confirma |

## Pendências de implementação conhecidas

| Item | Plataforma | Status |
|---|---|---|
| `MPPaymentData.Payment` | iOS | Pendente |
| `MPUserCancelledContext.payment` | iOS | Pendente |
| `Screen.CVV` no enum | Android | Pendente |
| Remoção de `amount`/`payer` do `MPOrder` | Android | Planejado |
