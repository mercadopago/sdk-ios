# openplatform-sdk-ios (MercadoPagoSDK)

Mercado Pago's native iOS payments SDK, distributed as a Swift Package (`Package.name = MercadoPagoSDK`)
and via CocoaPods (`MercadoPagoSDKCoreMethods.podspec`). Minimum deployment target: iOS 13.

## Architecture

A single Swift Package exposing **4 public library products** built on shared internal targets:

| Product (public) | Purpose |
|------------------|---------|
| `CoreMethods` | PCI card tokenization, payment methods, installments, issuers, identification types |
| `MercadoPagoCheckout` | Full checkout UI flow (Bricks + Screens) — see its own rule file |
| `MPApplePay` | Apple Pay (`PKPaymentToken` → Mercado Pago token) |
| `MPExtended` | Device session / fingerprint utilities |

Shared internal targets (not products): `MPCore` (DI, networking, entities, fingerprint),
`MPAnalytics` (Melidata tracking), `MPFoundation` (theme/tokens/localization/resources),
`MPComponents` (SwiftUI + UIKit component kit). `DeviceFingerPrint` is a prebuilt `.xcframework` binary target.

Each feature module follows Clean/Hexagonal layering internally (`Domain` / `Data` / `Presentation` / `Public`).
A separate `Example/` host app (its own `.xcodeproj`, CocoaPods) demonstrates SDK integration in SwiftUI and UIKit.

### Target dependency graph

```
MPAnalytics (leaf)        DeviceFingerPrint (binary .xcframework)
     ▲                          ▲
     └──────── MPCore ──────────┘
                 ▲   ▲   ▲
     ┌───────────┘   │   └───────────┐
 CoreMethods    MPFoundation      MPApplePay, MPExtended
     ▲               ▲            (→ MPCore + DeviceFingerPrint)
     │           MPComponents
     │               ▲
     └──── MercadoPagoCheckout (→ MPComponents, CoreMethods, MPCore, MPAnalytics)
```

Respect this graph. A lower target must never import a higher one (e.g. `MPCore` must not import `CoreMethods`).

## Tech Stack

- **Language:** Swift 6 (`swift-tools-version: 6.0`, strict concurrency)
- **Runtime:** iOS 13+, `defaultLocalization: es-AR`
- **Package manager:** Swift Package Manager (+ CocoaPods for distribution)
- **UI:** SwiftUI and UIKit (both, side by side)
- **Test:** XCTest, `swift-snapshot-testing`, `swift-custom-dump`
- **Tooling:** SwiftLint, SwiftFormat, Fastlane (`scan` + `xcov`) via Bundler, CircleCI

## Commands

| Task | Command | Notes |
|------|---------|-------|
| Build | `xcodebuild build -scheme MercadoPagoSDK-Package -destination "platform=iOS Simulator,name=iPhone 17"` | Builds via Xcode (not `swift build` — see gotcha below) |
| Test + coverage | `bundle exec fastlane test` | The real test entry point (also what CI runs) |
| Lint (check) | `swiftlint` | Config in `.swiftlint.yml` (only lints `Sources/`) |
| Format (autofix) | `make format` | Runs `swiftformat . --config .swiftformat.yml` |
| Snapshot tests | `bundle exec fastlane snapshot_tests` | Runs the `SnapshotTests` target only |
| Record snapshots | `bundle exec fastlane record_snapshots` | Regenerate reference images |

