//
//  MockAnalytics.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 14/02/25.
//

import MPAnalytics

final class MockAnalytics: AnalyticsInterface {
    actor Mock {
        enum Messages: Equatable {
            case initialize(version: String, siteID: String)
            case track(path: String)
            case setEventData([String: String])
            case send
            case trackView(_ path: String)
        }

        var messages: [Messages] = []

        func insert(_ message: Messages) {
            self.messages.append(message)
        }

        func getMessages() -> [Messages] {
            self.messages
        }
    }

    let mock = Mock()

    let sellerInfo = MPSellerInfo()
    let buyerInfo = MPBuyerInfo()

    func initialize(version: String, siteID: String) async {
        await self.mock.insert(.initialize(version: version, siteID: siteID))
    }

    @discardableResult
    func trackView(_ path: String) async -> AnalyticsInterface {
        await self.mock.insert(.trackView(path))
        return self
    }

    @discardableResult
    func trackEvent(_ path: String) async -> AnalyticsInterface {
        await self.mock.insert(.track(path: path))
        return self
    }

    @discardableResult
    func setEventData(_ data: AnalyticsEventData) async -> AnalyticsInterface {
        await self.mock.insert(.setEventData(data.toDictionary()))
        return self
    }

    func send() async {
        await self.mock.insert(.send)
    }
}
