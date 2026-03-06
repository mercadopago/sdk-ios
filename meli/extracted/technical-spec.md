# Technical Spec — openplatform-sdk-ios

**Versao**: 0.2.3
**Gerado**: 2026-03-06
**Modo**: Reverse Engineering (FULL EXTRACTION)

---

## 1. Stack Tecnica

| Aspecto | Valor | Confianca |
|---------|-------|-----------|
| Linguagem | Swift 6.0 | ✅✅ |
| Plataforma minima | iOS 13.0+ | ✅✅ |
| Swift Tools Version | 6.0 | ✅✅ |
| Concorrencia | Swift Concurrency (async/await, actors, Sendable) | ✅✅ |
| UI (Secure Fields) | UIKit | ✅✅ |
| UI (Components/Bricks) | SwiftUI + UIViewRepresentable | ✅✅ |
| Network | URLSession nativo (sem libs terceiras) | ✅✅ |
| Package Manager | Swift Package Manager (principal) | ✅✅ |
| Package Manager alt. | CocoaPods via `.podspec` | ✅✅ |
| Testes | XCTest + swift-snapshot-testing (1.17.6+) | ✅✅ |
| Linting | SwiftLint + SwiftFormat | ✅✅ |
| CI/CD | CircleCI + Fastlane | ✅✅ |
| Cobertura minima | 80% (xcov) | ✅✅ |
| Localizacao padrao | es-AR | ✅✅ |
| Licenca | Apache 2.0 | ✅✅ |

---

## 2. Arquitetura

### 2.1 Padrao Arquitetural: Clean Architecture

```
[Public API]
    CoreMethods (actor)
    MPApplePay
    MercadoPagoSDK
        |
[Domain Layer]
    Use Cases
    Repository Protocols
        |
[Data Layer]
    Repositories
    Network Service
    Endpoints
    Mappers
        |
[Infrastructure]
    URLSession
    DeviceFingerPrint.xcframework
```

### 2.2 Modulos SPM

```
Package.swift define os seguintes targets:

Libraries (products publicos):
  - CoreMethods    → target CoreMethods
  - MPApplePay     → target MPApplePay

Targets internos (nao publicos):
  - MPCore         (depende de: MPAnalytics, DeviceFingerPrint binary)
  - MPAnalytics    (sem dependencias)
  - MPFoundation   (depende de: MPCore)
  - MPComponents   (depende de: MPFoundation)
  - MercadoPagoCheckout (depende de: MPComponents, CoreMethods) — EM DESENVOLVIMENTO

Targets de teste:
  - CoreMethodsTests
  - AnalyticsTests
  - MPCoreTests
  - MPApplePayTests
  - SnapshotTests (usa swift-snapshot-testing)
```

### 2.3 Grafo de Dependencias

```
MPAnalytics
    ^
    |
MPCore ←── DeviceFingerPrint.xcframework (binario)
    ^
    |
CoreMethods ──► CoreMethodsTests
MPApplePay  ──► MPApplePayTests
MPFoundation
    ^
    |
MPComponents
    ^
    |
MercadoPagoCheckout (nao publicado)
```

---

## 3. API Publica

### 3.1 `MercadoPagoSDK` — Entry Point (Singleton)

```swift
public final class MercadoPagoSDK: @unchecked Sendable {

    public static let shared: MercadoPagoSDK

    public struct Configuration: Sendable {
        public init(publicKey: String, locale: String, country: Country)
    }

    public func initialize(_ configuration: Configuration)
    public func setNewConfiguration(_ configuration: Configuration)
}
```

**Arquivo**: `Sources/MPCore/MercadoPagoSDK.swift`

### 3.2 `MercadoPagoSDK.Country` — Enum de Paises

```swift
@frozen public enum Country: String, Sendable {
    case ARG  // MLA
    case BRA  // MLB
    case COL  // [BUG: mapeado para "MLC" em vez de "MCO"]
    case MEX  // MLM
    case CHL  // MLC
    case NIC  // MNI
    case PAN  // MPA
    case ECU  // MEC
    case HND  // MHN
    case GTM  // MGT
    case SLV  // MSV
    case CUB  // MCU
    case PRY  // MPY
    case DOM  // MRD
    case PER  // MPE
    case BOL  // MBO
    case CRI  // MCR
    case VEN  // MLV
    case URY  // MLU
}
```

