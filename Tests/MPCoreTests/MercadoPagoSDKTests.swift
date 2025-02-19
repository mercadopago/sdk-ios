//
//  MercadoPagoSDKTests.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 14/02/25.
//

import CommonTests
@testable import MPCore
import XCTest

private class MockFetchSiteIDUseCase: FetchSiteIDUseCaseProtocol {
    var result = "MLB"

    func getSiteID(with _: String, and _: MPCore.MercadoPagoSDK.Country) async -> String {
        self.result
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
        let locale = "pt-BR"

        let config = MercadoPagoSDK.Configuration(
            publicKey: "test_key",
            locale: locale,
            country: .BRA
        )

        let expectEventData = MPInicializationEventData(
            locale: locale,
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
                .initialize(version: MPSDKVersion.version, siteID: "MLB"),
                .track(path: "/sdk-native"),
                .setEventData(expectEventData.toDictionary()),
                .send
            ]
        )
    }

    func test_getPublicKey_Initialized_SDK_ShouldReturnCorrectKey() {
        let (sut, _, _) = self.makeSUT()
        let config = MercadoPagoSDK.Configuration(publicKey: "test_key", country: .ARG)

        sut.initialize(config)

        XCTAssertEqual(sut.getPublicKey(), "test_key")
    }
}
