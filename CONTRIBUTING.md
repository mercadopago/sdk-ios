# Contributing to Mercado Pago SDK iOS

Thank you for contributing to **Mercado Pago SDK iOS**. This guide explains how to report issues, propose changes, and open Pull Requests (PRs) with quality and safety.

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md).

---

## How can I contribute?

### 1) Report bugs

Before opening an issue:
- Check whether a similar issue already exists (open or closed).
- Provide as much context as possible:
  - SDK version
  - iOS version / device model
  - Steps to reproduce
  - Expected result vs. actual result
  - Relevant logs (Xcode console, `os_log`) and/or screenshots

### 2) Suggest enhancements

Suggestions are welcome. Please explain:
- What problem you are solving
- Your proposed solution
- Expected impact (API, compatibility, performance)

### 3) Submit code (Pull Request)

Changes via PR are the best way to contribute. Before writing code, read the [Coding Guidelines](CODING_GUIDELINES.md) — they cover language, style, architecture, security, testing, and commit conventions for this project.

---

## Requirements before you start

### Environment

- Xcode 16.0+ (latest stable recommended)
- Swift 5.5+
- iOS 13.0+ deployment target
- Homebrew — required to install development tools

### Running the project locally

1. Fork the repository
2. Clone your fork and add upstream:
   ```bash
   git clone https://github.com/<your-user>/sdk-ios.git
   cd sdk-ios
   git remote add upstream https://github.com/mercadopago/sdk-ios.git
   ```
3. Run the full setup (installs SwiftLint, SwiftFormat, git hooks, and Fastlane):
   ```bash
   make setup
   ```
4. Open `Package.swift` in Xcode to build and run the project
5. Create a branch for your change (see naming convention below)

### Available `make` commands

| Command | Description |
|---------|-------------|
| `make setup` | Full initial setup — runs the three commands below in sequence |
| `make install-tools` | Installs SwiftLint and SwiftFormat via Homebrew *(called by `make setup`)* |
| `make setup-git-hooks` | Configures the git pre-commit hook for auto-formatting *(called by `make setup`)* |
| `make install-fastlane` | Installs Fastlane and its dependencies via Bundler *(called by `make setup`)* |
| `make format` | Auto-formats Swift code with SwiftFormat |
| `make test` | Runs unit tests and generates coverage report via Fastlane |
| `make clean` | Removes installed tools and generated test/coverage output |

### Branch naming convention

Create branches from `main`. Suggested names:

- `feature/<ticket>/short-description`
- `fix/<ticket>/short-description`
- `hotfix/short-description`
- `docs/<ticket>/short-description`
- `refactor/<ticket>/short-description`

Example:
```bash
git checkout -b fix/3795/card-number-error
```

### Commit message convention

Follow the [seven rules of a great Git commit message](https://chris.beams.io/posts/git-commit). Use the imperative mood, capitalize the subject, limit to 72 characters, and explain **what and why** in the body.

```bash
git commit -m "Fix card number validation rejecting valid BIN prefix"
```

Commits like `fix tests`, `now it works`, or `wip` will not be accepted. See [Coding Guidelines — Git](CODING_GUIDELINES.md#git-guidelines) for full details and examples.

---

## Example app

The `Example/` directory contains an Xcode project that demonstrates the SDK integrations — CardForm (SwiftUI and UIKit), Device Session, and Installments. It links to the local SDK via Swift Package Manager, so changes you make to the SDK are immediately reflected.

### Setup

Open `Example/Example.xcodeproj` directly in Xcode. The SDK is linked locally via Swift Package Manager — no extra steps required.

### When to use it

- **UI changes** — run the affected flow end-to-end and record a screen capture to attach to your PR.
- **New public API** — add a usage example in the relevant screen to confirm the integration works as expected.
- **Bug fixes** — reproduce the bug in the app before fixing, and verify it is gone after.

> The Example app is excluded from the coverage gate and from SwiftLint — it exists solely for manual validation.

---

## Quality and compatibility

### General guidelines

- Avoid breaking changes without prior discussion.
- Keep binary and source compatibility whenever possible (library/SDK).
- Update documentation when the change affects public usage (README, doc comments, sample app).
- All public API must include doc comments (`///`).

### Style and lint

This project uses **SwiftLint** and **SwiftFormat**, configured via `.swiftlint.yml` and `.swiftformat.yml`. After running `make setup`, a git hook runs formatting automatically before each commit. You can also run manually:

```bash
make format        # auto-format with SwiftFormat
swiftlint lint     # static analysis with SwiftLint
```

See [Coding Guidelines — Code Style](CODING_GUIDELINES.md#code-style) for configuration details.

### Tests

- Add tests for any change that includes relevant logic.
- Ensure existing tests keep passing.
- Minimum line coverage: **80%** (enforced by `xcov` via Fastlane).
- SwiftUI view files (`*Screen.swift`, `*Brick.swift`) are excluded from coverage — test logic in ViewModels and UseCases instead.

See [Coding Guidelines — Testing](CODING_GUIDELINES.md#testing-guidelines) for tooling and patterns.

### Local checks (required before opening a PR)

```bash
make format        # format code
swiftlint lint     # check for lint errors
make test          # run tests + coverage report
```

---

## Pull Request checklist

Your PR should:
- [ ] Be small and focused (one concern per PR)
- [ ] Include a clear description and reference to the related ticket/issue
- [ ] Pass all CI checks (SwiftLint, SwiftFormat, tests, coverage)
- [ ] Include screenshots or screen recordings for any UI change
- [ ] Not introduce new public API without doc comments (`///`)

---

## Review process

- Keep the PR up to date with `main` (rebase preferred over merge commits).
- Reply to comments with context and apply incremental updates when needed.
- PRs that fail CI will not be reviewed until green.

---

## Security

This SDK handles PCI-sensitive payment data. Contributors must follow the security rules defined in [Coding Guidelines — Security](CODING_GUIDELINES.md#security-guidelines):

- Never persist card data (PAN, CVV, expiry) to disk or logs.
- Never hardcode credentials, tokens, or API keys in source code.
- Never include sensitive data in screenshots or PR descriptions.

If you discover a vulnerability, **do not open a public issue**. Report it privately following the process in [SECURITY.md](SECURITY.md).

---

## License

By contributing, you agree that your contribution will be licensed under the [Apache License 2.0](LICENSE.md).
