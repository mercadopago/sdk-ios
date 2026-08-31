# CoreMethods: PCI card tokenization module

`CoreMethods` is a public SDK product (`import CoreMethods`) that tokenizes cards and fetches
payment metadata (payment methods, installments, issuers, identification types). It depends only on
`MPCore` (which it re-exports via `@_exported import MPCore`). This is a **PCI-sensitive** module —
treat raw card data with extreme care.

## Layout (Clean architecture)

```
Sources/CoreMethods/
├── CoreMethods.swift                 # public actor entry point (createToken, installments, ...)
├── CoreMethods+Tracking.swift        # executeWithTracking + AnalyticsPath constants
├── Core/{Extensions, Protocols}      # CoreMethods+CreateToken, InputValidation
├── Domain/
│   ├── Interfaces/                   # CoreMethodsRepositoryProtocol
│   ├── UseCases/                     # GenerateCardTokenUseCase, InstallmentsUseCase, IssuersUseCase, ...
│   └── Analytics/                    # one *EventData per operation (TokenizationEventData, ...)
├── Data/
│   ├── CoreMethodsEndpoint.swift     # RequestEndpoint enum
│   ├── Repositories/                 # CoreMethodsRepository (concrete)
│   ├── Mappers/                      # response DTO → domain mappers
│   └── Model/                        # network DTOs (CardTokenBody, *Response, *Params)
├── Presentation/PCIFieldState/       # secure UITextField wrapper + style
├── Public/Model/                     # CardToken, CardParams, PaymentMethod, Installments, Issuer, ...
└── Public/UI/Fields/                 # CardNumber / ExpirationDate / SecurityCode secure fields
```

## PCI security rules (non-negotiable)
- `PCIFieldState` (`Presentation/PCIFieldState/`) is the only holder of raw secure-field text. Its
  `getValue()` is `internal` and documented "never expose through public interfaces" — keep it that way.
- Read secure values only inside the tokenization path, via `await field.input.getValue()`
  (or `getYear()`/`getMonth()` on `ExpirationDateTextfield`). Reference: `CoreMethods.createToken(...)`.
- **Never** put a raw card number, CVV, or expiration into: a `public` API, a log, or an
  `AnalyticsEventData`. `TokenizationEventData` tracks only `isSaveCard` + `documentType` — follow that.
- The secure UITextField uses `keyboardType = .numberPad`, `autocorrectionType = .no`, and returns
  `false` from `shouldChangeCharactersIn` (it manages its own text/masking). Preserve those.

## Public entry point (`CoreMethods` actor)
- `CoreMethods` is a `public final actor`. It exposes three overloaded `createToken(...)` variants
  (new card / new card + document / saved card by `cardID`) plus `identificationTypes()`, `installments()`,
  `paymentMethods()`, `issuers()`. All are `public async throws`.
- The default `init()` wires real use cases from `CoreDependencyContainer.shared`; a second `internal`
  `init(dependencies:...:)` injects mocks — that one is **for testing only**, keep it non-public.

## Use cases + repository
- One protocol + one `final class` per use case (`GenerateCardTokenUseCaseProtocol` /
  `GenerateCardTokenUseCase`), all `Sendable`, methods `async throws`. Inject the repository (and any
  `Has*` dependency) through `init`.
- `GenerateCardTokenUseCase` assembles `CardTokenBody` (card fields + `BuyerIdentification` +
  device fingerprint from `dependencies.fingerPrint.getDeviceData()` + session/version from
  `MPAnalyticsConfiguration.shared`) and maps the response DTO into the public `CardToken`.
- Validation lives in the use case (`validateExpirationDate`, `validateCardData` throwing
  `CoreMethodsError`), not in the UI field. Security-code length comes from the resolved `PaymentMethod`.

## Networking + analytics
- Add backend calls as cases on `CoreMethodsEndpoint` (conforms to `RequestEndpoint`). Card token POST
  uses `ConstantsEndpoint.baseURLToken`; the rest use `baseURLBricks`. Every request sends `X-Product-id`
  / `product_id` = `MPSDKProduct.id`.
- Wrap every public operation in `executeWithTracking(operation:path:extractEventData:)`
  (`CoreMethods+Tracking.swift`). Success tracks `AnalyticsPath.X`; failure tracks `path + "/error"` with
  `setError`. Tracking is dispatched in a low-priority `Task` and must never affect the returned result.

## Errors
- Throw `CoreMethodsError` (`binIsEmpty`, `cardNumberInvalid`, `securityCodeInvalid`,
  `expirationDateInvalid`, ...) for validation; network failures surface as `APIClientError` from `MPCore`.

## Do / Don't
- DO keep DTOs in `Data/Model` and public-facing types in `Public/Model`; map between them in `Data/Mappers`.
- DON'T bypass `executeWithTracking` for a new public operation.
- DON'T import `MercadoPagoCheckout` or any component/foundation target — `CoreMethods` sits below them.
