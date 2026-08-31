# MPApplePay + MPExtended: small independent products

Two small, self-contained public SDK products that share the same shape. Each depends only on `MPCore`
(re-exported via `@_exported import MPCore`) and the `DeviceFingerPrint` binary target. They do **not**
depend on each other, on `CoreMethods`, or on any UI target. Keep them thin: a public entry class, one
use case, one repository, one endpoint, DTOs, and a public result model.

## Shared layout

```
Sources/MPApplePay/                    Sources/MPExtended/
├── MPApplePay.swift  (public entry)   ├── MPExtended.swift  (public entry)
├── Domain/ApplePayUseCase.swift       ├── Domain/DeviceSessionUseCase.swift
├── Data/ApplePayEndpoint.swift        ├── Data/DeviceSessionEndpoint.swift
├── Data/Repositories/                 ├── Data/Repositories/
├── Data/Model/ (Body, Response, EventData)  ├── Data/Model/ (Body, Response)
└── Public/MPApplePayToken.swift       └── Public/MPDeviceSession.swift
```

## Conventions (match the existing files exactly)
- **Entry class** is `public final class` (`MPApplePay`, `MPExtended`), `Sendable` where possible.
  Default `init()` builds the dependency graph from `CoreDependencyContainer.shared`:
  `container → Repository(dependencies:) → UseCase(dependencies:repository:)`. A second `internal`
  init injects the use case for testing — keep it non-public.
- **Use case**: `protocol XUseCaseProtocol: Sendable` + `final class XUseCase: XUseCaseProtocol`.
  Declare `typealias Dependency = HasFingerPrint` (or `HasAnalytics`) and inject via `init`. Methods are
  `async throws` and return a `Public/` model.
- **Repository**: concrete `final class` calling `dependencies.networkService.request(endpoint)`; endpoint
  is an `enum: RequestEndpoint` defined in `Data/`.
- **Device data**: both modules read the fingerprint via `await dependencies.fingerPrint.getDeviceData()`
  and build the request body from it (see `DeviceSessionUseCase.buildBody`, which extracts the
  `"fingerprint"` object and attaches `siteId` from `MercadoPagoSDK.shared.configuration`).

## MPApplePay specifics
- `import PassKit`. Public statics help integrators configure Apple Pay:
  `supportedPKPaymentNetworks()` (Visa, Mastercard, Maestro), `paymentRequest(withMerchantIdentifier:currency:)`,
  `canMakePayments()`. Keep the supported-network list in one place (`supportedPKPaymentNetworks`).
- `createToken(_ paymentToken: PKPaymentToken, status:)` exchanges the Apple Pay token for an
  `MPApplePayToken`. On success and on failure it fires analytics in a `Task.detached`
  (`Analytics.tokenization` / `+ "/error"` with `setError`) and never lets tracking change the throw/return.

## MPExtended specifics
- `deviceSession()` returns `MPDeviceSession`. The body carries `siteId` + the parsed `fingerprint`
  dictionary. Do not leak raw device payloads through the public model beyond what `MPDeviceSession` exposes.

## Do / Don't
- DO keep each module's public surface to its entry class + `Public/` model.
- DO track analytics off the caller's path (detached `Task`) so it never blocks or alters the result.
- DON'T add cross-dependencies between these two modules or up to `CoreMethods`/checkout.
- DON'T expose the raw `DeviceFingerPrint` data or `PKPaymentToken` internals through a `public` API.
