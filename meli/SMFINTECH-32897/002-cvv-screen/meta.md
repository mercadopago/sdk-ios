# Feature Metadata

**Feature Name**: cvv-screen
**Feature Number**: 002
**Feature ID**: feat-002
**Mode**: extraction
**Project Type**: production
**User Profile**: technical
**Created**: 2026-06-25
**Last Updated**: 2026-07-07
**Current Stage**: functional-approved

---

## Context

```yaml
context:
  repository_type: specs-only
  initiative: SMFINTECH-32897
  quarter: 2026-Q2
  description: "Tela de CVV — extraída do Selector de Meios (feat-001)"
  branch: feature/cvv-screen
  parent_feature: 001-selector-de-meios
  note: "Separação da tela de CVV para spec e tasks dedicadas."
```

---

## Team

**Owner**: William Santos
**Team Members**: Core Frontend

---

## Stage History

```yaml
stages:
  functional:
    started: 2026-06-25
    completed: 2026-06-25
    status: approved
    owner: Danielle Nozaki Ogawa

  technical:
    started: null
    completed: null
    status: pending

  tasks:
    started: null
    completed: null
    status: pending

  implementation:
    started: null
    completed: null
    status: pending
```

---

## Notes

- Extraído de 001-selector-de-meios para isolar a tela de CVV em spec dedicada
- Tasks Android: A13–A16 (extraídas do android.md do selector-de-meios)
- Tasks iOS: I13–I16 (extraídas do ios.md do selector-de-meios)
- **2026-07-03**: tasks e spec técnica iOS revisadas e reescritas (I13–I24 → I13–I20) após validação contra o código real de `fury_openplatform-sdk-ios@feature/cardpayment-q2` — a versão herdada de 001-selector-de-meios inventava pastas/modelos/use cases (`Presentation/CVV/`, `FooterState`/`ButtonState`, `FetchSecurityCodeScreenUseCase`, `GenerateTokenWithCardIdUseCase`) sem checar `CardFormBrick`/`PaymentBrick` como referência. Tasks Android não foram revisadas nesta passada.
- **2026-07-07**: I13 (iOS) redesenhada a pedido do owner do SDK — eliminado o wrapper `Item.CardData`; identidade do cartão (`paymentMethodId`/`paymentTypeId`/`issuerId`) migrou direto para `Item`, e `length`/`field.error` migraram para dentro de `SecurityCodeScreenOutput`, tornando o model autossuficiente sem precisar estender `Configuration` do `SecurityCodeViewModel`. Numeração compactada para I13–I19 (a antiga I16 deixou de existir).
- **2026-07-07 (2ª rodada)**: `SecurityCodeScreen` corrigida para não guardar `item`/`transactionAmount` como propriedades próprias (quebrava o contrato de View já usado por `EmailScreen`/`CardFormScreen`) — ambos migraram para `SecurityCodeViewModel.Configuration`, exposto à View via computed properties (`cardTitle`, `amount`).
- **2026-07-07 (3ª rodada)**: `paymentMethodId`/`paymentTypeId`/`issuerId`/`securityCodeScreen` voltaram a ser agrupados — agora em `Item.cardData: CardData?` — porque 4 optionals soltos em `Item` permitiam estados inválidos (ex.: `paymentMethodId` presente sem `paymentTypeId`) que nunca ocorrem na prática. Um único `nil`-check em `cardData` protege os 4 de uma vez; `securityCodeScreen` fica aninhado dentro dele (opcionalidade independente, um nível abaixo).
