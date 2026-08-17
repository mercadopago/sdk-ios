# Tela de CVV — Technical Spec

**Status**: pending
**Owner**: Samanta Albanez
**Jira**: [SMFINTECH-32897](https://mercadolibre.atlassian.net/browse/SMFINTECH-32897)
**Functional Spec**: [1-functional/spec.md](../1-functional/spec.md)
**Parent Feature**: [001-selector-de-meios — Technical Spec](../../../001-selector-de-meios/2-technical/spec.md)
**Created**: 2026-06-26
**Last Updated**: 2026-06-29

---

## Overview

A tela de CVV é a segunda etapa do fluxo de pagamento com cartão salvo no PaymentBrick Nativo, exibida entre o seletor de meios e a tela de Revisa e Confirma.

**Não há chamada de rede dedicada para essa tela.** Todos os dados necessários para renderizá-la chegam no response de `GET /cho-off/v1/payment_brick/initialization`, dentro de `card_data.security_code`. O SDK reutiliza esses dados já em memória — sem latência adicional.

A decisão de exibir ou pular a tela verifica apenas a presença de `security_code.screen` no response — quando ausente, o fluxo avança direto para Revisa e Confirma. O SDK nunca lê `has_preapproval_scope` diretamente; essa decisão pertence ao BFF. **Android** encapsula essa checagem em `FetchSecurityCodeScreenUseCase`, executado pelo `PaymentBrickViewModel`; **iOS** resolve isso inline em `PaymentBrick.handleSelection`, sem UseCase dedicado (ver [`FetchSecurityCodeScreenUseCase`](#fetchsecuritycodescreenusecase)).

A implementação segue o padrão **MVVM** em ambas as plataformas (Android com `StateFlow` + Jetpack Compose, iOS com `@Published` + SwiftUI). A validação local do CVV antes de habilitar o botão de continuar usa `ValidateSecurityCodeUseCase` no **Android**; no **iOS** reaproveita `@CardFormValidate` + `SecurityCodeRule` (já existentes) dentro da `SecurityCodeScreen`.

---

## Lógica de Exibição (BFF → SDK)

### Regra do SDK

Toda a lógica de decisão está encapsulada em `FetchSecurityCodeScreenUseCase`, executado pelo `PaymentBrickViewModel`. O SDK possui uma única regra: verificar se `security_code.screen` está presente no response de `GET /cho-off/v1/payment_brick/initialization`. Ele **nunca lê `has_preapproval_scope` diretamente**.

```
if security_code.screen != null
    → exibe tela de CVV

→ pula para Revisa e Confirma
```

### Contexto BFF — por que `security_code.screen` pode estar ausente

A tabela abaixo descreve as regras de negócio que determinam o que o BFF envia. É uma referência para entender o comportamento esperado de ponta a ponta, mas **não representa lógica implementada no SDK**.

| `security_code.length` | `has_preapproval_scope` | BFF envia `security_code.screen`? | Comportamento SDK |
|---|---|---|---|
| > 0 (3 para Visa/Master, 4 para Amex) | `false` | **Sim** | Exibe tela de CVV |
| > 0 | `true` | **Não** | Pula tela de CVV |
| `0` | qualquer | **Não** | Pula tela de CVV |

---

## Contrato de Dados — `security_code.screen`

Campos recebidos via `GET /cho-off/v1/payment_brick/initialization` dentro de `card_data.security_code.screen`:

```json
{
  "security_code": {
    "length": 3,
    "screen": {
      "header": {
        "title": "Completá el código de seguridad"
      },
      "field": {
        "label": "Código de seguridad",
        "placeholder": "Ej.: 123",
        "helper": "Está en el reverso de tu tarjeta.",
        "error": "Completá este campo."
      },
      "button": {
        "label": "Continuar"
      }
    }
  }
}
```

| Campo | Tipo | Presença | Descrição |
|---|---|---|---|
| `length` | number | Sempre | Comprimento do CVV (3 ou 4) |
| `screen` | object | Opcional | **Presente** = SDK exibe tela. **Ausente** = SDK pula |
| `screen.header.title` | string | Com `screen` | Título da tela — traduzido pelo BFF por locale |
| `screen.field.label` | string | Com `screen` | Label do campo de CVV |
| `screen.field.placeholder` | string | Com `screen` | Placeholder gerado pelo BFF baseado no `length` |
| `screen.field.helper` | string | Com `screen` | Texto auxiliar |
| `screen.field.error` | string | Com `screen` | Mensagem de erro exibida no blur ou tap em continuar com campo vazio |
| `screen.button.label` | string | Com `screen` | Label do botão — traduzido pelo BFF |

> **Regra de placeholder**: BFF gera automaticamente — `"Ej.: 123"` para `length = 3`, `"Ej.: 1234"` para `length = 4`.

---

## SDK Architecture

### Padrão MVVM (Android + iOS)

**`PaymentBrickViewModel` (ambas as plataformas):**
- Decide exibir ou pular a tela de CVV a partir de `security_code.screen` do cartão selecionado. **Android** encapsula essa decisão em `FetchSecurityCodeScreenUseCase`. **iOS** resolve isso inline, sem UseCase dedicado (ver bullets de `PaymentInitializationOutput.Item`/`SecurityCodeScreenOutput` abaixo e [`PaymentBrick` — iOS](#orquestração-no-paymentbrick--ios))

**Android:**
- `CardState` — dados do cartão selecionado: `iconUrl`, `title`, `subtitle` (de `method.*`)
- `FooterState` — modelo compartilhado do PaymentBrick com `totalLabel` e `totalAmount`
- `ValidateSecurityCodeUseCase` — validação local do CVV (comprimento, formato numérico)
- `GenerateTokenWithCardIdUseCase` — tokenização via `generateCardTokenWithSecurityCode(cardId, securityCodeState: PCIFieldState)`
- `SecurityCodeViewModel` — expõe `StateFlow<SecurityCodeScreenState>` com estado do campo, validação e tokenização; ao iniciar tokenização ativa `footerState.buttonState.isLoading`; ao concluir emite `SecurityCodeViewEvent`
- `SecurityCodeScreen` (Composable) — renderiza com dados do ViewModel; campo CVV é um input numérico padrão

**iOS** — a maior parte já existe no código real (branch `feature/cardpayment-q2`); as tasks são principalmente extensão e wiring, não criação do zero:
- `SecurityCodeScreenOutput` — **model existente**, em `Domain/Model/SecurityCodeScreenOutput.swift`: `headerTitle`, `field: Field` (tipo **aninhado**, seguindo a mesma convenção de `PaymentInitializationOutput.Section`/`.Item`/`.Footer` — não um `SecurityCodeFieldOutput` solto), `buttonLabel`. Ganha dois campos novos: `length: Int` (de `security_code.length`) e `field.error` (mensagem de erro do BFF) — ver [`SecurityCodeScreenOutput` — iOS](#securitycodescreenoutput--ios-model-existente). Com `length` embutido, o model passa a ser **autossuficiente** para configurar tanto a tela quanto a validação, sem depender de um campo irmão espalhado em outro lugar
- `PaymentInitializationOutput.Item` — **hoje não carrega nada do cartão salvo além de `id, title, description, icon, route`; é o bloqueador real desta feature**. Ganha um único campo novo, `cardData: CardData?`, agrupando `paymentMethodId: String`, `paymentTypeId: String`, `issuerId: Int` e `securityCodeScreen: SecurityCodeScreenOutput?` — os 3 primeiros só existem juntos (ou é cartão salvo, ou não é nada), então viram 4 optionals soltos permitiria estados inválidos (ex.: `paymentMethodId` presente sem `paymentTypeId`); um único `nil`-check em `cardData` evita isso. `securityCodeScreen` mora dentro de `CardData`, não fora: são dois eixos de opcionalidade — `cardData == nil` responde "é cartão salvo?", `cardData?.securityCodeScreen == nil` responde "esse cartão precisa de CVV?" (só faz sentido perguntar depois do primeiro "sim"). `paymentMethodId`/`paymentTypeId`/`issuerId` continuam acessíveis mesmo quando a tela de CVV é pulada — nesse caso só `securityCodeScreen` é `nil`, `cardData` em si permanece. Não precisa de um campo `cardId` separado: `Item.id` **já é** `cardData.id` para cartões salvos (`RemotePaymentBrickRepository.map(_ method:)` já faz `method.cardData?.id ?? method.type`). O mapeamento `DTO → SecurityCodeScreenOutput` já existente no repositório precisa mudar de assinatura (recebe o `CardData` inteiro, não só o `screen` aninhado) para poder extrair `length` — ver [`SecurityCodeScreenOutput` — iOS](#securitycodescreenoutput--ios-model-existente)
- `@CardFormValidate` + `SecurityCodeRule` — **já existem** (`Utils/Rules/CardFormRules.swift`), reaproveitados do fluxo de cartão novo (`CardFormData`); usados na `SecurityCodeScreen` (View), dentro de um `@State` de campo único, configurados com `SecurityCodeRule(length: screenOutput.length)` — o wrapper sempre vive em structs `@State`, nunca dentro de um `ObservableObject` como o `SecurityCodeViewModel`
- `SecurityCodeViewModel` — **já existe** (`Views/SecurityCodeViewModel.swift`) com `Configuration{screenOutput, expectedLength, cardId}`, `@Published isTokenizing`, `submit(code:) async throws -> String` (chama `SecurityCodeUseCase` diretamente, sem `GenerateTokenWithCardIdUseCase`), `goBack()`, e 4 métodos de tracking já stubados (`trackInitialize`/`trackSubmit`/`trackSubmitError`/`trackCanceledError`). `Configuration` muda de forma: perde `expectedLength` (migra para `screenOutput.length`) e troca `cardId` por `item: PaymentInitializationOutput.Item` + `transactionAmount: Decimal` — o ViewModel passa a ser a única fonte de dados da `SecurityCodeScreen`, expondo computed properties (`cardTitle`, `amount`) para o que antes seria lido direto do `Item` pela View
- `SecurityCodeScreen` (SwiftUI View) — **a criar**, em `Views/SecurityCodeScreen.swift` (nunca `Presentation/CVV/` — essa pasta não existe no projeto; toda tela do fluxo mora plana em `Views/`); composição `MPHeader`+`MPFooter`/`MPFixedFooterButtonData`, igual a `EmailScreen`/`CardFormScreen`. Segue o mesmo contrato de View que todo o resto do fluxo (`EmailScreen`, `CardFormScreen`): só guarda `@ObservedObject viewModel` + `@State` local + closures de callback — **nunca um `Item`/`Decimal` cru ao lado do ViewModel**. Tudo que a tela precisa (texto do BFF, dados do cartão, total) chega via `viewModel.screenOutput`/`viewModel.cardTitle`/`viewModel.amount`

### Orquestrador de navegação — diferença entre plataformas

Android e iOS diferem fundamentalmente em como o resultado da tokenização volta ao fluxo principal:

| | Android | iOS |
|---|---|---|
| Orquestrador | `CheckoutController` (Composable separado) | `PaymentBrick` (a própria View) |
| Token comunica via | `SecurityCodeViewEvent.OnTokenSuccess` observado pelo `CheckoutController` | Closure `onTokenSuccess: (CardToken) -> Void` passada para `SecurityCodeScreen` |
| Erro de tokenização via | `SecurityCodeViewEvent.OnTokenError` observado pelo `CheckoutController` | Closure `onTokenError: () -> Void` passada para `SecurityCodeScreen` |
| Escopo do `PaymentBrickViewModel` | Precisa ser scoped ao `CheckoutGraph` | Já correto — `@ObservedObject` owned pelo `PaymentBrick` |
| Chamada de `processOrder` | `paymentBrickViewModel.processPaymentMethodWithToken(cardId, token)` | `PaymentBrick.process(params:)` — já existe |

### Fluxo de dados

```
GET /cho-off/v1/payment_brick/initialization (já executado)
        ↓
PaymentBrickViewModel
        ↓
FetchSecurityCodeScreenUseCase (card_data.security_code)
        ↓
(title, SecurityCodeState)?
        ↓
┌─────────────────────────────┐
│ resultado != null?          │
└─────────────────────────────┘
        │
        ├── NÃO → Revisa e Confirma
        │
        └── SIM
               ↓
        SecurityCodeViewModel (StateFlow / @Published)
               ↓
        SecurityCodeScreen (UI)
               ↓
        [usuário digita CVV]
               ↓
        ValidateSecurityCodeUseCase (validação local)
               ↓
        [CVV válido] → usuário toca "Continuar"
               ↓
        GenerateTokenWithCardIdUseCase (cardId + CVV → token)
               ↓
        ┌────────────────────────────────────┐
        │ Tokenização bem-sucedida?          │
        └────────────────────────────────────┘
               │
               ├── ERRO
               │      Android: SecurityCodeViewEvent.OnTokenError
               │               → CheckoutController → navController.popBackStack()
               │               → PaymentBrickViewModel exibe card_form_generic_error
               │      iOS:     onTokenError() closure
               │               → PaymentBrick.route = nil (volta ao seletor)
               │               → PaymentBrick exibe card_form_generic_error
               │
               └── SUCESSO
                      Android: SecurityCodeViewEvent.OnTokenSuccess(cardId, token)
                               → CheckoutController → paymentBrickViewModel.processPaymentMethodWithToken
                      iOS:     onTokenSuccess(token) closure
                               → PaymentBrick.process(params:)
                      ↓
               PaymentBrickViewModel / PaymentBrick processa a order
                      ↓
               Revisa e Confirma
```

> Diagrama conceitual — `FetchSecurityCodeScreenUseCase`, `ValidateSecurityCodeUseCase` e `GenerateTokenWithCardIdUseCase` são as classes concretas do **Android**. No **iOS** as mesmas três etapas existem, mas como: `if` inline em `PaymentBrick.handleSelection`, `@CardFormValidate`+`SecurityCodeRule` na `SecurityCodeScreen`, e chamada direta a `SecurityCodeUseCase` a partir de `SecurityCodeViewModel.submit(code:)` — sem três classes correspondentes.

---

## `FetchSecurityCodeScreenUseCase`

> **Nota de plataforma**: a descrição abaixo (input/output/regras) é a **regra de negócio conceitual**, compartilhada pelas duas plataformas. **Android** materializa isso como a classe `FetchSecurityCodeScreenUseCase` descrita aqui. **iOS não cria essa classe** — pelo padrão já estabelecido no `PaymentBrick` (ex.: `CardFormBrick.handleInstallments`, que decide inline se navega para a tela de installments), a mesma checagem vira um `if item.cardData?.securityCodeScreen != nil` dentro de `PaymentBrick.handleSelection` (ver [`PaymentBrick` — iOS](#orquestração-no-paymentbrick--ios)). Pelo `PATTERNS.md` do próprio SDK, use cases servem para acesso a dados externos — um `nil`-check local não se qualifica.

Executado pelo `PaymentBrickViewModel` após o usuário selecionar um cartão salvo, antes de qualquer navegação. Encapsula **todas** as regras de decisão sobre exibir ou pular a tela de CVV.

**Input:** `security_code` do cartão selecionado (response de `GET /cho-off/v1/payment_brick/initialization`)

**Output:** par `(title: String, securityCodeState: SecurityCodeState)?`
- Presente → `PaymentBrickViewModel` usa os dados para montar `SecurityCodeScreenState` e navega para a tela
- `null` / `nil` → `PaymentBrickViewModel` avança direto para Revisa e Confirma

**Regras internas:**

| Condição | Retorno |
|---|---|
| `security_code.screen` presente | `title` de `screen.header.title` + `SecurityCodeState` mapeado de `security_code` |
| `security_code.screen` ausente (qualquer motivo) | `null` / `nil` |

```
if security_code.screen != null
    → extrai title de screen.header.title
    → mapeia security_code para SecurityCodeState
    → retorna (title, SecurityCodeState)

→ retorna null / nil
```

> O use case não lê `has_preapproval_scope` nem toma decisões de negócio. A presença ou ausência de `security_code.screen` é a única fonte de verdade — a decisão pertence ao BFF.

---

## Validação local do CVV

- Apenas dígitos numéricos
- Comprimento exato igual a `security_code.length`
- Botão de continuar habilitado somente com CVV completo e válido

> **iOS**: validação feita via `@CardFormValidate` + `SecurityCodeRule` (já existem, reaproveitados de `CardFormData`) — mas na **`SecurityCodeScreen` (View)**, dentro de um `@State` de campo único, e não no `SecurityCodeViewModel`. O wrapper é sempre aplicado a `@State` (struct) em uma View — nunca dentro de uma `ObservableObject`. Sem use case dedicado; `SecurityCodeRule(length:)` é configurado com `viewModel.screenOutput.length`, que vem de `security_code.length` do BFF.
> **Android**: validação feita via `ValidateSecurityCodeUseCase`.

---

## Estado de erro do campo — ciclo de vida

| Trigger | Ação |
|---|---|
| Blur com campo vazio | Publica `fieldError` com texto de `screen.field.error` |
| Tap em "Continuar" com CVV vazio ou incompleto | Publica `fieldError` com texto de `screen.field.error` |
| Usuário começa a digitar (`onCvvChanged`) | Limpa `fieldError` (volta a `null`) |

**Android:** controlado via `onCvvFocusLost()` e `onCvvChanged()` no `SecurityCodeViewModel`.

**iOS:** controlado via `@CardFormValidate` — o property wrapper dispara automaticamente no blur e em tap de continuar; limpa ao digitar.

A mensagem de erro vem do BFF via `security_code.screen.field.error` — não é hardcoded.

---

## Estado de loading do botão

Quando o usuário toca em "Continuar" com CVV válido, o `SecurityCodeViewModel` ativa `footerState.buttonState.isLoading = true` **antes** de iniciar a tokenização. O botão exibe estado de carregamento e é desabilitado durante a operação — seguindo o padrão já adotado na tela de CardSave.

**`CardState` — dados do cartão selecionado:**

```kotlin
// Android
internal data class CardState(
    val iconUrl: String,
    val title: String,
    val subtitle: String,
)
```

| Campo | Origem no BFF |
|---|---|
| `iconUrl` | `method.icon_url` |
| `title` | `method.title` — banco + dígitos, ex: "Santander •••• 4567" |
| `subtitle` | `method.subtitle` — tipo do cartão, ex: "Visa Crédito" |

> **iOS**: não cria `CardState`. `PaymentInitializationOutput.Item` (o cartão selecionado) já expõe `icon`, `title` e `description` mapeados 1:1 a partir de `method.icon_url`/`method.title`/`method.subtitle` (ver `RemotePaymentBrickRepository.map(_ method:)`). A `SecurityCodeScreen` recebe o `Item` já selecionado e lê esses campos diretamente — duplicar em uma struct nova seria redundante.

---

**`FooterState` — modelo compartilhado do PaymentBrick (Android):**

Modelo reutilizável entre as telas do PaymentBrick para representar o rodapé com o resumo do pagamento. Deve ser criado no pacote de modelos compartilhados do PaymentBrick.

```kotlin
// Android
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

| Campo | Origem no BFF |
|---|---|
| `totalLabel` | `footer.total_label` |
| `totalAmount` | `footer.total_amount` |

> **iOS**: não cria `FooterState`/`ButtonState`. O design system já resolve isso com `MPFooter` + `MPFixedFooterButtonData` (`Sources/MPComponents/BaseElements/Footer/`), usados por `CardFormScreen`/`EmailScreen`/`PaymentsScreen` hoje — incluindo os modificadores `.isLoading(_:)` e `.disabled(_:)` que cobrem exatamente o estado de loading do botão. O valor total vem de `MPAmountData(from: PaymentBrickViewModel.transactionAmount)` — o Decimal já configurado pelo integrador — e não da string `footer.total_amount` do BFF: a tela seletora (`PaymentsScreen`/`PaymentsViewModel`) já segue esse caminho e ignora esse campo do BFF hoje.

---

**Android — `SecurityCodeScreenState`:**

```kotlin
internal data class SecurityCodeScreenState(
    val title: String,
    val cardState: CardState,
    val securityCodeState: SecurityCodeState,
    val footerState: FooterState,
)
```

| Campo | Origem |
|---|---|
| `title` | `security_code.screen.header.title` |
| `cardState` | `method.icon_url`, `method.title`, `method.subtitle` |
| `securityCodeState` | `security_code` — reutilizado sem modificação |
| `footerState` | `footer.total_label`, `footer.total_amount` |

**iOS — `SecurityCodeViewModel` (já existe, `Views/SecurityCodeViewModel.swift`):**

```swift
// Hoje (existente na branch)
struct Configuration {
    let screenOutput: SecurityCodeScreenOutput
    let expectedLength: Int
    let cardId: String
}

// Depois — expectedLength sai (vive em screenOutput.length); cardId dá lugar a item,
// de onde vem tanto o id do cartão quanto os dados de exibição; e transactionAmount entra
// para a ViewModel poder expor o total já formatado
struct Configuration {
    let screenOutput: SecurityCodeScreenOutput
    let item: PaymentInitializationOutput.Item
    let transactionAmount: Decimal
}

@Published private(set) var isTokenizing = false

// Computed — expõem para a View tudo que antes seria lido direto de um Item cru
var cardTitle: String { self.config.item.title }
var amount: MPAmountData { MPAmountData(from: self.config.transactionAmount) }
```

A `SecurityCodeScreen` **não guarda `Item`/`Decimal` como propriedades próprias** — segue o mesmo contrato de View que `EmailScreen`/`CardFormScreen` (só `@ObservedObject viewModel` + `@State` local + closures). Todo dado dinâmico da tela — texto do BFF (`screenOutput`), dados do cartão (`cardTitle`) e total (`amount`) — é lido através do ViewModel. `isTokenizing` cumpre o papel do `buttonState.isLoading` do Android: é revertido para `false` em qualquer desfecho (sucesso ou erro), via `defer` dentro de `submit(code:)`, que já está implementado; esse método só precisa trocar `self.config.expectedLength` por `self.config.screenOutput.length`, e `self.config.cardId` por `self.config.item.id`, nas chamadas ao `SecurityCodeUseCase`.

Sem campo `cardId` separado: `item.id` **já é** o id do cartão para cartões salvos (ver bullet de `PaymentInitializationOutput.Item` em [SDK Architecture](#sdk-architecture)). Como `trackInitialize()`/etc. também passam a ler `self.config.item` internamente, os 4 stubs de tracking continuam **sem precisar de novos parâmetros** — ver [Tracking — Melidata](#tracking--melidata).

---

## Tokenização — `GenerateTokenWithCardIdUseCase`

Disparado pelo `SecurityCodeViewModel` quando o usuário toca em "Continuar" com CVV válido. A função de `CoreMethods` chamada difere por plataforma.

> **Nota de plataforma**: `GenerateTokenWithCardIdUseCase` é a solução **Android**. **iOS não cria esse wrapper** — `SecurityCodeViewModel.submit(code:)` (já implementado em `Views/SecurityCodeViewModel.swift`) chama `SecurityCodeUseCase.execute(code:expectedLength:cardId:)` diretamente, sem UseCase intermediário.

**Android** — chama a nova função pública `generateCardTokenWithSecurityCode`; o CVV digitado é encapsulado em `PCIFieldState` pelo use case:

```kotlin
generateCardTokenWithSecurityCode(
    cardId: String,
    securityCodeState: PCIFieldState
)
```

| Parâmetro | Valor neste fluxo |
|---|---|
| `cardId` | ID do cartão selecionado |
| `securityCodeState` | Estado completo do campo PCI de CVV |

**iOS** — sem campo PCI; `SecurityCodeViewModel.submit(code:)` já delega ao `SecurityCodeUseCase.execute(code:expectedLength:cardId:)` com CVV como `String` (já implementado, nada a criar aqui):

```swift
SecurityCodeUseCase.execute(
    code: String,
    expectedLength: Int,
    cardId: String
)
```

| Parâmetro | Valor neste fluxo |
|---|---|
| `code` | CVV digitado pelo usuário (String) |
| `expectedLength` | `SecurityCodeState.length` |
| `cardId` | ID do cartão selecionado |

### Tratamento de erro na tokenização

Em caso de erro, o fluxo **não avança** para Revisa e Confirma. O SDK volta à tela do `PaymentBrick` (seletor de meios) e exibe `card_form_generic_error`, seguindo o padrão já estabelecido no checkout para erros de operação.

**Android:**
- `SecurityCodeViewModel` emite `SecurityCodeViewEvent.OnTokenError`
- `CheckoutController` executa `navController.popBackStack()` e sinaliza `PaymentBrickViewModel` para exibir o estado de erro genérico

**iOS:**
- `SecurityCodeViewModel` chama `onTokenError()`
- `PaymentBrick` executa `self.route = nil` (volta ao seletor) e exibe `card_form_generic_error`

---

## Tokenização iOS — `SecurityCodeUseCase` e `CardParams`

iOS **não utiliza campo PCI**. `SecurityCodeViewModel.submit(code:)` delega diretamente ao `SecurityCodeUseCase` existente (sem `GenerateTokenWithCardIdUseCase` intermediário), que recebe o CVV como `String`:

```swift
func execute(
    code: String,
    expectedLength: Int,
    cardId: String
) async throws(MercadoPagoCheckoutError) -> CardToken {
    try self.validateFormat(code: code, expectedLength: expectedLength)
    let params = CardParams(cardId: cardId, securityCode: code, ...)
    return try await self.service.createCardToken(cardParams: params)
}
```

A função `createToken(cardID:securityCode:SecurityCodeTextField)` adicionada ao `CoreMethods` existe exclusivamente para paridade de API pública com Android — não é utilizada internamente neste fluxo.

---

## `SecurityCodeScreenOutput` — iOS (model existente)

Model já presente na branch `feature/cardpayment-q2` em `Domain/Model/SecurityCodeScreenOutput.swift`. **Não** é necessário criar `SecurityCodeScreenData`/`SecurityCodeFieldConfig`/`Footer` novos — os ajustes são dois campos novos: a mensagem de erro do BFF (faltando hoje) e o comprimento do CVV (hoje vive só em `Configuration.expectedLength`, redundante com o próprio `screen` que o acompanha em todo response do BFF):

```swift
// Hoje (existente na branch)
struct SecurityCodeScreenOutput: Equatable {
    let headerTitle: String
    let field: Field
    let buttonLabel: String

    struct Field: Equatable {
        let label: String
        let placeholder: String
        let helper: String
    }
}

// Depois — length (nível raiz) + error (dentro do Field aninhado)
struct SecurityCodeScreenOutput: Equatable {
    let length: Int      // NOVO — de security_code.length; move para cá em vez de ficar em Configuration.expectedLength
    let headerTitle: String
    let field: Field
    let buttonLabel: String

    struct Field: Equatable {
        let label: String
        let placeholder: String
        let helper: String
        let error: String   // NOVO — de security_code.screen.field.error
    }
}
```

`field` continua um tipo **aninhado** (`SecurityCodeScreenOutput.Field`), igual à convenção usada em `PaymentInitializationOutput.Section`/`.Item`/`.Footer` — não uma struct solta `SecurityCodeFieldOutput`. `buttonLabel` não é substituído por nada: o total/rodapé não faz parte deste model (vem de `PaymentBrickViewModel.transactionAmount`, ver seção de `FooterState` acima).

Com `length` embutido, o model deixa de precisar de um campo irmão espalhado em `Item`/`Configuration` para essa informação — quem recebe um `SecurityCodeScreenOutput` já tem tudo que precisa para configurar a tela e a regra de validação, sem depender de outro parâmetro.

**Mapeamento — muda de assinatura.** `RemotePaymentBrickRepository.map(_ screen:)` (já escrito, hoje órfão) recebia só o `SecurityCodeScreen` aninhado do DTO — mas `length` é campo irmão de `screen` dentro de `security_code` (`card_data.security_code.length` vs. `card_data.security_code.screen`), então o mapper precisa subir um nível e receber o `security_code` inteiro (ou o `CardData` inteiro, para já servir também o mapeamento de `Item`, ver bullet de `PaymentInitializationOutput.Item`):

```swift
// Depois
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

O DTO (`PaymentBrickInitializationResponse.SecurityCodeScreen.Field`) também precisa ganhar `error`, já que hoje só decodifica `label`/`placeholder`/`helper`.

---

## `SecurityCodeViewEvent` — Android

Após a tokenização, o `SecurityCodeViewModel` emite um `SecurityCodeViewEvent`. O `CheckoutController` é o único consumidor — ele orquestra a navegação e repassa o resultado ao `PaymentBrickViewModel`.

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

### Escopo do `PaymentBrickViewModel` — Android

O `PaymentBrickViewModel` deve ser scoped ao **grafo de navegação** (`CheckoutGraph`), não ao destino `Payment`. Isso garante que a mesma instância seja acessível tanto na tela de seletor de meios quanto na tela de CVV.

```kotlin
// CheckoutController.kt
composable<CheckoutDestination.Payment> { backStackEntry ->
    val graphEntry = remember(backStackEntry) {
        navController.getBackStackEntry<CheckoutGraph>()
    }
    val paymentBrickViewModel: PaymentBrickViewModel = koinViewModel(
        viewModelStoreOwner = graphEntry  // scoped ao grafo
    ) { parametersOf(checkoutConfiguration) }
    PaymentBrickScreenDestination(viewModel = paymentBrickViewModel, ...)
}
```

Esse padrão é idêntico ao já adotado pelo `CardPaymentViewModel`.

### Orquestração no `CheckoutController` — Android

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
        onTokenError = { error ->
            navController.popBackStack()
            paymentBrickViewModel.onTokenError()  // exibe card_form_generic_error
        },
        onUserCancelled = { context ->
            CheckoutCallbackHolder.notify(
                MercadoPagoCheckoutResult.UserCancelled(context)
            )
        },
    )
}
```

### `processPaymentMethodWithToken` no `PaymentBrickViewModel` — Android

```kotlin
fun processPaymentMethodWithToken(cardId: String, token: String) {
    val method = findMethodByCardId(cardId) ?: return
    val paymentType = checkoutConfiguration?.checkoutType as? MPCheckoutType.Payment ?: return
    viewModelScope.launch {
        _viewState.value = _viewState.value.copy(footerState = footerState.copy(buttonState = buttonState.copy(isLoading = true)))
        processOrderUseCase(
            ProcessOrderParams(
                orderId = paymentType.order.orderId,
                clientToken = paymentType.order.clientToken,
                amount = paymentType.order.amount.toPlainString(),
                paymentMethodId = method.cardData?.paymentMethodId.orEmpty(),
                paymentMethodType = method.cardData?.paymentTypeId.orEmpty(),
                token = token,
                installments = DEFAULT_INSTALLMENTS,
            ),
        ).fold(
            onSuccess = { ... },
            onError = { ... },
        )
    }
}

fun onTokenError() {
    _viewState.value = _viewState.value.copy(footerState = footerState.copy(buttonState = buttonState.copy(isLoading = false)))
}
```

> `findMethodByCardId` localiza o método pelo `cardData.id`, análogo ao `findMethodByOptionId` existente.

---

## Orquestração no `PaymentBrick` — iOS

No iOS, o `PaymentBrick` (View) é o orquestrador de navegação. O token e os erros são comunicados via **closures** fornecidas pelo `PaymentBrick` ao `SecurityCodeScreen`.

### `Route` enum — novo case

```swift
enum Route: Hashable {
    case cardForm
    case securityCode   // NEW
    case installments
    case reviewAndConfirm
}
```

### `@State` para dados do cartão selecionado

```swift
// Análogo ao pendingInstallmentData/pendingPaymentData do Android
@State private var selectedItem: PaymentInitializationOutput.Item?
```

### `handleSelection` — decide exibir ou pular CVV

```swift
private func handleSelection(of item: PaymentInitializationOutput.Item) {
    switch item.route {
    case "saved_card":
        self.selectedItem = item
        if item.cardData?.securityCodeScreen != nil {
            self.route = .securityCode
        } else {
            // Pula CVV — avança direto para Revisa e Confirma
            Task { await self.process(params: /* sem token, ver nota abaixo */) }
        }
    case "card_form":
        self.route = .cardForm
    default:
        break
    }
}
```

> A ramificação de "pula CVV" (`has_preapproval_scope`/`security_code.length = 0`) chama `process(params:)` sem ter passado pela tela de CVV — ou seja, sem um token novo de CVV. `item.cardData` continua presente mesmo quando `cardData.securityCodeScreen` é `nil` (só esse último campo varia dentro de `CardData`), então `paymentMethodId`/`paymentTypeId` **já estão disponíveis nesse branch** para montar boa parte do `OrderTransactionParams`. O que continua em aberto, não resolvido nem por esta correção nem em nenhuma plataforma: se o backend aceita processar a order sem um token novo para cartões preapproved, ou se esse caminho precisa de outro campo/fluxo. Deveria virar uma pergunta explícita antes de I14 ser implementada.

### `NavigationLink` para `SecurityCodeScreen`

```swift
NavigationLink(
    destination: SecurityCodeScreen(
        viewModel: SecurityCodeViewModel(
            config: .init(
                screenOutput: self.selectedItem?.cardData?.securityCodeScreen ?? .empty, // SecurityCodeScreenOutput, já com .length
                item: self.selectedItem ?? .empty,     // Item.id já é o cardId para saved_card
                transactionAmount: self.viewModel.transactionAmount
            )
        ),
        // SecurityCodeScreen só recebe viewModel + closures — nada de item/transactionAmount aqui
        onTokenSuccess: { token in
            self.route = nil
            Task { await self.process(params: /* monta OrderTransactionParams com token + self.selectedItem?.cardData?.paymentMethodId/.paymentTypeId */) }
        },
        onTokenError: {
            self.route = nil          // volta ao seletor de meios
            self.showGenericError()   // exibe card_form_generic_error
        },
        onBack: {
            self.route = nil
        }
    )
    .onAppear { self.viewModel.markScreenPresented(.securityCode) },
    tag: Route.securityCode,
    selection: self.$route
) { EmptyView() }.hidden()
```

> `PaymentBrick.process(params:)` já existe na branch — apenas precisa ser chamado com o token correto. `markScreenPresented(.securityCode)` segue o mesmo padrão já usado pela tela seletora (`.onAppear { self.viewModel.markScreenPresented(.paymentMethodSelector) }`) — sem essa chamada, `screensVisited`/`onUserCancelled` não refletem a passagem pela tela de CVV.

---

## CoreMethods — Nova função pública

Uma nova função pública deve ser adicionada ao `CoreMethods` em ambas as plataformas para suportar tokenização com `cardId` + security code.

**Android** — nova função pública que recebe o campo PCI de security code:

```kotlin
suspend fun generateCardTokenWithSecurityCode(
    cardId: String,
    securityCodeState: PCIFieldState
): CardToken
```

> A função Android não recebe `expirationDateState` nem `BuyerIdentification` — esses campos não são necessários para tokenização de cartão salvo com CVV.

**iOS** — sem nova sobrecarga pública. A tokenização usa `createToken(_ params: CardParams)` já existente, passando `cardId` + `securityCode`. Ver [Tokenização iOS — CardParams com cardId](#tokenização-ios--cardparams-com-cardid).

---

## Cancelamento — `onUserCancelled` e `Screen.securityCode`

Quando o usuário toca em voltar na tela de CVV, o `SecurityCodeViewModel` dispara `onUserCancelled()`.

**Android** — emite `SecurityCodeViewEvent.OnUserCancelled`; `CheckoutController` notifica via `CheckoutCallbackHolder`:

```kotlin
onResult(MercadoPagoCheckoutResult.UserCancelled(MPUserCancelledContext.Payment(screens = listOf(Screen.SECURITY_CODE))))
```

**iOS** — chama a closure `onBack` fornecida pelo `PaymentBrick`; o `PaymentBrick` chama `cancel(screens:)`:

```swift
onResult(.userCancelled(MPUserCancelledContext.Payment(screens: [.securityCode])))
```

### `Screen` enum — novo case

```kotlin
// Android — Screen.kt
enum class Screen {
    INSTALLMENTS,
    PAYMENT_METHOD_SELECTOR,
    CARD_FORM,
    OFFLINE_METHOD_SELECTOR,
    SECURITY_CODE,  // NEW
}
```

```swift
// iOS — Screen.swift
public enum Screen: Sendable, Equatable {
    case paymentMethodSelector
    case installments
    case securityCode  // já adicionado na branch — nada a fazer aqui
}
```

O `screens` de `MPUserCancelledContext.Payment` reflete a ordem das telas visitadas antes do cancelamento:

| Cenário | `screens` entregue ao integrador |
|---|---|
| Usuário cancela direto do seletor de meios | `[]` |
| Usuário avança para CVV e cancela | `[.securityCode]` |

---

## Mock — Response de `GET /cho-off/v1/payment_brick/initialization`

Estrutura relevante para a tela de CVV:

```json
{
  "header_title": "Escolha como pagar",
  "sections": [
    {
      "title": "Formas de pagamento",
      "methods": [
        {
          "type": "saved_card",
          "title": "Mastercard **** 6351",
          "subtitle": "Master Crédito",
          "icon_url": "https://http2.mlstatic.com/storage/mobile-on-demand-resources/image/cho_off-master_mdpi",
          "card_data": {
            "id": "9720735105",
            "bin": "503143",
            "last_four_digits": "6351",
            "payment_method_id": "master",
            "payment_type_id": "credit_card",
            "issuer_id": 24,
            "security_code": {
              "length": 3,
              "screen": {
                "header": { "title": "Insira o código de segurança" },
                "field": {
                  "label": "Código de segurança",
                  "placeholder": "ex.: 123",
                  "helper": "Fica no verso do cartão.",
                  "error": "Preencha este campo."
                },
                "button": { "label": "Continuar" }
              }
            }
          }
        }
      ]
    }
  ],
  "footer": {
    "total_label": "Total",
    "total_amount": "R$ 100"
  }
}
```

### Mapeamento — dados do cartão na tela de CVV

O BFF entrega `title` e `subtitle` já formatados. O SDK **não compõe** esses valores a partir de campos separados.

| Elemento na tela | Campo no response | Exemplo |
|---|---|---|
| Ícone da bandeira | `method.icon_url` | logo Mastercard |
| Título do cartão | `method.title` | `"Mastercard **** 6351"` |
| Tipo do cartão | `method.subtitle` | "Master Crédito" |
| Label do total | `footer.total_label` | "Total" |
| Valor total | `footer.total_amount` | "R$ 100" |
| Token de tracking | `card_data.payment_method_id` | "master" |
| Token de tracking | `card_data.payment_type_id` | "credit_card" |
| Token de tracking | `card_data.issuer_id` | 24 |
| Token de tracking | `card_data.id` | "9720735105" |

---

## Tracking — Melidata

| Path | Tipo | Trigger | Payload |
|---|---|---|---|
| `/checkout_api_native/checkout/payment_brick/cvv` | EVENT | Tela de CVV exibida | `payment_method_id`, `payment_type_id`, `issuer_id`, `card_id` |
| `/checkout_api_native/checkout/payment_brick/cvv_continue` | EVENT | Tap em "Continuar" | — |
| `/checkout_api_native/checkout/payment_brick/cvv_back` | EVENT | Tap em voltar | — |

> Valores de `payment_method_id`, `payment_type_id`, `issuer_id` e `card_id` vêm do `Item` (cartão) selecionado.

> **iOS**: `SecurityCodeViewModel` já tem os 4 métodos de tracking **stubados** (`trackInitialize`, `trackSubmit`, `trackSubmitError`, `trackCanceledError`) — falta implementá-los e criar `SecurityCodeAnalyticsPath`, seguindo o mesmo formato de `OrderAnalyticsPath` (`Domain/Analytics/OrderAnalyticsPath.swift`):
> ```swift
> enum SecurityCodeAnalyticsPath {
>     static let initialize = "/checkout_api_native/checkout/payment_brick/cvv"
>     static let submit = "/checkout_api_native/checkout/payment_brick/cvv_continue"
>     static let userCanceledError = "/checkout_api_native/checkout/payment_brick/cvv_back"
> }
> ```
> `paymentMethodId`/`paymentTypeId`/`issuerId` vivem em `item.cardData`, e `Configuration` agora carrega o `item` inteiro (ver seção de `Configuration` acima) — então os 4 stubs continuam **sem precisar de parâmetros novos**, lendo `self.config.item.cardData?.paymentMethodId`/etc. e `self.config.item.id` internamente, exatamente como a assinatura já existente na branch (`func trackInitialize()`, sem argumentos). `trackInitialize()` precisa ser chamada a partir de `SecurityCodeScreen` (`.onAppear { self.viewModel.trackInitialize() }`) — hoje não é chamada de lugar nenhum.

---

## Dependencies

| Dependência | Tipo | Observação |
|---|---|---|
| `GET /cho-off/v1/payment_brick/initialization` (BFF) | Endpoint existente | `security_code.screen` já presente no contrato |
| `SecurityCodeState` (existente) | Model reutilizado | Reutilizado **sem modificação** — `title` é retornado separadamente, não adicionado à classe |
| **Android** `FetchSecurityCodeScreenUseCase` | UseCase novo | Decide exibir ou pular a tela — executado no `PaymentBrickViewModel`. iOS resolve isso inline (ver `PaymentBrick.handleSelection`) |
| **Android** `FooterState` | Model novo compartilhado | Reutilizável entre telas do PaymentBrick — `totalLabel` + `totalAmount`. iOS reutiliza `MPFooter`/`MPFixedFooterButtonData` (existentes) em vez de criar modelo próprio |
| **Android** `GenerateTokenWithCardIdUseCase` | UseCase novo | Tokeniza o cartão com `cardId` + CVV antes de avançar. iOS já resolve isso direto em `SecurityCodeViewModel.submit(code:)` → `SecurityCodeUseCase`, sem wrapper |
| **Android** `SecurityCodeViewEvent` | Sealed interface nova | `OnTokenSuccess`, `OnTokenError`, `OnUserCancelled` — consumido pelo `CheckoutController` |
| **Android** `PaymentBrickViewModel` | ViewModel do fluxo principal | Scoped ao `CheckoutGraph`; recebe token via `processPaymentMethodWithToken`; exibe `card_form_generic_error` em `onTokenError` |
| **Android** `CheckoutController` | Orquestrador de navegação | Novo destino `SecurityCode`; observa `SecurityCodeViewEvent` e roteia |
| **iOS** `PaymentInitializationOutput.Item.cardData` | Extensão de model (domain) | **Gap real** — `Item` hoje não carrega nada do cartão salvo. Ganha `cardData: CardData?` agrupando `paymentMethodId`/`paymentTypeId`/`issuerId` (não-opcionais dentro do grupo — evita estados inválidos) + `securityCodeScreen: SecurityCodeScreenOutput?` (opcionalidade aninhada, independente). `Item.id` já é o `cardId` |
| **iOS** `SecurityCodeScreenOutput` | Model existente (ajuste pequeno) | Ganha `length` (sai de `Configuration.expectedLength`) e `field.error`; `buttonLabel` **não** é substituído por `footer` — total vem de `PaymentBrickViewModel.transactionAmount`, fora deste model |
| **iOS** `SecurityCodeViewModel` | Já existe | `Views/SecurityCodeViewModel.swift` — `submit(code:)`, `goBack()`, `isTokenizing`, 4 métodos de tracking stubados |
| **iOS** `SecurityCodeUseCase` | UseCase existente | Já implementado com `String code`; ver [Decisão de tokenização iOS](#decisão-de-tokenização-ios) |
| **iOS** `@CardFormValidate` + `SecurityCodeRule` | Já existem | Reaproveitados de `CardFormData`; usados na `SecurityCodeScreen` (View), não no ViewModel |
| **iOS** `MPFooter` / `MPFixedFooterButtonData` / `MPAmountData` | Já existem (design system) | `Sources/MPComponents/BaseElements/Footer/`; cobrem total + botão + loading sem modelo próprio |
| **iOS** `PaymentBrick` | View orquestradora | Novo `Route.securityCode`; closures `onTokenSuccess`, `onTokenError` e `onBack` para `SecurityCodeScreen`; `markScreenPresented(.securityCode)` |
