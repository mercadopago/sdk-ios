# SDK iOS — Tasks: Tela de CVV (SMFINTECH-32897)

**Jira**: [SMFINTECH-32897](https://mercadolibre.atlassian.net/browse/SMFINTECH-32897)
**Repositório**: [`fury_openplatform-sdk-ios`](https://github.com/melisource/fury_openplatform-sdk-ios)
**Branch**: `feature/cardpayment-q2`
**Extraído de**: [001-selector-de-meios/3-tasks/ios.md](../../../001-selector-de-meios/3-tasks/ios.md)

> Cobertura mínima de testes unitários: **80%** em toda task.

## Ordem de execução

I13 é pré-requisito de I14, I15 e I19. Ordem sugerida: I13 → I14 → I15 → I16 → I18 → I19. I17 não requer implementação.

## Tasks

| Task | Descrição | Status |
|---|---|---|
| I13 | `PaymentInitializationOutput.Item.cardData` + `SecurityCodeScreenOutput.length`/`.field.error` + mapeamento no repositório | ✅ Feito |
| I14 | `PaymentBrick`: rota `.securityCode`, seleção de `"saved_card"`, navegação, tracking de tela visitada | ✅ Feito |
| I15 | `SecurityCodeScreen` (View) + `SecurityCodeViewModel.Configuration` | ✅ Feito |
| I16 | Estado de erro do campo | ✅ Feito (implícito em I15 — `MPTextField` + `@CardFormValidate`) |
| I17 | CoreMethods | ✅ Resolvido |
| I18 | Ações Continuar / Voltar | ✅ Feito |
| I19 | Tracking Melidata | ✅ Feito |

---

## I13 — Domain model e mapeamento

**Arquivos:**
- `Domain/Model/PaymentInitializationOutput.swift`
- `Domain/Model/SecurityCodeScreenOutput.swift`
- `Data/Model/PaymentBrickInitializationResponse.swift`
- `Data/Repositories/RemotePaymentBrickRepository.swift`

### `Item.cardData`

```swift
struct Item: Identifiable, Equatable {
    let id: String
    let title: String
    let description: String?
    let icon: Icon
    let route: String
    let cardData: CardData?

    struct CardData: Equatable {
        let paymentMethodId: String
        let paymentTypeId: String
        let issuerId: Int
        let securityCodeScreen: SecurityCodeScreenOutput?
    }
}
```

`cardData` é `nil` para qualquer item com `route != "saved_card"`. `paymentMethodId`, `paymentTypeId` e `issuerId` são não-opcionais dentro de `CardData` — só existem em conjunto. `securityCodeScreen` é aninhado e independente: indica se aquele cartão específico exige CVV, e permanece `nil` mesmo com `cardData` presente quando o cartão tem `has_preapproval_scope = true` ou `security_code.length = 0`.

`Item.id` é o identificador do cartão (mapeado de `card_data.id`) — não há campo `cardId` separado.

### `SecurityCodeScreenOutput`

```swift
struct SecurityCodeScreenOutput: Equatable {
    let length: Int
    let headerTitle: String
    let field: Field
    let buttonLabel: String

    struct Field: Equatable {
        let label: String
        let placeholder: String
        let helper: String
        let error: String
    }
}
```

### DTO

`PaymentBrickInitializationResponse.SecurityCodeScreen.Field` ganha `error`:

```swift
struct Field: Codable {
    let label: String
    let placeholder: String
    let helper: String
    let error: String
}
```

### Mapeamento

```swift
private func map(_ method: PaymentBrickInitializationResponse.PaymentMethod) -> PaymentInitializationOutput.Item {
    PaymentInitializationOutput.Item(
        id: identifier,
        title: method.title,
        description: method.subtitle,
        icon: .remote(URL(string: method.iconUrl)),
        route: method.type,
        cardData: method.cardData.map { data in
            .init(
                paymentMethodId: data.paymentMethodId,
                paymentTypeId: data.paymentTypeId,
                issuerId: data.issuerId,
                securityCodeScreen: self.mapSecurityCodeScreen(data)
            )
        }
    )
}

private func mapSecurityCodeScreen(_ cardData: PaymentBrickInitializationResponse.CardData) -> SecurityCodeScreenOutput? {
    guard let screen = cardData.securityCode.screen else { return nil }
    return SecurityCodeScreenOutput(
        length: cardData.securityCode.length,
        headerTitle: screen.headerTitle,
        field: .init(
            label: screen.field.label,
            placeholder: screen.field.placeholder,
            helper: screen.field.helper,
            error: screen.field.error
        ),
        buttonLabel: screen.continueButtonLabel
    )
}
```

**Testes:** estender `RemotePaymentBrickRepositoryTests` e `FetchPaymentBrickInitializationUseCaseTests` para cobrir `cardData` e `field.error`.

---

## I14 — Navegação para a tela de CVV

**Arquivo:** `Bricks/PaymentBrick.swift`

```swift
enum Route: Hashable {
    case cardForm
    case securityCode
    case installments
    case reviewAndConfirm
}

@State private var selectedItem: PaymentInitializationOutput.Item?

private func handleSelection(of item: PaymentInitializationOutput.Item) {
    switch item.route {
    case "card_form":
        self.route = .cardForm
    case "saved_card":
        self.selectedItem = item
        self.route = item.cardData?.securityCodeScreen != nil ? .securityCode : .reviewAndConfirm
    default:
        break
    }
}
```

`navigationLinks()` ganha um `NavigationLink` para `.securityCode`, construindo:

```swift
SecurityCodeScreen(
    viewModel: SecurityCodeViewModel(
        config: .init(
            screenOutput: self.selectedItem?.cardData?.securityCodeScreen ?? .empty,
            item: self.selectedItem ?? .empty,
            transactionAmount: self.viewModel.transactionAmount
        )
    ),
    onTokenSuccess: { _ in self.route = .reviewAndConfirm },
    onTokenError: { ... },
    onBack: { self.route = nil }
)
```

com `.onAppear { self.viewModel.markScreenPresented(.securityCode) }` na destination (mesmo padrão de `.onAppear { self.viewModel.markScreenPresented(.paymentMethodSelector) }` na tela seletora).

> **Nota**: por ora, tanto o caminho com CVV (`onTokenSuccess`) quanto o de pular CVV navegam direto para `.reviewAndConfirm`, sem processar a order — o token é descartado (`_`) e o processamento (com ou sem token, cartão comum ou preaprovado) fica pendente para quando a tela de Revisa e Confirma for implementada (ver `20260622-payment-review-confirm`).

---

## I15 — `SecurityCodeScreen` e `SecurityCodeViewModel.Configuration`

**Arquivos:** `Views/SecurityCodeScreen.swift` (criar), `Views/SecurityCodeViewModel.swift` (editar)

`SecurityCodeScreen` segue o mesmo contrato de `EmailScreen`/`CardFormScreen`: só `@ObservedObject viewModel` + `@State` local + closures — nunca `Item`/`Decimal` como propriedades próprias.

```swift
struct Configuration {
    let screenOutput: SecurityCodeScreenOutput
    let item: PaymentInitializationOutput.Item
    let transactionAmount: Decimal
}

var cardTitle: String { self.config.item.title }
var amount: MPAmountData { MPAmountData(from: self.config.transactionAmount) }
```

`submit(code:)` usa `self.config.item.id` como `cardId` e `self.config.screenOutput.length` como `expectedLength`.

```swift
struct SecurityCodeScreen: View {
    @ObservedObject private var viewModel: SecurityCodeViewModel
    @State private var field: SecurityCodeFieldData
    private let onTokenSuccess: (String) -> Void
    private let onTokenError: () -> Void
    private let onBack: () -> Void

    init(
        viewModel: SecurityCodeViewModel,
        onTokenSuccess: @escaping (String) -> Void,
        onTokenError: @escaping () -> Void,
        onBack: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onTokenSuccess = onTokenSuccess
        self.onTokenError = onTokenError
        self.onBack = onBack
        self._field = State(initialValue: SecurityCodeFieldData(expectedLength: viewModel.screenOutput.length))
    }

    var body: some View {
        MPHeader(
            title: self.viewModel.screenOutput.headerTitle,
            onBack: {
                self.viewModel.goBack()
                self.onBack()
            },
            content: {
                MPTextField(
                    text: self.$field.code,
                    label: self.viewModel.screenOutput.field.label,
                    placeholder: self.viewModel.screenOutput.field.placeholder,
                    errorMessage: self.field.$code,
                    keyboard: .numberPad
                )
            },
            footer: {
                MPFooter(
                    title: MPStrings.Common.total,
                    amount: self.viewModel.amount,
                    subtitle: self.viewModel.cardTitle,
                    buttonData: .init(
                        text: self.viewModel.screenOutput.buttonLabel,
                        onClick: { /* I18 */ }
                    )
                )
                .isLoading(self.viewModel.isTokenizing)
                .disabled(self.field.code.count != self.viewModel.screenOutput.length)
            }
        )
        .onAppear { self.viewModel.trackInitialize() }
    }
}
```

Validação via `@CardFormValidate` + `SecurityCodeRule` (`Utils/Rules/CardFormRules.swift`), num `@State` de campo único:

```swift
private struct SecurityCodeFieldData {
    @CardFormValidate var code: String

    init(expectedLength: Int) {
        _code = CardFormValidate(wrappedValue: "", SecurityCodeRule(length: expectedLength))
    }
}
```

---

## I16 — Estado de erro do campo

Borda vermelha, ícone e mensagem de erro seguem `field.$code` (I15) — vazio ou incompleto, no blur ou no tap em "Continuar". O texto vem de `viewModel.screenOutput.field.error`.

---

## I17 — CoreMethods

Nenhuma alteração necessária. A tokenização usa a API pública existente `createToken(_ params: CardParams)`.

---

## I18 — Ações Continuar / Voltar

```swift
onClick: {
    do {
        let token = try await self.viewModel.submit(code: self.field.code)
        self.onTokenSuccess(token)
    } catch {
        self.onTokenError()
    }
}
```

```swift
onBack: {
    self.viewModel.goBack()
    self.onBack()
}
```

---

## I19 — Tracking Melidata

**Arquivo:** `Domain/Analytics/SecurityCodeAnalyticsPath.swift` (criar)

```swift
enum SecurityCodeAnalyticsPath {
    static let initialize = "/checkout_api_native/checkout/payment_brick/cvv"
    static let submit = "/checkout_api_native/checkout/payment_brick/cvv_continue"
    static let userCanceledError = "/checkout_api_native/checkout/payment_brick/cvv_back"
}
```

Implementar `trackInitialize`, `trackSubmit`, `trackSubmitError`, `trackCanceledError` em `SecurityCodeViewModel`, lendo `self.config.item.cardData` e `self.config.item.id` internamente.

| Path | Trigger | Payload |
|---|---|---|
| `.initialize` | Tela exibida | `payment_method_id`, `payment_type_id`, `issuer_id`, `card_id` |
| `.submit` | Tap em "Continuar" | — |
| `.userCanceledError` | Tap em voltar | — |

`trackInitialize()` é chamada em `SecurityCodeScreen.onAppear` (I15).