### 3.3 `SDKError`

```swift
public enum SDKError: String {
    case notInitialized
    case alreadyInitialized
    case invalidPublicKey
    case countryInvalid
}
```

### 3.4 `CoreMethods` — Actor Principal

```swift
public final actor CoreMethods {

    public struct Configuration: Sendable {
        public var threeDS: ThreeDS
        public struct ThreeDS: Sendable { /* 3DS-specific config */ }
        public init()
    }

    public init(configuration: Configuration = Configuration())
    public func setConfiguration(_ newConfiguration: Configuration)

    // Tokenizacao
    public func createToken(
        cardNumber: CardNumberTextField,
        expirationDate: ExpirationDateTextfield,
        securityCode: SecurityCodeTextField,
        cardHolderName: String?
    ) async throws -> CardToken

    public func createToken(
        cardNumber: CardNumberTextField,
        expirationDate: ExpirationDateTextfield,
        securityCode: SecurityCodeTextField,
        documentType: IdentificationType,
        documentNumber: String,
        cardHolderName: String
    ) async throws -> CardToken

    public func createToken(
        cardID: String,
        expirationDate: ExpirationDateTextfield?,
        securityCode: SecurityCodeTextField
    ) async throws -> CardToken

    public func createToken(_ params: CardParams) async throws -> CardToken

    // Consultas
    public func identificationTypes() async throws -> [IdentificationType]
    public func installments(amount: Double, bin: String, mode: ProcessingMode = .aggregator) async throws -> [Installment]
    public func paymentMethods(bin: String, mode: ProcessingMode = .aggregator) async throws -> [PaymentMethod]
    public func issuers(bin: String, paymentMethodID: String) async throws -> [Issuer]

    // 3DS
    public func sendDeviceData(
        cardTokenId: String,
        appId: String,
        deviceData: String,
        referenceNumber: String,
        ephemeralPublicKey: String,
        transactionID: String
    ) async throws

    public func challengeParameters(_ id: String) async throws -> MPThreeDSChallengeParameters
    public func finishChallenge(_ id: String) async throws
    public func cancelChallenge(_ id: String) async throws
    public func errorChallenge(_ id: String, errorCode: String, errorMessageType: String) async throws
    public func timeoutChallenge(_ id: String) async throws
}
```

**Arquivo**: `Sources/CoreMethods/CoreMethods.swift`

### 3.5 `MPApplePay`

```swift
public final class MPApplePay: Sendable {
    public init()
    public static func supportedPKPaymentNetworks() -> [PKPaymentNetwork]  // visa, masterCard, maestro
    public static func paymentRequest(withMerchantIdentifier: String, currency: String) -> PKPaymentRequest
    public static func canMakePayments() -> Bool
    public func createToken(_ paymentToken: PKPaymentToken, status: String?) async throws -> MPApplePayToken
}
```

---

## 4. Modelos de Dados Publicos

### 4.1 `CardToken`

```swift
public struct CardToken: Sendable {
    public let token: String
    public let publicKey: String
    public let bin: String?
    public let expirationMonth: Int
    public let expirationYear: Int
    public let lastFourDigits: String
    public let cardHolder: CardHolder
    public let status: String
    public let dateCreated: String
    public let luhnValidation: Bool
    public let liveMode: Bool
}

public struct CardHolder: Sendable {
    public let identification: Identification?
    public let name: String?
}

public struct Identification: Sendable {
    public let type: String?
}
```

### 4.2 `CardParams`

```swift
public struct CardParams: Sendable {
    public let cardNumber: String
    public let expirationYear: Int
    public let expirationMonth: Int
    public let securityCode: String
    public let documentType: String?
    public let documentNumber: String?
    public let cardHolderName: String?
}
```

### 4.3 `IdentificationType`

