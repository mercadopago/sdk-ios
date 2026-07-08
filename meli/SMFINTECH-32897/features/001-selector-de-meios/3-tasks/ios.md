# SDK iOS — Implementation Tasks: PaymentBrick (SMFINTECH-32897)

**Jira**: [SMFINTECH-32897](https://mercadolibre.atlassian.net/browse/SMFINTECH-32897)
**Repositório**: [`fury_openplatform-sdk-ios`](https://github.com/melisource/fury_openplatform-sdk-ios)
**Branch principal**: `feature/cardpayment-q2`
**Specs**: [functional](../1-functional/spec.md) · [technical](../2-technical/spec.md) · [BFF tasks](./bricks-api.md)

> **Payment Flows**: As tasks I17–I25 e I27–I28 (fluxos de pagamento) foram extraídas para spec dedicada → [`003-payment-flows/3-tasks/ios.md`](../003-payment-flows/3-tasks/ios.md)

> **CVV Screen**: As tasks I13–I16 (tela de CVV) foram extraídas para spec dedicada → [`002-cvv-screen/3-tasks/ios.md`](../002-cvv-screen/3-tasks/ios.md)

> **Revisa e Confirma**: Tudo relacionado à tela de Revisa e Confirma foi extraído para spec dedicada → [`20260622-payment-review-confirm`](../../20260622-payment-review-confirm/)

---

## Bloqueadores

| Bloqueador | Afeta | Status |
|---|---|---|
| Pixel perfect da tela de Installments (`feature/checkout/card_payment_installments`) | I1 aguarda merge para `feature/cardpayment-q2` | ✅ Concluído |

---

## Tasks

> **Regra**: toda tarefa deve incluir testes unitários com cobertura mínima de **80%**.

| Task | Arquivo | Descrição | Branch | Status |
|---|---|---|---|---|
| I1 | `MPOrder.swift` | Adicionar `orderId: String` | `feature/checkout/card_payment_installments` | ✅ Feito |
| I2 | `MercadoPagoCheckout+CheckoutType.swift` | Adicionar caso `payment(order:)` entregando `MPPaymentData.Payment` | `feature/cardpayment-q2` | 🔲 Pendente |
| I3 | `MPPaymentData.swift` | Adicionar variant `Payment` com campos Order-based: `orderId`, `orderStatus`, `paymentMethodId` e `paymentTypeId` — contrato unificado para todos os meios, incluindo offline (decisão DD-8) | `feature/cardpayment-q2` | 🔲 Pendente |
| I4 | `MPUserCancelledContext.swift` | Adicionar `Payment` com `screens: List<Screen>` | `feature/cardpayment-q2` | 🔲 Pendente |
| I5 | Novos modelos | Criar e mapear modelos do response `GET /initialization`: `PaymentBrickInitializationResponse`, `PaymentSection`, `PaymentMethod`, `CardData`, `SecurityCode`, `SecurityCodeScreen`, `Installments`, `Quota`, `TicketOption`, `PaymentBrickFooter` | `feature/cardpayment-q2` | 🔲 Pendente |
| I6 | Camada de repositório `/initialization` | Criar toda a camada de data para `GET /initialization` seguindo a estrutura do módulo `MercadoPagoCheckout`: `Data/Network/PaymentBrickInitializationEndpoint.swift`, `Data/Repositories/RemotePaymentBrickInitializationRepository.swift`, `Domain/Repositories/PaymentBrickInitializationRepository.swift` (protocol) | `feature/cardpayment-q2` | 🔲 Pendente |

| I7 | ViewModel + UseCase `/initialization` | Criar `Domain/UseCases/FetchPaymentBrickInitializationUseCase.swift` e injetá-lo em `PaymentBrickViewModel.swift` — ViewModel expõe `@Published` state com loading, sucesso (seções mapeadas) e erro | `feature/cardpayment-q2` | 🔲 Pendente |

| I8 | Refinamento do layout da tela PaymentBrick | Refinar a `PaymentBrickScreen` com os dados reais vindos do response de `/initialization` via ViewModel — renderizar `sections[]`, `methods[]` com ícone, título e subtítulo, e `footer` com total. Garantir estados de loading e erro | `feature/cardpayment-q2` | 🔲 Pendente |

| I9 | `processOrderUseCase` no ViewModel | Injetar `ProcessOrderUseCase` em `PaymentBrickViewModel` e realizar a chamada a `POST /process` ao confirmar o meio de pagamento — mapear response para `MPPaymentData.Payment` e emitir resultado via callback (`onSuccess`, `onError`) | `feature/cardpayment-q2` | 🔲 Pendente |

| I10 | Callback `onSuccess` | Após processamento bem-sucedido da Order, emitir `MercadoPagoCheckoutResult.Success(MPPaymentData.Payment)` para o seller via callback — garantir que o switch é exaustivo (sem `default`/`else`) e que `MPPaymentData.Payment` carrega `orderId`, `orderStatus`, `paymentMethodId` e `paymentTypeId` | `feature/cardpayment-q2` | 🔲 Pendente |

| I11 | Callback `onUserCancelled` | Ao usuário sair do fluxo em qualquer tela, emitir `MercadoPagoCheckoutResult.UserCancelled(MPUserCancelledContext.Payment(screens))` — popular `screens: List<Screen>` com as telas percorridas antes do cancelamento | `feature/cardpayment-q2` | 🔲 Pendente |

| I12 | Callback `onError` | Ao ocorrer erro crítico (5xx, Order inválida, pagamento rejeitado), emitir `MercadoPagoCheckoutResult.Error(MercadoPagoCheckoutError)` para o seller — sem retry automático | `feature/cardpayment-q2` | 🔲 Pendente |


| I26 | Pixel Perfect — tela PaymentBrick | Revisão visual completa da tela seletora de meios com dados reais — validar espaçamentos, tipografia, ícones, footer e estados de loading/erro conforme especificação de design | `feature/cardpayment-q2` | 🔲 Pendente |
| I29 | Implementar caso `payment` no builder `MPCheckoutType` | Adicionar `clientToken: String` a `MPOrder.swift` e implementar o caso `payment(order: MPOrder, cardIds: [String]?)` em `MercadoPagoCheckout+CheckoutType.swift`, entregando `MPPaymentData.Payment` — alinhado ao contrato Android; `orderId` e `clientToken` são passados via `MPOrder`; `cardIds` permanece no SDK para o BFF buscar cartões salvos via Customers API | `feature/cardpayment-q2` | 🔲 Pendente |


---

## Notas

- **Cobertura de testes**: mínimo 80% de cobertura unitária em todas as tasks
- **`cardIds`**: permanece em `MPCheckoutType.Payment` — necessário para o BFF buscar cartões salvos via Customers API
- **Filtros excluídos** (`excludedTypes`, `excludedMethods`): configurados server-side via Order — SDK não os envia
- **Tela de Revisa e Confirma**: tratada em spec separada
- **`Screen` enum**: a criar em Swift alinhado ao Android (`INSTALLMENTS` + demais conforme entrega)
- **Tracks Melidata**: cobertos pela task **A29** no spec Android — task única para análise e implementação nas duas plataformas
