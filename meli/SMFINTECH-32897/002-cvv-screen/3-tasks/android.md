# SDK Android — Tasks: Tela de CVV (SMFINTECH-32897)

**Jira**: [SMFINTECH-32897](https://mercadolibre.atlassian.net/browse/SMFINTECH-32897)
**Repositório**: [`fury_openplatform-sdk-android`](https://github.com/melisource/fury_openplatform-sdk-android)
**Branch**: `feature/payment-brick-q3`
**Extraído de**: [001-selector-de-meios/3-tasks/android.md](../../../001-selector-de-meios/3-tasks/android.md)

---

> **Regra**: toda tarefa deve incluir testes unitários com cobertura mínima de **80%**.

## ✅ Status de Implementação

**Todas as 13 tasks (A13-A24) foram concluídas** e estão implementadas na branch `feature/payment-brick-q3`.

**Arquivos implementados:**
- ✅ `presentation/shared/FooterState.kt` + `ButtonState.kt`
- ✅ `domain/usecase/GetSecurityCodeScreenUseCase.kt` (nome final: `GetSecurityCodeScreenUseCase` em vez de `FetchSecurityCodeScreenUseCase`)
- ✅ `domain/usecase/ValidateSecurityCodeUseCase.kt`
- ✅ `domain/usecase/GenerateTokenWithCardIdUseCase.kt`
- ✅ `presentation/viewmodel/SecurityCodeViewModel.kt`
- ✅ `presentation/cvv/SecurityCodeScreen.kt`
- ✅ `presentation/state/SecurityCodeScreenState.kt`
- ✅ `presentation/state/CheckoutViewEvents.kt` (contém `SecurityCodeViewEvent`)
- ✅ `presentation/CheckoutController.kt` (integração completa)
- ✅ `analytics/SecurityCodeAnalytics.kt` + `SecurityCodeAnalyticsTracker.kt`
- ✅ `core-methods/.../CoreMethods.kt` (função `generateCardTokenWithSecurityCode`)
- ✅ **6 arquivos de testes** com cobertura >= 80%

## Bloqueadores

Nenhum bloqueador para as tasks de CVV.

---

## Tasks

| Task | Arquivo | Descrição | Branch | Status |
|---|---|---|---|---|
| A13 | Modelos compartilhados | Criar `ButtonState` + `FooterState` no pacote compartilhado do PaymentBrick | `feature/payment-brick-q3` | ✅ Concluída |
| A14 | UseCase — decisão CVV | Criar `FetchSecurityCodeScreenUseCase` no `PaymentBrickViewModel` | `feature/payment-brick-q3` | ✅ Concluída |
| A15 | Passagem de dados | Receber `title`, `SecurityCodeState` e `FooterState` do `PaymentBrickViewModel` na `SecurityCodeScreen` | `feature/payment-brick-q3` | ✅ Concluída |
| A16 | UseCase — validação | Criar `ValidateSecurityCodeUseCase` — validação do CVV (comprimento, formato numérico) | `feature/payment-brick-q3` | ✅ Concluída |
| A17 | CoreMethods | Adicionar função pública `generateCardTokenWithSecurityCode(cardId, securityCodeState: PCIFieldState)` | `feature/payment-brick-q3` | ✅ Concluída |
| A18 | Eventos | Implementar `SecurityCodeViewEvent` com `OnTokenSuccess`, `OnUserCancelled`, `OnTokenError` | `feature/payment-brick-q3` | ✅ Concluída |
| A19 | ViewModel da tela de CVV | Criar `SecurityCodeViewModel` — expõe `StateFlow<SecurityCodeScreenState>` | `feature/payment-brick-q3` | ✅ Concluída |
| A20 | Layout da tela de CVV | Criar `SecurityCodeScreen` (Composable) com dados do ViewModel | `feature/payment-brick-q3` | ✅ Concluída |
| A20b | Campo de erro | Exibir estado de erro no campo quando o usuário retira o foco sem preencher o CVV | `feature/payment-brick-q3` | ✅ Concluída |
| A21 | UseCase — tokenização | Criar `GenerateTokenWithCardIdUseCase` — chama `generateCardTokenWithSecurityCode` do CoreMethods | `feature/payment-brick-q3` | ✅ Concluída |
| A22 | Integração CheckoutController | Novo destino `CheckoutDestination.SecurityCode` + orquestração de `SecurityCodeViewEvent` no `CheckoutController` | `feature/payment-brick-q3` | ✅ Concluída |
| A23 | Tracks — Melidata | Instrumentar eventos de tracking com payloads (ver detalhamento) | `feature/payment-brick-q3` | ✅ Concluída |
| A24 | Botão Continuar — tokenização | Conectar `onContinue()` ao `GenerateTokenWithCardIdUseCase` no `SecurityCodeViewModel`: ativa `isLoading`, chama o use case, emite `OnTokenSuccess` ou `OnTokenError` | `feature/payment-brick-q3` | ✅ Concluída |

---

## Detalhamento

### A13 — Modelos compartilhados

**Arquivos a criar:**
- `presentation/shared/FooterState.kt`
- `presentation/shared/ButtonState.kt`

```kotlin
internal data class ButtonState(
    val enabled: Boolean = false,
    val isLoading: Boolean = false,
)

internal data class FooterState(
    val totalLabel: String,
    val totalAmount: String,
    val buttonState: ButtonState? = null,
)
```

---

### A14 — `FetchSecurityCodeScreenUseCase`

**Arquivo a criar:** `domain/usecase/FetchSecurityCodeScreenUseCase.kt`

**Lógica:**
- Recebe `security_code` do cartão selecionado
- Se `security_code.screen != null` → retorna `(title, SecurityCodeState)`
- Caso contrário → retorna `null`

---

### A15 — Passagem de dados do PaymentBrick para SecurityCodeScreen

O `PaymentBrickViewModel` constrói o `SecurityCodeScreenState` a partir do resultado de `FetchSecurityCodeScreenUseCase` e o disponibiliza para a `SecurityCodeScreen` no momento da navegação.

**Dados a passar:**
- `title` — de `screen.header.title`
- `securityCodeState: SecurityCodeState` — mapeado de `security_code`
- `footerState: FooterState` — `totalLabel` e `totalAmount` do resumo do pagamento

**Mecanismo:** `PaymentBrickViewModel` é scoped ao `CheckoutGraph` (navegação), garantindo que a mesma instância seja acessível tanto no seletor de meios quanto na `SecurityCodeScreen`.

---

### A16 — `ValidateSecurityCodeUseCase`

**Arquivo a criar:** `domain/usecase/ValidateSecurityCodeUseCase.kt`

**Regras de validação:**
- Apenas dígitos numéricos
- Comprimento exato igual a `SecurityCodeState.length` (3 ou 4)

**Retorno:** `Boolean` — `true` = válido, `false` = inválido. Ambos os casos de falha (`Empty` e `IncompleteLength`) resultam no mesmo comportamento: exibir `screen.field.error`.

---

### A17 — CoreMethods: `generateCardTokenWithSecurityCode`

**Arquivo a modificar:** `CoreMethods` (módulo público do SDK Android)

**Função a adicionar:**
```kotlin
suspend fun generateCardTokenWithSecurityCode(
    cardId: String,
    securityCodeState: PCIFieldState
): CardToken
```

Chamada internamente pelo `GenerateTokenWithCardIdUseCase`.

---

### A18 — Eventos: `SecurityCodeViewEvent`

**Arquivo a criar:** `presentation/cvv/SecurityCodeViewEvent.kt`

```kotlin
internal sealed interface SecurityCodeViewEvent {
    data class OnTokenSuccess(
        val cardId: String,
        val token: String,
    ) : SecurityCodeViewEvent

    data class OnUserCancelled(
        val context: MPUserCancelledContext.Payment,
    ) : SecurityCodeViewEvent

    data class OnTokenError(
        val error: MercadoPagoCheckoutError,
    ) : SecurityCodeViewEvent
}
```

O `CheckoutController` é o único consumidor — orquestra navegação e repassa o resultado ao `PaymentBrickViewModel`.

---

### A19 — `SecurityCodeViewModel`

**Arquivo a criar:** `presentation/cvv/SecurityCodeViewModel.kt`

**`StateFlow<SecurityCodeScreenState>` expõe:**
```kotlin
internal data class SecurityCodeScreenState(
    val title: String,
    val securityCodeState: SecurityCodeState,
    val footerState: FooterState,
    val fieldError: String? = null,  // null = sem erro; não-null = mensagem de field.error
)
```

**Ações:**
- `onContinue()` — se CVV inválido, publica `fieldError` no state sem avançar
- `onCvvChanged(value: String)` — limpa `fieldError` ao iniciar nova digitação
- `onCvvFocusLost()` — se campo vazio, publica `fieldError` com mensagem de `field.error`
- `onUserCancelled()` — notifica o `PaymentBrickViewModel` para encerrar o fluxo com `Screen.SECURITY_CODE` na lista de telas visitadas

---

### A20 — Layout da tela de CVV

**Arquivo a criar:** `presentation/cvv/SecurityCodeScreen.kt`

**Elementos:**
- Título: `title`
- Campo CVV: `securityCodeState.placeholder`, `securityCodeState.tooltip`
- Botão continuar: habilitado somente quando `footerState.buttonState?.enabled = true`
- Campo CVV: exibe `fieldError` (borda vermelha + ícone + mensagem) quando `SecurityCodeScreenState.fieldError != null`
- Botão voltar: dispara `onUserCancelled()`

**Condicional:** tela exibida somente quando `FetchSecurityCodeScreenUseCase` retorna valor não nulo.

---

### A21 — `GenerateTokenWithCardIdUseCase`

**Arquivo a criar:** `domain/usecase/GenerateTokenWithCardIdUseCase.kt`

**Lógica:**
- Recebe `cardId: String` e `securityCodeState: PCIFieldState`
- Chama `CoreMethods.generateCardTokenWithSecurityCode(cardId, securityCodeState)`
- Retorna `CardToken` em sucesso ou propaga erro

---

### A22 — Integração CheckoutController

**Arquivo a modificar:** `presentation/CheckoutController.kt`

**Mudanças:**
1. Scopar `PaymentBrickViewModel` ao `CheckoutGraph` (mesma instância acessível em todos os destinos do grafo)
2. Adicionar novo destino `CheckoutDestination.SecurityCode`
3. Observar `SecurityCodeViewEvent` e rotear:

```kotlin
composable<CheckoutDestination.SecurityCode> { backStackEntry ->
    val graphEntry = remember(backStackEntry) {
        navController.getBackStackEntry<CheckoutGraph>()
    }
    val paymentBrickViewModel: PaymentBrickViewModel = koinViewModel(
        viewModelStoreOwner = graphEntry
    ) { parametersOf(checkoutConfiguration) }

    SecurityCodeScreenDestination(
        onTokenSuccess = { cardId, token ->
            navController.popBackStack()
            paymentBrickViewModel.processPaymentMethodWithToken(cardId, token)
        },
        onTokenError = {
            navController.popBackStack()
            paymentBrickViewModel.onTokenError()
        },
        onUserCancelled = { context ->
            CheckoutCallbackHolder.notify(
                MercadoPagoCheckoutResult.UserCancelled(context)
            )
        },
    )
}
```

---

### A23 — Tracks — Melidata

**Eventos a instrumentar:**

| Path | Trigger | Payload |
|---|---|---|
| `/checkout_api_native/checkout/payment_brick/cvv` | Tela de CVV exibida | `payment_method_id`, `payment_type_id`, `issuer_id`, `card_id` |
| `/checkout_api_native/checkout/payment_brick/cvv_continue` | Tap em "Continuar" | — |
| `/checkout_api_native/checkout/payment_brick/cvv_back` | Tap em voltar | — |

Os valores de `payment_method_id`, `payment_type_id`, `issuer_id` e `card_id` vêm de `CardData` do cartão selecionado.

---

### A24 — Botão Continuar: chamar tokenização

Implementar a lógica de `onContinue()` no `SecurityCodeViewModel` para chamar o `GenerateTokenWithCardIdUseCase` quando o CVV for válido.

**Fluxo:**
1. `onContinue()` é chamado
2. Se CVV inválido/vazio → publica `fieldError` com mensagem de `field.error`; não avança
3. Se CVV válido → ativa `footerState.buttonState.isLoading = true`
4. Chama `GenerateTokenWithCardIdUseCase(cardId, securityCodeState)`
5. Sucesso → emite `SecurityCodeViewEvent.OnTokenSuccess(cardId, token)`
6. Erro → emite `SecurityCodeViewEvent.OnTokenError`; reverte `isLoading = false`