```swift
public struct IdentificationType: Sendable {
    public let id: String
    public let name: String
    public let type: String
    public let minLenght: Int
    public let maxLenght: Int
}
```

### 4.4 `Installment` e `PayerCost`

```swift
public struct Installment: Sendable {
    public let paymentMethodId: String
    public let paymentTypeId: String
    public let thumbnail: String?
    public let issuer: Issuer?
    public let processingMode: String
    public let payerCosts: [PayerCost]
    public let agreements: [Agreement]?
}

public struct PayerCost: Sendable {
    public let installments: Int
    public let installmentAmount: Double
    public let installmentRate: Double
    public let totalAmount: Double
    public let minAllowedAmount: Double
    public let maxAllowedAmount: Double
    public let labels: [String]
}
```

### 4.5 `Issuer`

```swift
public struct Issuer: Sendable {
    public let id: Int
    public let name: String
    public let merchantAccountId: String?
    public let processingMode: String?
    public let status: String?
    public let thumbnail: String?
}
```

### 4.6 `PaymentMethod`

```swift
public struct PaymentMethod: Sendable {
    public let id: String
    public let paymentTypeId: String
    public let status: String
    public let processingMode: String
    public let accreditationTime: Int?
    public let siteId: String?
    public let card: CardInfo?
    public let issuer: IssuerInfo?
    public let financialInstitution: FinancialInstitution?
    public let bins: [BinInfo]?
    public let agreements: [Agreement]?
    public let payerCosts: [PayerCost]?
    public let additionalInfoNeeded: [String]?
}
```

### 4.7 `ProcessingMode`

```swift
public enum ProcessingMode: String, Sendable {
    case aggregator
    case gateway
}
```

### 4.8 `MPApplePayToken`

```swift
public struct MPApplePayToken: Sendable {
    public let id: String
    public let bin: String?
}
```

### 4.9 `MPThreeDSChallengeParameters`

```swift
public struct MPThreeDSChallengeParameters: Sendable {
    public let status: ThreeDSStatus  // .authenticated | .challenge
    public let acsReferenceNumber: String?
    public let dsTransID: String?
    public let acsTransID: String?
    public let acsSignedContent: String?
}

public enum MPThreeDSDirectoryServer {
    case visa, debvisa, master, debmaster, amex
    public var id: String { /* retorna o directory server ID */ }
}
```

### 4.10 `APIClientError`

```swift
public enum APIClientError: Error {
    case invalidURL
    case invalidResponse(Data)
    case requestFailed(Error)
    case decodingFailed(Error)
    case notExpectedHttpResponseCode(code: Int)
    case urlRequestIsEmpty
    case statusCode(Int)
    case networkError(Error)
    case apiError(APIErrorResponse)
}

public struct APIErrorResponse: Codable, Equatable, Sendable {
    public let code: String
}
```

---

## 5. Secure Fields (UI)

### 5.1 Campos UIKit

| Classe | Herda de | Callbacks publicos | Metodos publicos |
|--------|----------|-------------------|-----------------|
| `PCITextField` | UIView | - | `isValid`, `count`, `isEnabled`, `setStyle()`, `setPlaceholder()`, `setLeftImage()`, `setRightImage()`, `clear()`, `focus()`, `resignFocus()`, `isInputFocused` |
| `CardNumberTextField` | PCITextField | `onBinChanged`, `onLastFourDigitsFilled`, `onFocusChanged`, `onLengthChanged`, `onError` | `setMaxLength()`, `setMask()` |
| `SecurityCodeTextField` | PCITextField | `onLengthChanged`, `onInputFilled`, `onFocusChanged`, `onError` | `setMaxLength()` |
| `ExpirationDateTextfield` | PCITextField | `onLengthChanged`, `onInputFilled`, `onFocusChanged`, `onError` | `setFormat(.short / .long)` |

### 5.2 Wrappers SwiftUI (UIViewRepresentable)

| Struct | Wraps |
|--------|-------|
| `CardNumberTextFieldView` | `CardNumberTextField` |
| `SecurityCodeTextFieldView` | `SecurityCodeTextField` |
| `ExpirationDateTextFieldView` | `ExpirationDateTextfield` |

