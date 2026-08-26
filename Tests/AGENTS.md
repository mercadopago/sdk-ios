# Testing conventions (XCTest + swift-snapshot-testing)

Tests use XCTest. Unit/logic tests run via `bundle exec fastlane test`; snapshot tests are a separate
target/lane. Do **not** run `make test` — its lane name is a typo (see the root `AGENTS.md`).

## Layout
```
Tests/
├── Common/Mocks/           # shared mocks: MockDependencyContainer, MockURLSession, MockAnalytics, MockFingerPrint
│                           #   (target CommonTests, path Tests/Common — depends on MPCore)
├── AnalyticsTests/         # MPAnalytics target tests
├── CoreMethodsTests/       # + Data/, Domain/UseCases/, UI/, Model/, Stubs/, Mocks
├── MPCoreTests/, MPApplePayTests/, MPExtendedTests/
├── MercadoPagoCheckoutTests/  # excluded from the coverage gate (see the root AGENTS.md)
└── SnapshotTests/          # swift-snapshot-testing; excluded from `test` lane + coverage gate
Example/ExampleTests, Example/ExampleUITests   # host-app unit + UI tests
```

## Which lane runs what (`fastlane/Fastfile`)
- `test` → `only_testing`: CoreMethodsTests, AnalyticsTests, MPCoreTests, MPApplePayTests,
  MercadoPagoCheckoutTests, MPExtendedTests; `skip_testing`: SnapshotTests. Then `xcov` (80% gate,
  excludes SnapshotTests + MercadoPagoCheckoutTests).
- `snapshot_tests` → runs `SnapshotTests` only. `record_snapshots` → same, with `SNAPSHOT_RECORD_MODE=YES`.

## The SUT / makeSUT pattern (follow it)
Every test class wires its system-under-test through a private `makeSUT(...)` helper that returns a
tuple of the SUT plus the mocks the test drives. Example (from `GenerateCardTokenUseCaseTests`):

```swift
private extension GenerateCardTokenUseCaseTests {
    typealias SUT = (sut: GenerateCardTokenUseCase, session: MockURLSession, paymentMethodUseCase: PaymentMethodUseCaseMock)

    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> SUT {
        let container = MockDependencyContainer()       // wires mock network/analytics/fingerprint
        let repository = CoreMethodsRepository(dependencies: container)
        let paymentMethodUseCase = PaymentMethodUseCaseMock(result: [paymentMethodStub()])
        let sut = GenerateCardTokenUseCase(dependencies: container, repository: repository, paymentMethodUseCase: paymentMethodUseCase)
        return (sut, container.mockSession, paymentMethodUseCase)
    }
}
```

- Use `@testable import <Target>` and `import CommonTests` (for the shared mocks).
- Name tests `test_<method>_When<condition>_Should<expectation>` (the codebase style).
- Async tests are `func test_...() async` and use `try await`; assert with `XCTAssertEqual` /
  `XCTFail("Should not throw error")` in the `catch`.

## Shared mocks (`Tests/Common/Mocks`) — reuse, don't reinvent
- `MockDependencyContainer` conforms to `HasNetwork & HasAnalytics & HasFingerPrint & HasNoDependency`
  and exposes `mockSession` + `mockAnalytics`. Default-construct it and drive its mocks.
- `MockURLSession` (a `URLSessionProtocol`) has an inner `actor Mock`; stage responses with
  `await session.mock.setResponse(...)` / `.setData(...)` / `.setError(...)`.
- Feature targets add their own repo/use-case mocks + `Stubs/` (e.g. `CardTokenStub.validResponse`,
  `CardTokenStub.expectedToken`) and `*+PaymentMethodStub` extensions. Put fixtures in `Stubs/`.

## Snapshot tests
- Live in `Tests/SnapshotTests/<Module>/`. Add a new reference by running
  `bundle exec fastlane record_snapshots`, review the generated image, then run `bundle exec fastlane snapshot_tests`
  to verify. Never commit a failing/placeholder snapshot.
- Remember snapshot targets are outside the coverage gate — don't rely on them for coverage %.

## Coverage
- The gate is 80% (`xcov`). New SwiftUI `*Screen.swift`/`*Brick.swift` files are auto-ignored via
  `.xcovignore`; keep unit-testable logic in `*ScreenViewModel.swift` siblings so it counts.

## Do / Don't
- DO keep mocks/stubs in `Common/Mocks` (shared) or the feature's `Mocks/`+`Stubs/` folders.
- DO stage network results through `MockURLSession` rather than hitting the network.
- DON'T put real card numbers, keys, or PII in fixtures — use obviously-fake test values.