> **Gotcha — do not use `swift build`.** Build via `xcodebuild`/Xcode instead (same scheme and
> simulator destination fastlane's `scan` already uses for tests). Plain SPM CLI builds are not
> the supported way to build this package.

> **Gotcha — do not use `make test`.** The `Makefile` `test` target runs `bundle exec fastlane testes`,
> but no lane named `testes` exists in `fastlane/Fastfile` (only `test`, `snapshot_tests`,
> `record_snapshots`). That is a typo bug in the Makefile. Use `bundle exec fastlane test`.
> Do not silently "fix" the Makefile unless asked.

> **Bundler is required.** Fastlane and xcov are managed through the `Gemfile` (Ruby via rbenv).
> Always prefix fastlane invocations with `bundle exec`.

## Coverage

The test lane enforces coverage via `xcov` (configured in `fastlane/Fastfile`):

- **Real threshold: 80%** (`minimum_coverage_percentage: 80.0`) — this is what CI enforces and what
  you must satisfy. (A generic 75% may appear elsewhere; 80% is the enforced number.)
- `exclude_targets`: `SnapshotTests`, `MercadoPagoCheckoutTests`
- `.xcovignore` skips files by naming convention: `*Screen.swift`, `*Brick.swift`, `*+Compatible13.swift`.
  New SwiftUI screens/bricks are therefore auto-excluded — keep testable logic in `*ScreenViewModel.swift`
  siblings (those stay in the coverage gate).

## Project Structure

```
Sources/
├── MPCore/            # DI (CoreDependencyContainer), networking, entities, fingerprint, SDK entry
│   ├── Internal/Core/{Base,DI,Extensions}   MercadoPagoSDK.swift, MercadoPagoSDK+Country.swift
│   └── Internal/Data/{Network,Repositories,Responses,Interfaces}
├── MPAnalytics/       # Melidata tracking actor, event-data protocol, buyer/seller info
├── CoreMethods/       # PCI tokenization product (Core/Data/Domain/Presentation/Public)
├── MercadoPagoCheckout/  # Checkout UI product (see checkout-module-structure.md)
├── MPApplePay/        # Apple Pay product (Data/Domain/Public)
├── MPExtended/        # Device session product (Data/Domain/Public)
├── MPFoundation/      # MPTheme, tokens, MPStrings localization, Resources (fonts/assets/lproj)
├── MPComponents/      # BaseElements/ + Natives/ SwiftUI+UIKit component kit
└── Frameworks/        # DeviceFingerPrint.xcframework (binary)
Tests/                 # XCTest per target + Common/Mocks + SnapshotTests
Example/               # Host app (own .xcodeproj + Podfile): SwiftUI, UIKit, ThreeDS, DeviceSession
fastlane/Fastfile      # test / snapshot_tests / record_snapshots lanes
```

## Conventions

These are patterns this codebase actually follows — match them.

### Access control
- Use `package` (not `public`) for symbols that must cross targets internally but are **not** part of a
  product's public API. `MPCore`, `MPAnalytics`, `MPFoundation` expose most cross-target API as `package`.
- Reserve `public` for the genuine SDK surface of the 4 products (e.g. `CoreMethods`, `createToken`,
  `MPApplePay`, `MercadoPagoSDK.Configuration`). Do not make something `public` just to silence a build error.

### Dependency injection
- `CoreDependencyContainer.shared` (in `MPCore`) is the composition root. It conforms to capability
  protocols `HasNetwork`, `HasAnalytics`, `HasFingerPrint`, `HasNoDependency` (aliased as `DI`).
- A type declares its needs as `typealias Dependency = HasAnalytics & HasFingerPrint` and injects via
  `init(dependencies: Dependency = CoreDependencyContainer.shared, ...)`. See `CoreMethods.init()`.
- Exception: `MercadoPagoCheckout` deliberately does **not** use the container (use cases default-construct
  their repositories). This is a known inconsistency — see `Sources/MercadoPagoCheckout/AGENTS.md`.

### Concurrency (Swift 6, strict)
- Everything crossing an isolation boundary is `Sendable`. Network/use-case/repository APIs are `async throws`.
- `CoreMethods` is an `actor`. `MPAnalytics` is a `package final class` wrapper whose nested `TrackEvent`
  actor owns mutable event state; await the tracking API for that actor-managed state, not because the wrapper
  itself is actor-isolated. `PCIFieldState` and SwiftUI views are `@MainActor`.
- Fire-and-forget analytics runs in a detached / low-priority `Task` so tracking never blocks the caller.

### Networking
- Define endpoints as an `enum` conforming to `RequestEndpoint` — one case per call, with computed
  `apiVersion`/`baseURL`/`method`/`path`/`headers`/`urlParams`/`body`. Reference: `CoreMethodsEndpoint`.
- Repositories call `dependencies.networkService.request(endpoint)`; the generic decodes into
  `T: Codable & Sendable`. Do not build `URLRequest`s by hand outside `MPCore`.

### Analytics
- Track with the fluent chain: `await analytics.trackEvent(path).setEventData(data).send()`
  (and `.setError(...)` on the failure path). Event payloads conform to `AnalyticsEventData`
  (`Encodable & Sendable` + `toDictionary()`). One `*EventData` type per tracked operation.
- Wrap SDK operations in `CoreMethods.executeWithTracking(...)` (see `CoreMethods+Tracking.swift`).

### Dual distribution guard
- SPM-only imports of sibling targets are wrapped: `#if SWIFT_PACKAGE import MPCore #endif`. Keep this
  guard when adding cross-target imports so the CocoaPods build keeps working.

### PCI security (non-negotiable)
- Raw secure-field values (card number, expiration, CVV) are read only via `PCIFieldState.getValue()` /
  the field's `.input.getValue()`, and only inside the tokenization path. **Never** expose raw field
  values through any `public` API, log them, or route them into analytics event data.

### File hygiene
- Every source file starts with the standard header comment block; keep it. `#Preview`/`#if DEBUG`
  scaffolding is allowed but must be inside `#if DEBUG`.

## Scoped instructions

More specific `AGENTS.md` files live under each source area and `Tests/`. When working in one of
those directories, follow both this root file and the closest scoped instructions. The `.claude/rules/`
files remain compatibility inputs for Claude; their Codex counterparts are the hierarchical
`AGENTS.md` files committed beside the relevant code.

## Shared skills

Team skills are versioned in `.agents/skills/` and are the canonical project copies for Codex and
Claude. Entries under `.claude/skills/` are relative symlinks to the same directories. Keep the
symlinks intact and update the canonical copy so every developer and both agents receive the change.

## Code Review Rules

### Swift Concurrency

When reviewing any added or modified Swift source file, first read
`.agents/skills/swift-concurrency/SKILL.md` in full. Apply its guidance on Swift language mode,
isolation boundaries, `Sendable`, actors, `@MainActor`, structured concurrency, cancellation, and
unsafe concurrency escape hatches. Flag changes that can introduce a data race, break an isolation
boundary, misuse `Task.detached`, or add `@preconcurrency`, `@unchecked Sendable`, or
`nonisolated(unsafe)` without a documented safety invariant and follow-up migration plan.