### 5.3 Sistema de Style (Builder Pattern)

```swift
public protocol PCIFieldStateStyleProtocol {
    var textColor: UIColor { get }
    var font: UIFont { get }
    var textAlignment: NSTextAlignment { get }
    var adjustsFontSizeToFitWidth: Bool { get }
    var minimumFontSize: CGFloat { get }
    var placeholderColor: UIColor { get }
    var placeholderFont: UIFont? { get }
    var backgroundColor: UIColor { get }
    var borderColor: UIColor { get }
    var borderWidth: CGFloat { get }
    var cornerRadius: CGFloat { get }
    var borderStyle: UITextField.BorderStyle { get }
    var clearButtonMode: UITextField.ViewMode { get }
    var clearButtonTintColor: UIColor? { get }
    var opacity: Float { get }
}

// Builder pattern:
TextFieldDefaultStyle()
    .textColor(.black)
    .font(.systemFont(ofSize: 16))
    .borderWidth(1)
    .cornerRadius(8)
    .backgroundColor(.white)
```

---

## 6. Endpoints REST Consumidos

| Operacao | Method | URL |
|----------|--------|-----|
| Card Token | POST | `https://api.mercadopago.com/v1/card_tokens` |
| Identification Types | GET | `https://api.mercadopago.com/cho-off/v1/identification_types` |
| Installments | GET | `https://api.mercadopago.com/cho-off/v1/installments` |
| Payment Methods | GET | `https://api.mercadopago.com/cho-off/v1/payment_methods` |
| Issuers | GET | `https://api.mercadopago.com/cho-off/v1/card_issuers` |
| 3DS Device Data | POST | `https://api.mercadopago.com/cho-off/beta/v1/challenges/threeds/device` |
| 3DS Challenge GET | GET | `https://api.mercadopago.com/cho-off/beta/v1/challenges/threeds/{id}/authenticate` |
| 3DS Challenge UPDATE | PATCH | `https://api.mercadopago.com/cho-off/beta/v1/challenges/threeds/{id}/authenticate` |
| Apple Pay Tokenize | POST | `https://api.mercadopago.com/platforms/pci/applepay/v1/tokenize` |
| Analytics | POST | `https://api.mercadolibre.com/tracks` |

### 6.1 Headers de Autenticacao

| Header | Endpoints | Descricao |
|--------|-----------|-----------|
| `?public_key=` (query param) | Todos | Chave publica do desenvolvedor |
| `X-Public-Key` | 3DS, Apple Pay | Chave publica (header) |
| `X-Product-id` | Tokenizacao, Apple Pay | Identificador do produto SDK |
| `Meli-Session-id` | Tokenizacao | ID de sessao |
| `SDK-version` | Tokenizacao | Versao do SDK |
| `X-Test-Status` | Apple Pay | Ambiente de teste (opcional) |

---

## 7. Camadas Internas

### 7.1 Use Cases

| Use Case | Operacao |
|----------|----------|
| `GenerateCardTokenUseCase` | Tokenizacao de cartao (novo e salvo) |
| `IdentificationTypeUseCase` | Consulta de tipos de documento |
| `InstallmentsUseCase` | Consulta de parcelas |
| `PaymentMethodUseCase` | Consulta de meios de pagamento |
| `IssuersUseCase` | Consulta de emissores |
| `CapabilityUseCase` | Verificacao de capacidades do metodo de pagamento |
| `ApplePayUseCase` | Tokenizacao Apple Pay |
| `FetchSiteIDUseCase` | Obtencao do SiteID a partir do Country |

### 7.2 Repositories

| Repository | Protocolo | Implementacao |
|------------|-----------|--------------|
| `CoreMethodsRepositoryProtocol` | Domain | `CoreMethodsRepository` |
| `ThreeDSRepositoryProtocol` | Domain | `ThreeDSRepository` |
| `SiteRepositoryProtocol` | Domain | `SiteRepository` |
| `MPApplePayRepository` | - | Implementacao direta |

