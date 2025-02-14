//
//  DependencyContainerMock.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 14/02/25.
//
import MPAnalytics
@testable import MPCore
import XCTest

struct MockDependencyContainer: Sendable, HasKeyChain, HasNetwork, HasAnalytics {
    let keyChainService: KeyChainManagerProtocol

    let networkService: NetworkServiceProtocol

    var analytics: AnalyticsInterface

    let mockSession: MockURLSession
    let mockKeyChainService: MockKeyChainService
    let mockAnalytics: MockAnalytics

    init(
        session: MockURLSession = MockURLSession(),
        keyChainService: MockKeyChainService = MockKeyChainService(),
        analytics: MockAnalytics = MockAnalytics()
    ) {
        self.mockSession = session
        self.mockKeyChainService = keyChainService
        self.mockAnalytics = analytics

        self.networkService = NetworkService(session: session)
        self.keyChainService = keyChainService
        self.analytics = analytics
    }
}
