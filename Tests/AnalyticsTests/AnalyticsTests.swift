//
//  AnalyticsTests.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 06/01/25.
//

@testable import MPAnalytics
import XCTest

// MARK: - Test Doubles

private struct MockEventData: AnalyticsEventData {
    let value: String
    let iosMinimium: String
    let deviceInfo: String

    func toDictionary() -> [String: Any] {
        return ["test_value": self.value, "deviceInfo": self.deviceInfo, "iosMinimium": self.iosMinimium]
    }
}

// MARK: - Setup SUT

private extension AnalyticsTests {
    typealias SUT = MPAnalytics

    func makeSUT(file _: StaticString = #filePath, line _: UInt = #line) -> SUT {
        return MPAnalytics()
    }
}

final class AnalyticsTests: XCTestCase {
    // MARK: - Event Tracking Tests

    func test_trackEvent_ShouldSetCorrectPathAndType() async {
        let sut = self.makeSUT()
        let eventPath = "payment/credit_card"

        await sut.trackEvent(eventPath)

        let path = await sut.path
        let type = await sut.type
        XCTAssertEqual(path, eventPath)
        XCTAssertEqual(type, .event)
    }

    func test_trackView_ShouldSetCorrectPathAndType() async {
        let sut = self.makeSUT()
        let viewPath = "checkout/review"

        await sut.trackView(viewPath)

        let path = await sut.path
        let type = await sut.type
        XCTAssertEqual(path, viewPath)
        XCTAssertEqual(type, .view)
    }

    // MARK: - Event Data Tests

    func test_setEventData_ShouldStoreEventData() async {
        let sut = self.makeSUT()
        let mockData = await MockEventData(
            value: "test-123",
            iosMinimium: sut.sellerInfo.getTargetMinimum(),
            deviceInfo: sut.buyerInfo.getDeviceInfo()
        )

        await sut.setEventData(mockData)

        guard let storedData = await sut.eventData as? MockEventData else {
            return XCTFail("Event Data is not stored")
        }
        XCTAssertEqual(storedData.value, "test-123")
        XCTAssertEqual(storedData.iosMinimium, "iOS 13.0")
        XCTAssertEqual(storedData.deviceInfo, "arm64")
    }

    // MARK: - Configuration Tests

    func test_setSiteID_ShouldUpdateSiteID() async {
        let sut = self.makeSUT()
        let siteID = "MLB"

        await sut.setSiteID(siteID)

        let resultSiteId = await sut.siteId
        XCTAssertEqual(resultSiteId, siteID)
    }

    func test_setVersion_ShouldUpdateVersion() async {
        let sut = self.makeSUT()
        let version = "1.0.0"

        await sut.setVersion(version)

        let resultVersion = await sut.version
        XCTAssertEqual(resultVersion, version)
    }

    // MARK: - Method Chaining Tests

    func test_methodChaining_ShouldReturnSelfAndUpdateValues() async {
        let sut = self.makeSUT()
        let eventPath = "payment/credit_card"
        let mockData = await MockEventData(
            value: "test-123",
            iosMinimium: sut.sellerInfo.getTargetMinimum(),
            deviceInfo: sut.buyerInfo.getDeviceInfo()
        )
        let siteID = "MLB"
        let version = "1.0.0"

        await sut
            .trackEvent(eventPath)
            .setEventData(mockData)
            .setSiteID(siteID)
            .setVersion(version)

        let resultPath = await sut.path
        let resultType = await sut.type
        let resultEventData = await sut.eventData as? MockEventData
        let resultSiteId = await sut.siteId
        let resultVersion = await sut.version

        XCTAssertEqual(resultPath, eventPath)
        XCTAssertEqual(resultType, .event)
        XCTAssertEqual(resultEventData?.value, "test-123")
        XCTAssertEqual(resultSiteId, siteID)
        XCTAssertEqual(resultVersion, version)
    }

    // MARK: - Send Tests

    func test_send_ShouldNotCrash() async {
        let sut = self.makeSUT()
        let eventPath = "payment/credit_card"
        let mockData = await MockEventData(
            value: "test-123",
            iosMinimium: sut.sellerInfo.getTargetMinimum(),
            deviceInfo: sut.buyerInfo.getDeviceInfo()
        )

        await sut
            .trackEvent(eventPath)
            .setEventData(mockData)
            .send()
    }

    func test_sendWithoutEventData_ShouldNotCrash() async {
        let sut = self.makeSUT()

        await sut.send()
    }

    func test_multipleSends_ShouldNotCrash() async {
        let sut = self.makeSUT()
        let eventPath = "test/path"

        await sut.trackEvent(eventPath).send()
        await sut.send()
    }
}
