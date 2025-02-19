//
//  MockAnalytics.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 14/02/25.
//

import MPAnalytics

package final class MockAnalytics: AnalyticsInterface {
    package actor Mock {
        package enum Messages: Equatable {
            case initialize(version: String, siteID: String)
            case track(path: String)
            case setEventData([String: String])
            case send
            case trackView(_ path: String)
        }

        var messages: [Messages] = []

        package func insert(_ message: Messages) {
            self.messages.append(message)
        }

        package func getMessages() -> [Messages] {
            self.messages
        }
    }

    package let mock = Mock()

    package let sellerInfo = MPSellerInfo()
    package let buyerInfo = MPBuyerInfo()

    package func initialize(version: String, siteID: String) async {
        await self.mock.insert(.initialize(version: version, siteID: siteID))
    }

    @discardableResult
    package func trackView(_ path: String) async -> AnalyticsInterface {
        await self.mock.insert(.trackView(path))
        return self
    }

    @discardableResult
    package func trackEvent(_ path: String) async -> AnalyticsInterface {
        await self.mock.insert(.track(path: path))
        return self
    }

    @discardableResult
    package func setEventData(_ data: AnalyticsEventData) async -> AnalyticsInterface {
        await self.mock.insert(.setEventData(data.toDictionary()))
        return self
    }

    package func send() async {
        await self.mock.insert(.send)
    }
}
