import XCTest
@testable import MPCore

final class NativeErrorReporterTests: XCTestCase {
    func testDualWriteUsesOneDeterministicIDAndDelivers() async throws {
        let transport = RecordingNativeErrorTransport()
        let reporter = NativeErrorReporter(
            deliveryMode: .dualWrite,
            transport: transport,
            eventIDProvider: { UUID(uuidString: "3f6fd694-4ba8-4f45-ae7c-871c4698aace")! },
            dateProvider: { Date(timeIntervalSince1970: 1_777_000_000) }
        )
        reporter.configure(sdkVersion: "1.0.0", country: .BRA)

        let receipt = reporter.capture(.init(operation: .installments, code: .requestTimeout))
        XCTAssertEqual(receipt.eventID, "3f6fd694-4ba8-4f45-ae7c-871c4698aace")
        XCTAssertTrue(receipt.shouldSendMelidata)

        let report = await transport.nextReport()
        XCTAssertEqual(report.eventID, receipt.eventID)
        XCTAssertEqual(report.source.sdkVersion, "1.0.0")
    }

    func testDeliveryModesAndMissingConfigurationAreContained() async throws {
        let melidataTransport = RecordingNativeErrorTransport()
        let melidataOnly = NativeErrorReporter(deliveryMode: .melidataOnly, transport: melidataTransport)
        XCTAssertTrue(melidataOnly.capture(.init(operation: .issuers, code: .operationFailed)).shouldSendMelidata)
        let melidataCount = await melidataTransport.count
        XCTAssertEqual(melidataCount, 0)

        let observabilityTransport = RecordingNativeErrorTransport()
        let observabilityOnly = NativeErrorReporter(deliveryMode: .observabilityOnly, transport: observabilityTransport)
        XCTAssertFalse(observabilityOnly.capture(.init(operation: .issuers, code: .operationFailed)).shouldSendMelidata)
        let observabilityCount = await observabilityTransport.count
        XCTAssertEqual(observabilityCount, 0)
    }

    func testReconfigurationDoesNotMutateQueuedSnapshot() async throws {
        let transport = RecordingNativeErrorTransport(suspended: true)
        let reporter = NativeErrorReporter(transport: transport)
        reporter.configure(sdkVersion: "1.0.0", country: .BRA)
        _ = reporter.capture(.init(operation: .installments, code: .operationFailed))
        reporter.configure(sdkVersion: "2.0.0", country: .COL)
        await transport.resume()

        let first = await transport.nextReport()
        XCTAssertEqual(first.source.sdkVersion, "1.0.0")
        XCTAssertEqual(first.siteID, "MLB")
    }

    func testTransportFailuresAreContainedAndWorkerContinues() async {
        let transport = FailingNativeErrorTransport()
        let reporter = NativeErrorReporter(transport: transport)
        reporter.configure(sdkVersion: "1.0.0", country: .BRA)

        let offlineReceipt = reporter.capture(.init(operation: .paymentMethods, code: .connectionUnavailable))
        await transport.waitForAttempt(1)
        let timeoutReceipt = reporter.capture(.init(operation: .issuers, code: .requestTimeout))
        await transport.waitForAttempt(2)

        XCTAssertTrue(offlineReceipt.shouldSendMelidata)
        XCTAssertTrue(timeoutReceipt.shouldSendMelidata)
        XCTAssertNotEqual(offlineReceipt.eventID, timeoutReceipt.eventID)
        let attempts = await transport.attemptCount
        XCTAssertEqual(attempts, 2)
    }
}

private actor RecordingNativeErrorTransport: NativeErrorTransporting {
    private var reports: [NativeErrorReport] = []
    private var waiters: [CheckedContinuation<NativeErrorReport, Never>] = []
    private var suspended: Bool
    private var suspensionWaiters: [CheckedContinuation<Void, Never>] = []

    init(suspended: Bool = false) { self.suspended = suspended }

    var count: Int { reports.count }

    func send(_ report: NativeErrorReport) async throws -> Bool {
        if suspended {
            await withCheckedContinuation { suspensionWaiters.append($0) }
        }
        if waiters.isEmpty {
            reports.append(report)
        } else {
            waiters.removeFirst().resume(returning: report)
        }
        return true
    }

    func nextReport() async -> NativeErrorReport {
        if !reports.isEmpty { return reports.removeFirst() }
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

    func send(_ report: NativeErrorReport) async throws -> Bool {
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
