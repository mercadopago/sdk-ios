# MercadoPagoCheckout module structure

`Sources/MercadoPagoCheckout` was reorganized (PR #142) to match the layer convention already
used by `CoreMethods`, `MPApplePay`, and `MPExtended`. Follow this layout for any new file —
don't recreate `Bricks/`, `Views/`, or a top-level `Model/` folder; they no longer exist.

## Layout

```
Sources/MercadoPagoCheckout/
├── Public/                    # entry point + public API surface
│   ├── MercadoPagoCheckout(+Builder/+CheckoutType).swift, MP*.swift (public config types)
│   └── Model/                 # public-facing models (MPPaymentData, MercadoPagoCheckoutResult, ...)
├── Domain/
│   ├── Model/                 # domain entities + Use Case/Repository return types
│   │   └── Errors/            # domain error types (BinFetchError, CardAcceptanceError, ...)
│   ├── Repositories/          # repository protocols (incl. CheckoutServiceProtocol)
│   ├── UseCases/
│   └── Analytics/             # one {Feature}AnalyticsPath.swift + {Feature}EventData.swift per feature
├── Data/
│   ├── Repositories/          # concrete Remote* repository implementations
│   ├── Network/               # endpoints
│   └── Model/                 # network request/response DTOs
├── Presentation/
│   ├── Bricks/{Product}/      # top-level product/flow entry points (CardForm/, Payment/, future ones)
│   └── Screens/{Feature}/     # shared flow-step screens+view models, reusable across Bricks
└── Utils/                     # cross-cutting helpers (validation, formatting, extensions)
```

## Rules

- **No loose files at the module root or at `Domain/` root.** Every file belongs in one of the
  subfolders above. If a new file doesn't fit any existing subfolder, that's a signal to ask
  before adding a new one — don't default to dropping it at the top level.
- **`Public/` doesn't require every file to be `public`-tagged.** It also holds internal types
  tightly coupled to the public surface (e.g. `MPCheckoutConfiguration`, an internal type the
  `Builder` constructs; `MercadoPagoCheckoutError+Network.swift`, an internal-only extension of
  the public `MercadoPagoCheckoutError`). Precedent: `CoreMethods/Public/Model/CoreMethodsError.swift`
  is internal-only and still lives in `Public/`.
- **Bricks are products, Screens are shared steps.** A Brick (`CardFormBrick`, `PaymentBrick`, ...)
  is a top-level flow reachable from `MercadoPagoCheckout.show/present/push`. A Screen
  (`CardFormScreen`, `InstallmentScreen`, ...) is a step a Brick composes — screens can be reused
  by more than one Brick, so never nest a Screen's files inside a Brick's folder.
- **`Domain/Model/` must never import `UIKit` or `SwiftUI`.** Domain entities are UI-agnostic.
  If a model needs to expose a UI-specific mapping (e.g. keyboard type), put that mapping in a
  `Presentation`/`Utils` extension instead — see `Utils/Extensions/IdentificationType+Checkout.swift`
  for the pattern to follow.
- **Naming: distinguish "config the screen" from "result of the screen."** Types ending in
  `InitializationOutput` (`CardFormInitializationOutput`, `EmailInitializationOutput`,
  `PaymentInitializationOutput`) are data flowing *into* a screen from the backend. Don't reuse
  a bare `*Output` name for data flowing *out* of a screen after user interaction — name those
  for what they are (e.g. a submission/tokenization result), so the two directions aren't
  confusable at a glance.

## Known gaps (tracked, not yet fixed — don't treat as license to add more of the same)

- `Domain/Model/CardFieldConfig.swift` still imports `UIKit` (`getKeyboardType()` defined inline
  on the Domain struct) — violates the rule above, pending extraction into an extension.
- `Domain/Model/CardFormOutput.swift` still has the ambiguous name the naming rule above warns
  about (it's the CardForm screen's submission result, not init data) — pending rename.
- This module has no dependency-injection container (unlike `CoreMethods`'s
  `CoreDependencyContainer`). Use Cases resolve their concrete repository via a default
  constructor parameter (`init(repository: X = RemoteX())`) instead of a shared container. This
  is a known inconsistency with the rest of the SDK, not an endorsed pattern to keep extending.

## Code Review Rules

### SwiftUI presentation standards

When reviewing added or modified SwiftUI screens, bricks, or presentation view modifiers, first
read these repository guides in full:

- `.agents/skills/swiftui-ui-guidelines/SKILL.md`
- `.agents/skills/swiftui-custom-styles/SKILL.md`

Apply their guidance on view responsibility, state and binding ownership, view identity,
performance-sensitive rendering, and style boundaries. Flag changes that mix business logic into
styles or views, overwrite user input, perform expensive work during rendering, break view identity,
or bypass an established reusable component/style API.
