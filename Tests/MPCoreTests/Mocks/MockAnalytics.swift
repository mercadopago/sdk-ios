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
            case setEventData
            case send
            case trackView(_ path: String)

            static func == (lhs: Messages, rhs: Messages) -> Bool {
                switch (lhs, rhs) {
                case let (.initialize(lVersion, lSiteID), .initialize(rVersion, rSiteID)):
                    return lVersion == rVersion && lSiteID == rSiteID

                case let (.track(lPath), .track(rPath)):
                    return lPath == rPath

                case (.setEventData, .setEventData):
                    return true

                case (.send, .send):
                    return true

                case let (.trackView(lPath), .trackView(rPath)):
                    return lPath == rPath

                default:
                    return false
                }
            }
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

    func initialize(version: String, siteID: String) {
        Task {
            await self.mock.insert(.initialize(version: version, siteID: siteID))
        }
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
    func setEventData(_: AnalyticsEventData) async -> AnalyticsInterface {
        await self.mock.insert(.setEventData)
        return self
    }

    func send() async {
        await self.mock.insert(.send)
    }
}
