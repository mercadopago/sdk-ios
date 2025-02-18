//
//  MercadoPagoSDKTests.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 14/02/25.
//

import Common
@testable import MPCore
import XCTest

private class MockFetchSiteIDUseCase: FetchSiteIDUseCaseProtocol {
    var result = "MLB"

    func getSiteID(by _: String) async -> String {
        return self.result
    }
}

// MARK: - Setup SUT

private extension MercadoPagoSDKTests {
    typealias SUT = (
        sut: MercadoPagoSDK,
        analytics: MockAnalytics,
        siteIDUseCase: MockFetchSiteIDUseCase
    )

    func makeSUT(file _: StaticString = #filePath, line _: UInt = #line) -> SUT {
        let container = MockDependencyContainer()
        let analytics = container.mockAnalytics
        let siteIDUseCase = MockFetchSiteIDUseCase()

        let sut = MercadoPagoSDK(dependencies: container, useCase: siteIDUseCase)

        return (sut, analytics, siteIDUseCase)
    }
}

final class MercadoPagoSDKTests: XCTestCase {
    // MARK: - Initialization Tests

    func test_initialize_WithValidConfiguration_ShouldSetPropertiesCorrectly() async {
        let (sut, analytics, _) = self.makeSUT()
        let config = MercadoPagoSDK.Configuration(publicKey: "test_key", locale: "pt-BR")
        let expectEventData = MPInicializationEventData(
            locale: "pt-BR",
            distribution: analytics.sellerInfo.getDistribution().rawValue,
            minimumVersionApp: analytics.sellerInfo.getTargetMinimum()
        )

        sut.initialize(config)

        XCTAssertTrue(sut.isInitialized)
        XCTAssertEqual(sut.getPublicKey(), "test_key")

        await sut.analyticsMonitoringTask?.value

        let messages = await analytics.mock.getMessages()

        XCTAssertEqual(
            messages,
            [
                .initialize(version: MPSDKVersion.version, siteID: "MLB"),
                .track(path: "/sdk-native"),
                .setEventData(expectEventData.toDictionary()),
                .send
            ]
        )
    }

    func test_getPublicKey_Initialized_SDK_ShouldReturnCorrectKey() {
        let (sut, _, _) = self.makeSUT()
        let config = MercadoPagoSDK.Configuration(publicKey: "test_key")

        sut.initialize(config)

        XCTAssertEqual(sut.getPublicKey(), "test_key")
    }
}
