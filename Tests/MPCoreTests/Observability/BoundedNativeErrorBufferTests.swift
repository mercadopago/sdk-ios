import XCTest
@testable import MPCore

final class BoundedNativeErrorBufferTests: XCTestCase {
    func testCapacityIsFIFOAndDropsNewest() {
        let buffer = BoundedNativeErrorBuffer(capacity: 2)
        let first = makePendingNativeError(id: "00000000-0000-0000-0000-000000000001")
        let second = makePendingNativeError(id: "00000000-0000-0000-0000-000000000002")
        let dropped = makePendingNativeError(id: "00000000-0000-0000-0000-000000000003")

        XCTAssertTrue(buffer.append(first))
        XCTAssertTrue(buffer.append(second))
        XCTAssertFalse(buffer.append(dropped))
        XCTAssertEqual(buffer.first()?.eventID, first.eventID)
        XCTAssertEqual(buffer.first()?.eventID, first.eventID, "head remains retained while in flight")
        buffer.removeFirst()
        XCTAssertEqual(buffer.first()?.eventID, second.eventID)
    }

    func testConcurrentProducersNeverExceedCapacity() {
        let buffer = BoundedNativeErrorBuffer(capacity: 64)
        DispatchQueue.concurrentPerform(iterations: 512) { index in
            _ = buffer.append(makePendingNativeError(
                id: String(format: "00000000-0000-0000-0000-%012d", index)
            ))
        }
        XCTAssertEqual(buffer.currentCount, 64)
    }

}

private func makePendingNativeError(id: String) -> PendingNativeError {
    PendingNativeError(
        eventID: UUID(uuidString: id)!,
        occurredAt: .distantPast,
        environment: .init(sdkVersion: "1.0.0", siteID: "MLB", osVersion: nil),
        error: .init(operation: .installments, code: .operationFailed)
    )
}
