# SDK Android — Implementation Tasks: PaymentBrick (SMFINTECH-32897)

**Jira**: [SMFINTECH-32897](https://mercadolibre.atlassian.net/browse/SMFINTECH-32897)
**Repositório**: [`fury_openplatform-sdk-android`](https://github.com/melisource/fury_openplatform-sdk-android)
**Branch principal**: `feature/cardpayment-q2`
**Specs**: [functional](../1-functional/spec.md) · [technical](../2-technical/spec.md) · [BFF tasks](./bricks-api.md)

> **Payment Flows**: As tasks A17–A25 e A27–A29 (fluxos de pagamento) foram extraídas para spec dedicada → [`003-payment-flows/3-tasks/android.md`](../003-payment-flows/3-tasks/android.md)

> **CVV Screen**: As tasks A13–A16 (tela de CVV) foram extraídas para spec dedicada → [`002-cvv-screen/3-tasks/android.md`](../002-cvv-screen/3-tasks/android.md)

> **Revisa e Confirma**: Tudo relacionado à tela de Revisa e Confirma foi extraído para spec dedicada → [`20260622-payment-review-confirm`](../../20260622-payment-review-confirm/)

---

## Bloqueadores

| Bloqueador | Afeta | Status |
|---|---|---|
| Pixel perfect da tela de Installments (`feature/installments-flow`) | A4 — enum `Screen.kt` aguarda merge para `feature/cardpayment-q2` | ✅ Concluído |

---

## Tasks

> **Regra**: toda tarefa deve incluir testes unitários com cobertura mínima de **80%**.

| Task | Arquivo | Descrição | Branch | Status |
|---|---|---|---|---|
| A1 | `MPOrder.kt` | Adicionar `orderId: String` e `clientToken: String` | `feature/installments-flow` / `feature/cardpayment-q2` | ✅ Feito |
| A2 | `MPPaymentData.kt` | Remover campos token-based de `MPPaymentData.Payment` (dívida técnica da branch atual: `transactionAmount`, `payer`, `installment`, `issuerId`) — target fixo: `orderId`, `orderStatus`, `paymentMethodId` e `paymentTypeId` para todos os meios de pagamento, incluindo meios offline (decisão DD-8: callback unificado, sem campos extras como `barcodeContent` ou `dateOfExpiration`) | `feature/cardpayment-q2` | 🔲 Pendente |
| A3 | `MPUserCancelledContext.kt` | Migrar `Payment` de `object` para `data class(screens: List<Screen>)` | `feature/cardpayment-q2` | 🔲 Pendente |
| A4 | `Screen.kt` | Adicionar `OFFLINE_METHOD_SELECTOR` e demais valores ao enum conforme telas implementadas | `feature/installments-flow` | ✅ Feito |
| A5 | Novos modelos | Criar e mapear modelos do response `GET /initialization`: `PaymentBrickInitializationResponse`, `PaymentSection`, `PaymentMethod`, `CardData`, `SecurityCode`, `SecurityCodeScreen`, `Installments`, `Quota`, `TicketOption`, `PaymentBrickFooter` | `feature/cardpayment-q2` | 🔲 Pendente |
| A6 | Camada de repositório `/initialization` | Criar toda a camada de data/domain para `GET /initialization` seguindo a estrutura do módulo `checkout`: `data/remote/datasource/PaymentBrickInitializationRemoteDataSource.kt` (interface + impl), `data/remote/mapper/PaymentBrickInitializationResponseMapper.kt`, `data/repository/PaymentBrickInitializationRepositoryImpl.kt`, `domain/repository/PaymentBrickInitializationRepository.kt` (interface), `domain/mapper/PaymentBrickInitializationMapper.kt` | `feature/cardpayment-q2` | 🔲 Pendente |

| A7 | ViewModel + UseCase `/initialization` | Criar `domain/usecase/FetchPaymentBrickInitializationUseCase.kt` e injetá-lo em `PaymentBrickViewModel.kt` — ViewModel expõe `StateFlow<PaymentBrickScreenState>` com loading, sucesso (seções mapeadas) e erro | `feature/cardpayment-q2` | 🔲 Pendente |

| A8 | Refinamento do layout da tela PaymentBrick | Refinar a `PaymentBrickScreen` com os dados reais vindos do response de `/initialization` via ViewModel — renderizar `sections[]`, `methods[]` com ícone, título e subtítulo, e `footer` com total. Garantir estados de loading e erro | `feature/cardpayment-q2` | 🔲 Pendente |

| A9 | `processOrderUseCase` no ViewModel | Injetar `ProcessOrderUseCase` em `PaymentBrickViewModel` e realizar a chamada a `POST /process` ao confirmar o meio de pagamento — cobre **todos os meios**, incluindo cartão salvo, novo cartão e meios offline (ticket); para offline, o `card_token` é ausente. Mapear response para `MPPaymentData.Payment` e emitir resultado via callback (`onSuccess`, `onError`) | `feature/cardpayment-q2` | 🔲 Pendente |

| A10 | Callback `onSuccess` | Após processamento bem-sucedido da Order, emitir `MercadoPagoCheckoutResult.Success(MPPaymentData.Payment)` para o seller via callback — garantir que o switch é exaustivo (sem `default`/`else`) e que `MPPaymentData.Payment` carrega `orderId`, `orderStatus`, `paymentMethodId` e `paymentTypeId` | `feature/cardpayment-q2` | 🔲 Pendente |

| A11 | Callback `onUserCancelled` | Ao usuário sair do fluxo em qualquer tela, emitir `MercadoPagoCheckoutResult.UserCancelled(MPUserCancelledContext.Payment(screens))` — popular `screens: List<Screen>` com as telas percorridas antes do cancelamento | `feature/cardpayment-q2` | 🔲 Pendente |

| A12 | Callback `onError` | Ao ocorrer erro crítico (5xx, Order inválida, pagamento rejeitado), emitir `MercadoPagoCheckoutResult.Error(MercadoPagoCheckoutError)` para o seller — sem retry automático | `feature/cardpayment-q2` | 🔲 Pendente |


| A26 | Pixel Perfect — tela PaymentBrick | Revisão visual completa da tela seletora de meios com dados reais — validar espaçamentos, tipografia, ícones, footer e estados de loading/erro conforme especificação de design | `feature/cardpayment-q2` | 🔲 Pendente |

---

## Notas

- **Cobertura de testes**: mínimo 80% de cobertura unitária em todas as tasks
- **`cardIds`**: permanece em `MPCheckoutType.Payment` — necessário para o BFF buscar cartões salvos via Customers API
- **Filtros excluídos** (`excludedTypes`, `excludedMethods`): configurados server-side via Order — SDK não os envia
- **Tela de Revisa e Confirma**: tratada em spec separada
- **`Screen` enum**: existe em `domain/model/Screen.kt` com `INSTALLMENTS`. Demais valores adicionados conforme cada tela for entregue
- **Meios offline — callback unificado (DD-8)**: `MPPaymentData.Payment` devolve `orderId`, `orderStatus`, `paymentMethodId` e `paymentTypeId` para todos os meios, incluindo offline. Campos como `barcodeContent`, `dateOfExpiration`, `transactionAmount`, `payer`, `installment` e `issuerId` **não serão expostos** no SDK
