# SDK core: MPCore + MPAnalytics

These are the two foundation targets every other module depends on. `MPAnalytics` is a leaf (no
in-package dependencies); `MPCore` depends on `MPAnalytics` + the `DeviceFingerPrint` binary. Nothing
here may import a higher-level target (`CoreMethods`, `MercadoPagoCheckout`, `MPApplePay`, `MPExtended`,
`MPFoundation`, `MPComponents`). Keep this layer UI-agnostic — no `SwiftUI`, no `UIKit`.

## MPCore layout

```
Sources/MPCore/
├── MercadoPagoSDK.swift, MercadoPagoSDK+Country.swift, SDKError.swift   # public SDK entry point
└── Internal/
    ├── Core/{Base, DI, Extensions}   MPSDKProduct, MPSDKVersion, CoreDependencyContainer, FingerPrint
    └── Data/{Network, Repositories, Responses, Interfaces/Repositories}
```

## Access control
- Use `package` for anything other targets need internally (this is the dominant modifier here):
  `NetworkServiceProtocol`, `CoreDependencyContainer`, `HasNetwork`/`HasAnalytics`/`HasFingerPrint`,
  `AnalyticsInterface`, `AnalyticsEventData` are all `package`.
- Reserve `public` for the genuine SDK surface: `MercadoPagoSDK`, `MercadoPagoSDK.Configuration`,
  `MercadoPagoSDK.Country`. Do not widen to `public` to fix a build error — widen to `package` first.

## Dependency injection
- `CoreDependencyContainer` is the composition root and conforms to `typealias DI = Sendable &
  HasNoDependency & HasAnalytics & HasNetwork & HasFingerPrint`. `CoreDependencyContainer.shared` is
  the default instance injected everywhere.
- Add a new shared service by: (1) defining a `HasX` capability protocol (single `var x: XProtocol { get }`,
  `: Sendable`), (2) adding it to the `DI` typealias + `CoreDependencyContainer`, (3) consumers declare
  `typealias Dependency = HasX & ...` and inject via `init(dependencies: Dependency = CoreDependencyContainer.shared)`.
- Note: `analytics` is a computed property returning a fresh `MPAnalytics()` per access (by design —
  each track builds its own event); `networkService` and `fingerPrint` are stored `let`s.

## Networking (`Internal/Data/Network`)
- Requests flow: `RequestEndpoint` enum → `NetworkService.request(_:decoder:)` → decode into `T: Codable & Sendable`.
- Define endpoints as enums conforming to `RequestEndpoint` (see `CoreAPIEndpoint`); compute
  `apiVersion`/`baseURL`/`method`/`path`/`headers`/`urlParams`/`body`. URLs are assembled in `RequestEndpoint`
  — do not hand-build `URLRequest` outside `NetworkService`.
- The convenience overload `request(_ endpoint:)` (default `JSONDecoder()`) is `@discardableResult`.
- Errors: throw `APIClientError` (`invalidURL`, `networkError`, `decodingFailed`); backend error bodies
  decode into `APIErrorResponse`.
- Tests inject a `URLSessionProtocol` (see `MockURLSession`) into `NetworkService(session:)`.

## MPAnalytics
```
Sources/MPAnalytics/  MPAnalytics.swift, MPAnalyticsConfiguration.swift, HasAnalytics.swift,
                      FrameworkType.swift, Models/TrackType.swift, Helpers/{MPBuyerInfo,MPSellerInfo,NetworkMonitor,BundleProtocol}
```
- `MPAnalytics` is a `final class: AnalyticsInterface` wrapping an inner `actor TrackEvent` for thread-safe
  event state. All tracking methods are `async` and `@discardableResult` returning `AnalyticsInterface`
  to support the fluent chain: `await analytics.trackEvent(path).setEventData(data).setError(e).send()`.
- Event payloads conform to `AnalyticsEventData` (`Sendable & Encodable` + `func toDictionary() -> [String: any Sendable]`).
- `MPAnalyticsConfiguration.shared` (an actor/global) holds `version`, `siteID`, `sessionID`. `send()`
  no-ops until `version` and `siteID` are set (i.e. after `MercadoPagoSDK.initialize`).
- Tracking must never block or throw into the caller — `send()` swallows errors; callers dispatch it in
  a detached/low-priority `Task`.

## Concurrency
- Swift 6 strict concurrency. Everything crossing a boundary is `Sendable`. Public/package APIs that do
  I/O are `async throws`. `MPAnalytics.TrackEvent` and `MPAnalyticsConfiguration` are actors.

## Do / Don't
- DO keep `MPCore`/`MPAnalytics` free of `SwiftUI`/`UIKit` and of any higher-target import.
- DO gate cross-target imports with `#if SWIFT_PACKAGE import MPAnalytics #endif` (CocoaPods compatibility).
- DON'T log, persist, or track PII or raw card data from this layer.
- DON'T add a second DI mechanism — extend `CoreDependencyContainer` / the `Has*` protocol set instead.
