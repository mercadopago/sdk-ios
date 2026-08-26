# Design system: MPFoundation + MPComponents

This is the SDK's native design system (not a web/Nordic one). `MPFoundation` holds the theme
contract, design tokens, localization, and bundled resources (fonts, assets, `.lproj`).
`MPComponents` builds reusable SwiftUI + UIKit components on top of it. Dependency direction:
`MPComponents → MPFoundation → MPCore`. Never import `CoreMethods` or `MercadoPagoCheckout` here.

## MPFoundation
```
Sources/MPFoundation/
├── MPTheme.swift            # theme + token protocols (MPColors, MPSpacings, MPTypography, ...)
├── ThemeProvider.swift      # SwiftUI provider + @Environment(\.checkoutTheme)
├── Themes/LightTheme/MPLightTheme.swift
├── Appearance/{Button,TextField}/   # MPButtonAppearance, MPButtonSize, MPTextFieldAppearance
├── Localization/MPStrings*.swift     # MPStrings + per-feature extensions
├── Extensions/              # Color+Hex, View+Loading, View+HasError, View+ReadOnly, Bundle+MP
├── Utils/Task+Compatible13.swift
└── Resources/               # Fonts (Inter), Assets.xcassets, es-AR/CL/CO/MX/PE/UY + pt-BR .lproj
```

### Theming
- The theme contract is the `MPTheme` protocol (`colors`, `spacings`, `borderRadius`, `borderWidth`,
  `typography`, `buttons`, `textFields`). Tokens are themselves protocols (`MPColors`, `MPSpacings`,
  `MPTypography`, ...) so themes stay swappable and `Sendable`.
- Components read the theme via `@Environment(\.checkoutTheme) var theme: MPTheme`. It is injected by
  `ThemeProvider(light:dark:style:)`, which switches on `colorScheme` and
  `MercadoPagoUserInterfaceStyle` (`.automatic` / `.lightMode` / `.darkMode`). Default is `MPLightTheme`.
- **Never hardcode colors, spacing, radii, or fonts in a component.** Pull them from `theme.colors.*`,
  `theme.spacings.*`, `theme.borderRadius.*`, `theme.typography.*`. Add a new token to the relevant token
  protocol + `MPLightTheme` rather than inlining a literal.
- Colors are `SwiftUI.Color`; use `Color+Hex` for hex definitions. Typography carries `UIFont`s (bridge
  to SwiftUI with the existing `.toFont()` helper). Custom fonts (Inter) load via the resource helpers.

### Localization
- All user-facing strings go through `MPStrings` (+ per-feature extensions like `MPStrings+CardForm`).
  Add new copy to a localized `.strings` file for **every** supported locale
  (es-AR/CL/CO/MX/PE/UY, pt-BR) — do not ship a bare literal.

## MPComponents
```
Sources/MPComponents/
├── StyleProtocol.swift      # the makeBody(configuration:) style contract
├── BaseElements/            # Badge, BottomSheet, Footer, Header, Helper, Icon, ListItem, Message,
│                            #   MPRadioButton, MPTooltip, Popover, ProgressView, Skeleton, TextField
└── Natives/{Button,Text}/   # MPButtonStyle (ButtonStyle), TextStyle
```

### Required skill for component creation
The `$swiftui-custom-styles` skill is mandatory for every new component and for structural changes to
existing components. Invoke and follow it before designing or implementing the component; it is the
source of truth for the component, style, configuration, and modifier structure.

### Component style pattern (the dominant convention)

Most `BaseElements/` components come as a triad — follow it when adding one:
- `MPFoo.swift` — the SwiftUI view/element.
- `MPFooStyleConfiguration.swift` — a `Configuration` value type describing the render inputs.
- `MPFooStyle.swift` — conforms to `StyleProtocol` (`associatedtype Configuration`, `associatedtype Body: View`,
  `@ViewBuilder @MainActor func makeBody(configuration:) -> Body`). Concrete variants live in a `Styles/`
  subfolder (see `ListItem/Styles/`).
- Access level is typically `package` for cross-target-internal components and `public` only for the
  genuinely public design-system surface (`StyleProtocol`, `MPTheme` and its tokens are `public`).

### Native SwiftUI style wrappers
- For `ButtonStyle`/native styles, expose an ergonomic `View` modifier (e.g. `MPButtonStyle` +
  `func mpButtonStyle(variant:size:)`). Read appearance from the theme (`theme.buttons.loud/quiet/transparent`,
  `theme.buttons.sizes.*`) and honor `@Environment(\.isEnabled)` / `\.isLoading`.
- Any `#Preview` / demo view must be wrapped in `#if DEBUG` (see `MPButtonStyle`'s `ButtonStyleView`).

## Do / Don't
- DO support both light and dark by resolving everything through the theme; test in both schemes.
- DO keep UIKit interop (e.g. `BottomSheet/UIKit/`, presenters) beside its SwiftUI counterpart, not mixed in.
- DON'T put business logic or networking here — components are presentation-only.
- DON'T add strings, colors, or fonts as literals; route them through localization + theme tokens.

## Code Review Rules

### SwiftUI component standards

When reviewing added or modified SwiftUI components, styles, style configurations, or view modifiers,
first read these repository guides in full:

- `.agents/skills/swiftui-ui-guidelines/SKILL.md`
- `.agents/skills/swiftui-custom-styles/SKILL.md`

Apply their guidance on responsibility boundaries, view identity, state and binding ownership,
parent-managed spacing, lightweight rendering, style APIs, and reusable style structure. Flag
changes that put business logic in a style, make a style depend on external mutable state, break
view identity or user input, bypass the existing component/style/configuration pattern, or create
an unsafe-to-reuse component API.
