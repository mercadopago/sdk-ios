//
//  DependencyContainerMock.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 14/02/25.
//
import MPAnalytics
@testable import MPCore
import XCTest

package struct MockDependencyContainer: Sendable, HasNetwork, HasAnalytics, HasFingerPrint, HasNoDependency {
    package let networkService: NetworkServiceProtocol

    package var analytics: AnalyticsInterface

    package let fingerPrint: FingerPrintProtocol

    package let mockSession: MockURLSession
    package let mockAnalytics: MockAnalytics

    package init(
        session: MockURLSession = MockURLSession(),
        analytics: MockAnalytics = MockAnalytics(),
        fingerPrint: MockFingerPrint = MockFingerPrint()
    ) {
        self.mockSession = session
        self.mockAnalytics = analytics

        self.networkService = NetworkService(session: session)
        self.analytics = analytics
        self.fingerPrint = fingerPrint
    }
}
