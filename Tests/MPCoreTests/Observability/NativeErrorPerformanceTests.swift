import XCTest
@testable import MPCore

final class NativeErrorPerformanceTests: XCTestCase {
    func testCaptureP95StaysUnderOneMillisecondDuringBoundedErrorStorm() {
        let buffer = BoundedNativeErrorBuffer(capacity: 64)
        let reporter = NativeErrorReporter(
            buffer: buffer,
            transport: SlowNativeErrorTransport()
        )
        reporter.configure(sdkVersion: "1.0.0", country: .BRA)
        let input = NativeErrorInput(type: .unknown, code: .unknownError)

        for _ in 0 ..< 128 {
            _ = reporter.capture(operation: .paymentMethods, input: input)
        }

        var samples = [UInt64]()
        samples.reserveCapacity(20_000)
        for _ in 0 ..< 20_000 {
            let start = DispatchTime.now().uptimeNanoseconds
            _ = reporter.capture(operation: .paymentMethods, input: input)
            samples.append(DispatchTime.now().uptimeNanoseconds - start)
        }

        samples.sort()
        let p95 = samples[(samples.count * 95) / 100]
        XCTAssertLessThan(p95, 1_000_000, "capture p95 was \(p95)ns")
        XCTAssertEqual(buffer.currentCount, 64, "the error storm must remain bounded")
    }
}

private struct SlowNativeErrorTransport: NativeErrorTransporting {
    func send(_ report: NativeErrorReport) async throws -> Bool {
        try await Task.sleep(nanoseconds: 60_000_000_000)
        return true
    }
}
