# PATTERNS.md — openplatform-sdk-ios

**Gerado**: 2026-03-06
**Fonte**: Analise de codigo (reverse engineering)

---

## 1. Clean Architecture com Protocol Composition para DI

**Categoria**: Architecture

**Evidence**:
- `Sources/MPCore/Internal/Core/DI/CoreDependencyContainer.swift`
- `Sources/CoreMethods/Data/Repositories/CoreMethodsRepository.swift`
- `Sources/CoreMethods/Domain/Interfaces/CoreMethodsRepositoryProtocol.swift`
- `Sources/MPApplePay/Domain/ApplePayUseCase.swift`

**Exemplo**:
```swift
// 1. Declare suas dependencias via protocol
typealias DI = Sendable & HasNoDependency & HasAnalytics & HasNetwork & HasFingerPrint

// 2. Componente recebe via constructor injection
class CoreMethodsRepository {
    typealias Dependency = HasNetwork & HasAnalytics
    init(dependencies: Dependency) { ... }
}

// 3. Container resolve
class CoreDependencyContainer: DI {
    static let shared = CoreDependencyContainer()
}
```

**Quando usar**: Ao criar novos repositories, use cases ou services que dependem de network, analytics ou fingerprint. Sempre declare o `typealias Dependency` e receba via init para facilitar testes.

---

## 2. Actor Swift para API Publica Thread-Safe

**Categoria**: Concorrencia

**Evidence**:
- `Sources/CoreMethods/CoreMethods.swift` — `public final actor CoreMethods`
- `Sources/MPAnalytics/MPAnalytics.swift` — `actor TrackEvent` (interno)

**Exemplo**:
```swift
public final actor CoreMethods {
    public init(configuration: Configuration = Configuration()) { ... }

    public func createToken(...) async throws -> CardToken {
        // Swift garante exclusividade de acesso automaticamente
    }
}
```

**Quando usar**: Toda classe publica que mantém estado mutável e pode ser chamada de múltiplas tasks concorrentes deve ser `actor`. Use `@unchecked Sendable` apenas para singletons com sincronizacao propria (ex: `MercadoPagoSDK`).

---

## 3. Repository + Use Case + Protocol para Operacoes de Negocio

**Categoria**: Architecture / Data Access

**Evidence**:
- `Sources/CoreMethods/Domain/UseCases/GenerateCardTokenUseCase.swift`
- `Sources/CoreMethods/Domain/UseCases/InstallmentsUseCase.swift`
- `Sources/CoreMethods/Domain/UseCases/PaymentMethodUseCase.swift`
- `Sources/CoreMethods/Domain/UseCases/IssuersUseCase.swift`
- `Sources/CoreMethods/Domain/UseCases/IdentificationTypeUseCase.swift`
- `Sources/CoreMethods/Domain/UseCases/CapabilityUseCase.swift`

**Exemplo**:
```swift
// 1. Protocol no Domain (testavel, substituivel)
protocol CoreMethodsRepositoryProtocol {
    func createToken(_ body: CardTokenBody) async throws -> CardTokenResponse
}

// 2. Use Case orquestra logica
class GenerateCardTokenUseCase {
    let repository: CoreMethodsRepositoryProtocol
    func execute(params: CardParams) async throws -> CardToken { ... }
}

// 3. Repository implementa o acesso a dados
class CoreMethodsRepository: CoreMethodsRepositoryProtocol {
    func createToken(_ body: CardTokenBody) async throws -> CardTokenResponse {
        try await networkService.request(CoreMethodsEndpoint.cardToken(body))
    }
}
```

**Quando usar**: Para toda nova feature que acesse dados externos (APIs), crie: Protocol no Domain + Use Case + Repository concreto. Nao acesse network diretamente do actor/viewmodel.

---

## 4. UIViewRepresentable Bridge para Campos UIKit em SwiftUI

**Categoria**: UI / Interoperabilidade

**Evidence**:
- `Sources/CoreMethods/Public/UI/Fields/CardNumber/CardNumberTextFieldView.swift`
- `Sources/CoreMethods/Public/UI/Fields/SecurityCode/SecurityCodeTextFieldView.swift`
- `Sources/CoreMethods/Public/UI/Fields/ExpirationDate/ExpirationDateTextFieldView.swift`

**Exemplo**:
```swift
public struct CardNumberTextFieldView: UIViewRepresentable {
    public typealias UIViewType = CardNumberTextField

    public func makeUIView(context: Context) -> CardNumberTextField {
        CardNumberTextField()
    }

    public func updateUIView(_ uiView: CardNumberTextField, context: Context) {
        // sincroniza estado SwiftUI -> UIKit
    }
}
```

**Quando usar**: Sempre que um componente UIKit precisa ser usado em SwiftUI. Crie um wrapper `UIViewRepresentable` correspondente mantendo o mesmo nome com sufixo `View`.

---

## 5. Builder Pattern para Customizacao de Style

**Categoria**: UI / API Design

**Evidence**:
- `Sources/CoreMethods/Presentation/PCIFieldState/PCIFieldStateStyle.swift`
- `Sources/CoreMethods/Public/UI/Fields/PCITextField.swift`

