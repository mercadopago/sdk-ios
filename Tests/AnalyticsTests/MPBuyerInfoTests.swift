//
//  MPBuyerInfoTests.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 07/01/25.
//

@testable import MPAnalytics
import XCTest

// MARK: - Test Doubles

private class NetworkMonitoringMock: @unchecked Sendable, NetworkMonitoring {
    var networkTypeToReturn = "wifi"

    func getCurrentNetworkType() -> String {
        return self.networkTypeToReturn
    }
}

private extension MPBuyerInfoTests {
    typealias SUT = (
        sut: MPBuyerInfo,
        networkMonitor: NetworkMonitoringMock
    )

    func makeSUT(
        networkType: String = "wifi",
        file _: StaticString = #filePath,
        line _: UInt = #line
    ) -> SUT {
        let networkMonitor = NetworkMonitoringMock()
        networkMonitor.networkTypeToReturn = networkType
        let sut = MPBuyerInfo(networkMonitor: networkMonitor)

        return (sut, networkMonitor)
    }
}

final class MPBuyerInfoTests: XCTestCase {
    func test_getDeviceInfo_shouldReturnDeviceModel() {
        let (sut, _) = self.makeSUT()

        let deviceInfo = sut.getDeviceInfo()

        XCTAssertFalse(deviceInfo.isEmpty)
        XCTAssertNotEqual(deviceInfo, "unknown")
    }

    func test_getiOSVersion_shouldReturnCurrentSystemVersion() async {
        let (sut, _) = self.makeSUT()

        let version = await sut.getiOSVersion()

        XCTAssertFalse(version.isEmpty)
        XCTAssertTrue(version.contains("."))
    }

    func test_getUID_shouldReturnVendorIdentifier() async {
        let (sut, _) = self.makeSUT()

        let uid = await sut.getUID()

        XCTAssertFalse(uid.isEmpty)
        XCTAssertEqual(uid.count, 36)
    }

    func test_getNetworkType_whenWiFi_shouldReturnWifi() {
        let (sut, _) = self.makeSUT(networkType: "wifi")

        let networkType = sut.getNetworkType()

        XCTAssertEqual(networkType, "wifi")
    }

    func test_getNetworkType_when4G_shouldReturn4g() {
        let (sut, _) = self.makeSUT(networkType: "4g")

        let networkType = sut.getNetworkType()

        XCTAssertEqual(networkType, "4g")
    }

    func test_getNetworkType_when5G_shouldReturn5g() {
        let (sut, _) = self.makeSUT(networkType: "5g")

        let networkType = sut.getNetworkType()

        XCTAssertEqual(networkType, "5g")
    }
}