### 7.3 Network Layer

```
NetworkServiceProtocol
    └── NetworkService (URLSession based)
        ├── RequestEndpoint (HTTPMethod, APIVersion, path, headers, body)
        └── APIClientError (erros tipados)
```

---

## 8. Validacoes

| Campo | Validacao | Algoritmo |
|-------|-----------|-----------|
| `CardNumberTextField` | Formato + Luhn | `CardNumberValidation` com algoritmo Luhn |
| `SecurityCodeTextField` | Comprimento minimo/maximo | `SecurityCodeValidation` |
| `ExpirationDateTextfield` | Formato (MM/YY ou MM/YYYY), data valida, nao expirado | `ExpirationDateValidation` |

### Erros de Validacao

```swift
public enum CardNumberError { case invalidCharacters, invalidLuhn, invalidLength, empty, none }
public enum SecurityCodeError { case invalidLength, empty, none }
public enum ExpirationDateError { case invalidFormat, invalidDate, invalidLength, expired, empty, none }
```

---

## 9. Analytics

- Modulo `MPAnalytics` independente (sem dependencias externas)
- Actor `MPAnalytics.TrackEvent` garante thread-safety
- Eventos rastreados: inicializacao SDK, load/focus de campos, createToken (success/error), paymentMethods, installments, issuers, identificationTypes, Apple Pay
- Dados coletados: device info, iOS version, conectividade (`NetworkMonitor`), bundle ID, UID
- Endpoint: `POST https://api.mercadolibre.com/tracks`

---

## 10. Dependency Injection

```swift
// Protocol composition para DI
typealias DI = Sendable & HasNoDependency & HasAnalytics & HasNetwork & HasFingerPrint

// Cada componente declara suas dependencias:
class CoreMethodsRepository {
    typealias Dependency = HasNetwork & HasAnalytics
    init(dependencies: Dependency)
}
```

Container: `CoreDependencyContainer.shared` (singleton, substitivel em testes via mocks).

---

## 11. Testes

| Target | Foco | Ferramentas |
|--------|------|-------------|
| `CoreMethodsTests` | Tokenizacao, payment methods, 3DS, UI fields | XCTest + Mocks |
| `AnalyticsTests` | MPAnalytics, BuyerInfo, SellerInfo | XCTest |
| `MPCoreTests` | MercadoPagoSDK, NetworkService, RequestEndpoint | XCTest + MockURLSession |
| `MPApplePayTests` | MPApplePay, Repository, UseCase | XCTest |
| `SnapshotTests` | Regressao visual (campos + components) | swift-snapshot-testing |

Mocks em `Tests/Common/Mocks/`: `MockAnalytics`, `MockDependencyContainer`, `MockFingerPrint`, `MockURLSession`.

---

## 12. CI/CD Pipeline (CircleCI)

| Job | Trigger | Acoes |
|-----|---------|-------|
| `build-and-test` | branches != main | SwiftLint + SwiftFormat + Tests + xcov |
| `snapshot-tests` | branches != main (apos build-and-test) | Testes de snapshot |
| `generate-doc` | main only | Gera DocC, faz deploy no GitHub Pages |
| `publish-release` | main only | Verifica VERSION vs ultimo tag Git, publica se diferente |

---

## 13. Notas de Implementacao

### Bug Conhecido
`Country.COL` retorna SiteID `"MLC"` (Chile) em vez de `"MCO"` (Colombia).
**Arquivo**: `Sources/MPCore/Internal/Core/Extensions/Country+SiteID.swift`

### DeviceFingerPrint.xcframework
Framework binario proprietario pre-compilado. Interface conhecida:
```swift
protocol FingerPrintProtocol {
    func getDeviceData() -> String
}
```
Localizado em `Sources/Frameworks/DeviceFingerPrint.xcframework`.

### MercadoPagoCheckout (Em Desenvolvimento)
Modulo `MercadoPagoCheckout` com `CardFormBrick` existe em `Sources/MercadoPagoCheckout/` mas nao e exposto como product SPM publico. NAO usar em producao sem confirmacao de GA.