**Exemplo**:
```swift
// Builder retorna Self para encadeamento
class TextFieldDefaultStyle: PCIFieldStateStyleProtocol {
    @discardableResult
    func textColor(_ color: UIColor) -> Self { ... return self }

    @discardableResult
    func borderWidth(_ width: CGFloat) -> Self { ... return self }
}

// Uso:
let style = TextFieldDefaultStyle()
    .textColor(.black)
    .font(.systemFont(ofSize: 16))
    .borderWidth(1)
    .cornerRadius(8)

field.setStyle(style, for: .idle)
field.setStyle(errorStyle, for: .error)
```

**Quando usar**: Para APIs de customizacao onde o consumidor precisa configurar multiplos atributos opcionais. Prefira ao pattern de struct com muitas propriedades opcionais.

---

## 6. Strategy Pattern para Validacao de Campos

**Categoria**: Validation / Domain

**Evidence**:
- `Sources/CoreMethods/Core/Protocols/InputValidation.swift`
- `Sources/CoreMethods/Public/UI/Fields/CardNumber/CardNumberValidation.swift`
- `Sources/CoreMethods/Public/UI/Fields/SecurityCode/SecurityCodeValidation.swift`
- `Sources/CoreMethods/Public/UI/Fields/ExpirationDate/ExpirationDateValidation.swift`

**Exemplo**:
```swift
protocol InputValidation {
    func validate(_ input: String) -> ValidationResult
}

struct CardNumberValidation: InputValidation {
    func validate(_ input: String) -> ValidationResult {
        guard luhnCheck(input) else { return .failure(.invalidLuhn) }
        return .success
    }
}

struct ExpirationDateValidation: InputValidation {
    func validate(_ input: String) -> ValidationResult {
        // verifica formato, data valida, nao expirado
    }
}
```

**Quando usar**: Ao adicionar novos tipos de campo de entrada, crie uma implementacao de `InputValidation` correspondente. Mantenha a logica de validacao separada da UI.

---

## 7. Analytics Automatico com Decorator Implicito

**Categoria**: Observability / Cross-cutting

**Evidence**:
- `Sources/CoreMethods/CoreMethods+Tracking.swift`
- `Sources/MPCore/MercadoPagoSDK.swift` (evento de init)
- `Sources/CoreMethods/Public/UI/Fields/PCITextField.swift` (load/focus events)

**Exemplo**:
```swift
// Em CoreMethods+Tracking.swift, extensao separada para tracking
extension CoreMethods {
    func trackCreateToken(result: Result<CardToken, Error>) {
        let event = CreateTokenEventData(success: result.isSuccess, ...)
        analytics.track(event)
    }
}

// No metodo principal:
public func createToken(...) async throws -> CardToken {
    do {
        let token = try await generateCardTokenUseCase.execute(...)
        trackCreateToken(result: .success(token))
        return token
    } catch {
        trackCreateToken(result: .failure(error))
        throw error
    }
}
```

**Quando usar**: Mantenha tracking em extensoes separadas (`+Tracking.swift`) para nao poluir a logica principal. Todo metodo publico que represente uma acao do usuario deve ter tracking de success e error.

---

## 8. MockURLSession para Testes de Network

**Categoria**: Testing

**Evidence**:
- `Tests/Common/Mocks/MockURLSession.swift`
- `Tests/MPCoreTests/Network/NetworkServiceTests.swift`
- `Tests/CoreMethodsTests/` (varios testes de repository)

**Exemplo**:
```swift
class MockURLSession: URLSessionProtocol {
    var stubbedResponse: (Data, URLResponse)?
    var stubbedError: Error?

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = stubbedError { throw error }
        return stubbedResponse ?? (Data(), HTTPURLResponse())
    }
}

// Em testes:
let mockSession = MockURLSession()
mockSession.stubbedResponse = (jsonData, HTTPURLResponse(statusCode: 200))
let repository = CoreMethodsRepository(dependencies: MockDependencyContainer(session: mockSession))
```

**Quando usar**: Sempre ao testar repositories ou use cases que fazem chamadas de rede. Injete `MockURLSession` via `MockDependencyContainer` — nunca faca chamadas reais em unit tests.

---

## 9. Snapshot Tests para Regressao Visual de Campos

**Categoria**: Testing / UI

**Evidence**:
- `Tests/SnapshotTests/CoreMethods/` (CardNumber, SecurityCode, ExpirationDate snapshots)
- `Tests/SnapshotTests/MPComponents/` (componentes SwiftUI)
- `fastlane/Fastfile` — lane `snapshot_tests` e `record_snapshots`

**Exemplo**:
```swift
import SnapshotTesting

class CardNumberSnapshotTests: XCTestCase {
    func testCardNumberTextField_idle() {
        let field = CardNumberTextField()
        assertSnapshot(matching: field, as: .image(on: .iPhone13))
    }
}
```

**Quando usar**: Ao adicionar novos componentes visuais (campos, telas, bricks), crie snapshot tests correspondentes. Use `record_snapshots` da fastlane para gerar referencias. Execute via `snapshot_tests` lane no CI.
