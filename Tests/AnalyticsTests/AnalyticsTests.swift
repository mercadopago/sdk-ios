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

    func toDictionary() -> [String: String] {
        return ["test_value": self.value, "deviceInfo": self.deviceInfo, "iosMinimium": self.iosMinimium]
    }
}

// MARK: - Setup SUT

private extension AnalyticsTests {
    typealias SUT = MPAnalytics

    func makeSUT(file _: StaticString = #filePath, line _: UInt = #line) async -> SUT {
        let sut = MPAnalytics()
        await sut.initialize(version: "1.0.0", siteID: "MLB")

        return sut
    }
}

final class AnalyticsTests: XCTestCase {
    // MARK: - Event Tracking Tests

    func test_trackEvent_ShouldSetCorrectPathAndType() async {
        let sut = await self.makeSUT()
        let eventPath = "payment/credit_card"

        await sut.trackEvent(eventPath)

        let path = await sut.track.getPath()
        let type = await sut.track.getType()

        XCTAssertEqual(path, eventPath)
        XCTAssertEqual(type, .event)
    }

    func test_trackView_ShouldSetCorrectPathAndType() async {
        let sut = await self.makeSUT()
        let viewPath = "checkout/review"

        await sut.trackView(viewPath)

        let path = await sut.track.getPath()
        let type = await sut.track.getType()

        XCTAssertEqual(path, viewPath)
        XCTAssertEqual(type, .view)
    }

    // MARK: - Event Data Tests

    func test_setEventData_ShouldStoreEventData() async {
        let sut = await self.makeSUT()
        let mockData = MockEventData(
            value: "test-123",
            iosMinimium: sut.sellerInfo.getTargetMinimum(),
            deviceInfo: sut.buyerInfo.getDeviceInfo()
        )

        await sut.setEventData(mockData)

        guard let storedData = await sut.track.getEventData() as? MockEventData else {
            return XCTFail("Event Data is not stored")
        }
        XCTAssertEqual(storedData.value, "test-123")
        XCTAssertEqual(storedData.iosMinimium, "iOS 13.0")
        XCTAssertEqual(storedData.deviceInfo, "arm64")
    }

    // MARK: - Method Chaining Tests

    func test_methodChaining_ShouldReturnSelfAndUpdateValues() async {
        let sut = await self.makeSUT()
        let eventPath = "payment/credit_card"
        let mockData = MockEventData(
            value: "test-123",
            iosMinimium: sut.sellerInfo.getTargetMinimum(),
            deviceInfo: sut.buyerInfo.getDeviceInfo()
        )

        await sut
            .trackEvent(eventPath)
            .setEventData(mockData)

        let path = await sut.track.getPath()
        let type = await sut.track.getType()
        let resultEventData = await sut.track.getEventData() as? MockEventData

        XCTAssertEqual(path, eventPath)
        XCTAssertEqual(type, .event)
        XCTAssertEqual(resultEventData?.value, "test-123")
    }

    func test_setError_ShouldStoreError() async {
        let sut = await self.makeSUT()
        let expectError = "Error in line 123"

        await sut.setError(expectError)

        guard let storedError = await sut.track.getError() else {
            return XCTFail("Event Data is not stored")
        }
        XCTAssertEqual(storedError, expectError)
    }

    // MARK: - Send Tests

    func test_send_ShouldNotCrash() async {
        let sut = await self.makeSUT()
        let eventPath = "payment/credit_card"
        let mockData = MockEventData(
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
        let sut = await self.makeSUT()

        await sut.send()
    }

    func test_multipleSends_ShouldNotCrash() async {
        let sut = await self.makeSUT()
        let eventPath = "test/path"

        await sut.trackEvent(eventPath).send()
        await sut.send()
    }
}
