@testable import MPCore
import XCTest

final class FingerPrintTests: XCTestCase {
    @MainActor
    func testGetDeviceDataReturnsNilOnSimulator() async {
        #if targetEnvironment(simulator)
            let sut = FingerPrint()

            let deviceData = await sut.getDeviceData()

            XCTAssertNil(deviceData)
        #endif
    }
}
