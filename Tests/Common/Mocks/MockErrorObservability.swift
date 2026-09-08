import Foundation
@testable import MPCore

package final class MockErrorObservability: ErrorObservabilityReporting, @unchecked Sendable {
    private let lock = NSLock()
    private var configurations: [(String, MercadoPagoSDK.Country)] = []
    private var captured: [ClassifiedNativeError] = []
    private var inputs: [(NativeErrorOperation, NativeErrorInput)] = []
    private let shouldSendMelidata: Bool
    private let eventIDForOperation: @Sendable (NativeErrorOperation) -> String

    package init(
        eventID: String = "3f6fd694-4ba8-4f45-ae7c-871c4698aace",
        shouldSendMelidata: Bool = true
    ) {
        self.shouldSendMelidata = shouldSendMelidata
        self.eventIDForOperation = { _ in eventID }
    }

    package init(
        shouldSendMelidata: Bool = true,
        eventIDForOperation: @escaping @Sendable (NativeErrorOperation) -> String
    ) {
        self.shouldSendMelidata = shouldSendMelidata
        self.eventIDForOperation = eventIDForOperation
    }

    package func configure(sdkVersion: String, country: MercadoPagoSDK.Country) {
        lock.withMockErrorLock { configurations.append((sdkVersion, country)) }
    }

    package func capture(
        operation: NativeErrorOperation,
        input: NativeErrorInput
    ) -> NativeErrorReceipt {
        let classifiedError = NativeErrorClassifier.classify(operation: operation, input: input)
        lock.withMockErrorLock {
            inputs.append((operation, input))
            captured.append(classifiedError)
        }
        return NativeErrorReceipt(
            eventID: eventIDForOperation(classifiedError.operation),
            shouldSendMelidata: shouldSendMelidata
        )
    }

    package func recordedConfigurations() -> [(String, MercadoPagoSDK.Country)] {
        lock.withMockErrorLock { configurations }
    }

    package func recordedErrors() -> [ClassifiedNativeError] {
        lock.withMockErrorLock { captured }
    }

    package func recordedInputs() -> [(NativeErrorOperation, NativeErrorInput)] {
        lock.withMockErrorLock { inputs }
    }
}

private extension NSLock {
    func withMockErrorLock<T>(_ body: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try body()
    }
}
