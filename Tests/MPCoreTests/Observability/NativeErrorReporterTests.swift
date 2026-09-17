@testable import MPCore
import XCTest

final class NativeErrorReporterTests: XCTestCase {
    func testDualWriteUsesOneDeterministicIDAndDelivers() async {
        let transport = RecordingNativeErrorTransport()
        let reporter = NativeErrorReporter(
            transport: transport,
            eventIDProvider: { UUID(uuidString: "3f6fd694-4ba8-4f45-ae7c-871c4698aace")! },
            dateProvider: { Date(timeIntervalSince1970: 1_777_000_000) }
        )
        await reporter.configure(.init(sdkVersion: "1.0.0", siteID: "MLB"))

        let receipt = await reporter.capture(operation: .installments, input: .init(type: .request, code: .timeout))
        XCTAssertEqual(receipt.eventID, "3f6fd694-4ba8-4f45-ae7c-871c4698aace")
        XCTAssertTrue(receipt.shouldSendMelidata)

        let report = await transport.nextReport()
        XCTAssertEqual(report.eventID, receipt.eventID)
        XCTAssertEqual(report.source.sdkVersion, "1.0.0")
    }

    func testDeliveryModesAndMissingConfigurationAreContained() async {
        let melidataTransport = RecordingNativeErrorTransport()
        let melidataOnly = NativeErrorReporter(
            deliveryPolicy: .init(coreMethods: .melidataOnly),
            transport: melidataTransport
        )
        let melidataReceipt = await melidataOnly.capture(operation: .issuers, input: .init(type: .unknown))
        XCTAssertTrue(melidataReceipt.shouldSendMelidata)
        let melidataCount = await melidataTransport.count
        XCTAssertEqual(melidataCount, 0)

        let observabilityTransport = RecordingNativeErrorTransport()
        let observabilityOnly = NativeErrorReporter(
            deliveryPolicy: .init(coreMethods: .observabilityOnly),
            transport: observabilityTransport
        )
        let observabilityReceipt = await observabilityOnly.capture(operation: .issuers, input: .init(type: .unknown))
        XCTAssertFalse(observabilityReceipt.shouldSendMelidata)
        let observabilityCount = await observabilityTransport.count
        XCTAssertEqual(observabilityCount, 0)

        await observabilityOnly.configure(.init(sdkVersion: "1.0.0", siteID: "MLB"))
        let retainedReport = await observabilityTransport.nextReport()
        XCTAssertEqual(retainedReport.eventID, observabilityReceipt.eventID)
        XCTAssertEqual(retainedReport.siteID, "MLB")
    }

    func testAllModuleDeliveryModePairsRemainIndependent() async {
        let modes = NativeErrorDeliveryMode.allCases
        XCTAssertEqual(modes.count * modes.count, 9)
        for coreMethodsMode in modes {
            for checkoutMode in modes {
                let buffer = BoundedNativeErrorBuffer(capacity: 2)
                let reporter = NativeErrorReporter(
                    deliveryPolicy: .init(coreMethods: coreMethodsMode, checkout: checkoutMode),
                    buffer: buffer,
                    transport: BlockingNativeErrorTransport()
                )
                await reporter.configure(.init(sdkVersion: "1.0.0", siteID: "MLB"))

                let coreMethodsReceipt = await reporter.capture(
                    operation: .cardTokenization,
                    input: .init(type: .unknown)
                )
                let checkoutReceipt = await reporter.capture(
                    operation: .orderSubmission,
                    input: .init(type: .unknown)
                )

                let pair = "\(coreMethodsMode.rawValue)/\(checkoutMode.rawValue)"
                XCTAssertEqual(coreMethodsReceipt.shouldSendMelidata, coreMethodsMode.sendsMelidata, pair)
                XCTAssertEqual(checkoutReceipt.shouldSendMelidata, checkoutMode.sendsMelidata, pair)
                XCTAssertEqual(
                    buffer.currentCount,
                    [coreMethodsMode, checkoutMode].filter(\.sendsObservability).count,
                    pair
                )
            }
        }
    }

    func testReconfigurationDoesNotMutateQueuedSnapshot() async {
        let transport = RecordingNativeErrorTransport(suspended: true)
        let reporter = NativeErrorReporter(transport: transport)
        await reporter.configure(.init(sdkVersion: "1.0.0", siteID: "MLB"))
        _ = await reporter.capture(operation: .installments, input: .init(type: .unknown))
        await reporter.configure(.init(sdkVersion: "2.0.0", siteID: "MCO"))
        await transport.resume()

        let first = await transport.nextReport()
        XCTAssertEqual(first.source.sdkVersion, "1.0.0")
        XCTAssertEqual(first.siteID, "MLB")
    }

    func testTransportFailuresAreContainedAndWorkerContinues() async {
        let transport = FailingNativeErrorTransport()
        let reporter = NativeErrorReporter(transport: transport)
        await reporter.configure(.init(sdkVersion: "1.0.0", siteID: "MLB"))

        let offlineReceipt = await reporter.capture(
            operation: .paymentMethods,
            input: .init(type: .request, code: .offline)
        )
        await transport.waitForAttempt(1)
        let timeoutReceipt = await reporter.capture(
            operation: .issuers,
            input: .init(type: .request, code: .timeout)
        )
        await transport.waitForAttempt(2)

        XCTAssertTrue(offlineReceipt.shouldSendMelidata)
        XCTAssertTrue(timeoutReceipt.shouldSendMelidata)
        XCTAssertNotEqual(offlineReceipt.eventID, timeoutReceipt.eventID)
        let attempts = await transport.attemptCount
        XCTAssertEqual(attempts, 2)
    }
}

private struct BlockingNativeErrorTransport: NativeErrorTransporting {
    func send(_: NativeErrorReport) async throws {
        try await Task.sleep(nanoseconds: 60_000_000_000)
    }
}

private actor RecordingNativeErrorTransport: NativeErrorTransporting {
    private var reports: [NativeErrorReport] = []
    private var waiters: [CheckedContinuation<NativeErrorReport, Never>] = []
    private var suspended: Bool
    private var suspensionWaiters: [CheckedContinuation<Void, Never>] = []

    init(suspended: Bool = false) {
        self.suspended = suspended
    }

    var count: Int {
        reports.count
    }

    func send(_ report: NativeErrorReport) async throws {
        if suspended {
            await withCheckedContinuation { suspensionWaiters.append($0) }
        }
        if waiters.isEmpty {
            reports.append(report)
        } else {
            waiters.removeFirst().resume(returning: report)
        }
    }

    func nextReport() async -> NativeErrorReport {
        if !reports.isEmpty {
            return reports.removeFirst()
        }
        return await withCheckedContinuation { waiters.append($0) }
    }

    func resume() {
        suspended = false
        let continuations = suspensionWaiters
        suspensionWaiters.removeAll()
        continuations.forEach { $0.resume() }
    }
}

private actor FailingNativeErrorTransport: NativeErrorTransporting {
    private(set) var attemptCount = 0
    private var waiters: [(count: Int, continuation: CheckedContinuation<Void, Never>)] = []

    func send(_: NativeErrorReport) async throws {
        attemptCount += 1
        let ready = waiters.filter { $0.count <= attemptCount }
        waiters.removeAll { $0.count <= attemptCount }
        ready.forEach { $0.continuation.resume() }
        throw URLError(attemptCount == 1 ? .notConnectedToInternet : .timedOut)
    }

    func waitForAttempt(_ count: Int) async {
        guard attemptCount < count else { return }
        await withCheckedContinuation { waiters.append((count, $0)) }
    }
}
