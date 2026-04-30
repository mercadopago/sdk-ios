# Coding Guidelines

## Language
Use English in all source code, comments, doc comments, commit messages, PR descriptions, and review comments.

---

## Code Style

Enforced via **SwiftLint** and **SwiftFormat** with pre-commit hooks.

Setup:
```bash
brew install swiftlint swiftformat pre-commit
pre-commit install
```

Manual execution:
```bash
swiftformat .      # auto-format
swiftlint lint     # static analysis
```

Config: `.swiftlint.yml` and `.swiftformat.yml` at the repo root.

---

## Swift Guidelines

- Prefer `let` over `var`; prefer value types (`struct`, `enum`) over reference types when appropriate
- Avoid force-unwrap (`!`); use `guard let`, `if let`, optional chaining (`?.`), or `?? default`
- Use `async`/`await` with structured concurrency; avoid `DispatchQueue.global()` in new code; inject concurrency context via `@MainActor` or actor isolation
- Use `enum` with associated values or `Result<Success, Failure>` for error and state modeling
- No `// swiftlint:disable` without an explanatory comment

---

## Architecture Guidelines

Module boundaries:

```
MercadoPagoSDK         ← SDK entry point, top-level initialization
MPCore                 ← networking, base infrastructure, DeviceFingerPrint
CoreMethods            ← API layer (identification, installments, tokenization)
MercadoPagoCheckout    ← card payment UI (SwiftUI), ViewModel, checkout flow
MPComponents           ← reusable SwiftUI components
MPFoundation           ← design system, theme, base UI
MPAnalytics            ← event tracking
MPApplePay             ← Apple Pay integration
MPExtended             ← extended APIs (deviceSession)
```

Dependency direction is strict. No circular dependencies.

- **State**: `@Published` on `ObservableObject` ViewModels or `@State`/`@Binding` in views; never expose mutable state directly to callers
- **No logic inside SwiftUI `body`** — extract to ViewModel, UseCase, or a plain function
- **File size**: 300 lines max — extract types or extensions before reaching the limit

---

## Security Guidelines

- Never persist PCI data to disk (`@State` / in-memory only, not `@AppStorage`, `UserDefaults`, or files)
- Never log PCI data (`print`, `os_log`, crash reporters, analytics SDKs)
- Never hardcode credentials — pass via `MercadoPagoSDK.Configuration`
- Always validate inputs at module boundaries

See [SECURITY.md](SECURITY.md) for the full security policy.

---

## Comment Guidelines

- Comment departures from convention, non-obvious decisions, and safety-critical invariants
- Do not explain obvious code or leave commented-out blocks in production code
- All public API requires doc comments (`///`)

---

## Testing Guidelines

- Unit tests mandatory for all production code with relevant logic
- SwiftUI view files (`*Screen.swift`, `*Brick.swift`) are excluded from the coverage gate — logic belongs in ViewModels and UseCases
- Minimum **80%** line coverage enforced by `xcov` via Fastlane
- XCTest + Fakes/Stubs; prefer fakes over mocks to avoid tight coupling
- `tearDown()` must clean up any shared or singleton state
- Use snapshot tests (`swift-snapshot-testing`) for UI component regression

---

## Branching Guidelines

Branch from `main`:

| Pattern | Use case |
|---------|----------|
| `feature/TICKET-description` | New feature |
| `fix/TICKET-description` | Bug fix |
| `hotfix/description` | Critical patch |
| `docs/description` | Docs only |
| `refactor/description` | Refactor only |

---

## Git Guidelines

Follow the [seven rules](https://chris.beams.io/posts/git-commit): imperative mood, 72-char subject, blank line before body, explain what and why.

```bash
# Good
git commit -m "Fix card number validation rejecting valid BIN prefix"

# Also good (with body)
git commit -m "Add Apple Pay fallback for unsupported devices

Devices without Secure Element cannot use Apple Pay. This change
adds a graceful fallback to the standard card form instead of
crashing at runtime."
```

Unacceptable: `fix tests`, `now it works`, `wip`, `asdfgh`

---

## Pull Request Guidelines

- Every PR must reference a ticket or issue
- Fill in the PR template completely
- PRs failing CI will not be reviewed
- One concern per PR
- Screenshots or screen recordings required for UI changes
- Run full checklist before marking ready:

```bash
swiftformat .
swiftlint lint
swift test
bundle exec fastlane test   # tests + coverage report
```
