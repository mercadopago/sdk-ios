# Example host app (SDK integration demo)

`Example/` is a standalone host app with its **own** `Example.xcodeproj` and `Podfile` — it is not part
of the `MercadoPagoSDK` Swift Package. Its job is to demonstrate real integration of the SDK products
from a consumer's point of view (SwiftUI + UIKit). Treat it as reference/demo code, not SDK code.

## Layout
```
Example/Sources/
├── ExampleApp.swift, SceneDelegate.swift, MainListView.swift   # app entry + demo menu
├── SwiftUIExample/       # CardFormView + Sections/ + Components/ (SwiftUI CoreMethods integration)
├── UIKit/                # CardFormViewController + Components/ (UIKit CoreMethods integration)
├── Playground/           # CheckoutPlaygroundView, CheckoutConfig, ExclusionsSheet (MercadoPagoCheckout)
├── DeviceSession/        # DeviceSessionView (MPExtended)
├── ThreeDS/ExampleThreeDS.swift
├── Debug/                # DebugView, DebugLogger, DebugLogType
└── CardFormViewModel.swift
```

## Integration conventions (mirror these — they are what we tell integrators to do)
- **Initialize once at launch.** `ExampleAppWrapper.main()` builds a `MercadoPagoSDK.Configuration`
  and calls `MercadoPagoSDK.shared.initialize(_:)` before showing UI. Do this from `@main` /
  AppDelegate / SceneDelegate — never lazily mid-flow.
- **Import only the product(s) a screen needs** (`import CoreMethods`, `import MercadoPagoCheckout`,
  `import MPExtended`). Do not import internal targets (`MPCore`, `MPComponents`, ...) here — a real
  integrator can't, and the demo must stay honest to the public surface.
- **Show both UI paradigms.** CoreMethods secure fields are demoed in both `SwiftUIExample/` and
  `UIKit/` (via `UIViewControllerRepresentable` bridges like `CardFormViewControllerRepresentable`).
  Put shared demo UI in the respective `Components/` folder.
- **Respect API availability.** Newer SwiftUI entry points are guarded with `@available(iOS 14.0, *)`
  and fall back to `SceneDelegate`/`UIApplicationMain` for iOS 13. Keep that dual path working.
- **Add accessibility identifiers** on interactive demo elements (e.g. `.accessibilityIdentifier("checkout.playground")`)
  so `Example/ExampleUITests` can drive them.

## Do / Don't
- DO keep this app consuming only the public SDK API — it's the contract test for our public surface.
- DO route demo logging through the `Debug/` helpers, not stray `print(` (allowed only in `#if DEBUG`).
- DON'T add SDK business logic here; if the demo needs something the public API can't do, that's a
  signal to change the SDK, not to reach into internals.
- DON'T hardcode real public keys or credentials — the sample uses an empty/placeholder key.
