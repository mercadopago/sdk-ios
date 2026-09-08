import Foundation
@testable import MPCore

package final class MockErrorObservability: ErrorObservabilityReporting, @unchecked Sendable {
    private let lock = NSLock()
    private var configurations: [(String, MercadoPagoSDK.Country)] = []
    private var captured: [ClassifiedNativeError] = []
    private let receipt: NativeErrorReceipt

    package init(
        eventID: String = "3f6fd694-4ba8-4f45-ae7c-871c4698aace",
        shouldSendMelidata: Bool = true
    ) {
        receipt = NativeErrorReceipt(eventID: eventID, shouldSendMelidata: shouldSendMelidata)
    }

    package func configure(sdkVersion: String, country: MercadoPagoSDK.Country) {
        lock.withMockErrorLock { configurations.append((sdkVersion, country)) }
    }

    package func capture(_ classifiedError: ClassifiedNativeError) -> NativeErrorReceipt {
        lock.withMockErrorLock { captured.append(classifiedError) }
        return receipt
    }

    package func recordedConfigurations() -> [(String, MercadoPagoSDK.Country)] {
        lock.withMockErrorLock { configurations }
    }

    package func recordedErrors() -> [ClassifiedNativeError] {
        lock.withMockErrorLock { captured }
    }
}

private extension NSLock {
    func withMockErrorLock<T>(_ body: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try body()
    }
}
