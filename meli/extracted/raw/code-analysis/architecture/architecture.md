# Architecture Analysis — openplatform-sdk-ios

## Overview

iOS SDK client-side para integracao de pagamentos MercadoPago. Nao e um servico backend Fury — e uma biblioteca distribuida para desenvolvedores iOS integrarem em seus aplicativos.

## Stack

| Aspecto | Valor |
|---------|-------|
| Linguagem | Swift 6.0 |
| Plataforma | iOS 13.0+ |
| Concorrencia | Swift Concurrency (async/await, actors, Sendable) |
| UI | UIKit (campos seguros) + SwiftUI (wrappers + components) |
| Network | URLSession nativo |
| Package Managers | Swift Package Manager (principal) + CocoaPods (alternativo) |
| Testes | XCTest + swift-snapshot-testing |
| CI/CD | CircleCI + Fastlane |
| Cobertura minima | 80% (xcov) |

## Architectural Pattern: Clean Architecture

```
Public API (actor CoreMethods)
    |
    v
Domain Layer (Use Cases + Protocols)
    |
    v
Data Layer (Repositories + Network + Mappers)
    |
    v
Infrastructure (URLSession + DeviceFingerPrint.xcframework)
```

## Modulos SPM

```
MPAnalytics         -- Tracking sem dependencias externas
    ^
MPCore              -- SDK init, network, DI, fingerprint
    ^
CoreMethods         -- Tokenizacao, payment methods, 3DS
MPApplePay          -- Integracao Apple Pay
MPFoundation        -- Temas, localizacao, aparencia
    ^
MPComponents        -- Design system (SwiftUI)
    ^
MercadoPagoCheckout -- Bricks pre-montados (NAO e product publico ainda)
```

## Products SPM Publicos

- `CoreMethods`
- `MPApplePay`

## Dependency Injection

Usa protocol composition via typealias:
```swift
typealias DI = Sendable & HasNoDependency & HasAnalytics & HasNetwork & HasFingerPrint
```

Cada componente declara `typealias Dependency = HasX & HasY` e recebe via constructor injection. Container: `CoreDependencyContainer.shared`.

## Patterns Arquiteturais

1. **Clean Architecture**: Domain/Data/Presentation em camadas separadas
2. **Repository Pattern**: `CoreMethodsRepository`, `ThreeDSRepository`, `MPApplePayRepository`
3. **Use Case Pattern**: Um use case por operacao de negocio
4. **Actor Pattern**: `CoreMethods` e um `actor` Swift para thread-safety
5. **Singleton Pattern**: `MercadoPagoSDK.shared`, `CoreDependencyContainer.shared`
6. **Builder Pattern**: `TextFieldDefaultStyle().textColor(.blue).borderWidth(2)`
7. **Strategy Pattern**: `InputValidation` protocol com implementacoes por tipo de campo
8. **UIViewRepresentable Bridge**: Campos UIKit com wrappers SwiftUI correspondentes
