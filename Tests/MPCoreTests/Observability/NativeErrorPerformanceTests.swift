@testable import MPCore
import XCTest

final class NativeErrorPerformanceTests: XCTestCase {
    func testCaptureP95StaysUnderOneMillisecondDuringBoundedErrorStorm() async {
        let buffer = BoundedNativeErrorBuffer(capacity: 64)
        let reporter = NativeErrorReporter(
            buffer: buffer,
            transport: SlowNativeErrorTransport()
        )
        await reporter.configure(.init(sdkVersion: "1.0.0", siteID: "MLB"))
        let input = NativeErrorInput(type: .unknown, code: .unknownError)

        for _ in 0 ..< 128 {
            _ = await reporter.capture(operation: .paymentMethods, input: input)
        }

        var samples = [UInt64]()
        samples.reserveCapacity(20000)
        for _ in 0 ..< 20000 {
            let start = DispatchTime.now().uptimeNanoseconds
            _ = await reporter.capture(operation: .paymentMethods, input: input)
            samples.append(DispatchTime.now().uptimeNanoseconds - start)
        }

        samples.sort()
        let p95 = samples[(samples.count * 95) / 100]
        XCTAssertLessThan(p95, 1_000_000, "capture p95 was \(p95)ns")
        XCTAssertEqual(buffer.currentCount, 64, "the error storm must remain bounded")
    }
}

private struct SlowNativeErrorTransport: NativeErrorTransporting {
    func send(_: NativeErrorReport) async throws {
        try await Task.sleep(nanoseconds: 60_000_000_000)
    }
}
