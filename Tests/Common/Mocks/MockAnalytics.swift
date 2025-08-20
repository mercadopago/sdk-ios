//
//  MockAnalytics.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 14/02/25.
//

import MPAnalytics

package final class MockAnalytics: AnalyticsInterface {
    package actor Mock {
        package var sendCallback: (() -> Void)?

        package enum Messages: Equatable {
            case initialize(version: String, siteID: String)
            case track(path: String)
            case setEventData([String: any Sendable])
            case send
            case trackView(_ path: String)
            case setError(String)

            package static func == (lhs: Messages, rhs: Messages) -> Bool {
                switch (lhs, rhs) {
                case let (.initialize(lVersion, lSiteID), .initialize(rVersion, rSiteID)):
                    return lVersion == rVersion && lSiteID == rSiteID

                case let (.track(lPath), .track(rPath)):
                    return lPath == rPath

                case let (.setEventData(lData), .setEventData(rData)):
                    return self.areDictionariesEqual(lData, rData)

                case (.send, .send):
                    return true

                case let (.trackView(lPath), .trackView(rPath)):
                    return lPath == rPath

                case let (.setError(lError), .setError(rError)):
                    return lError == rError

                default:
                    return false
                }
            }

            private static func areDictionariesEqual(_ dict1: [String: Any], _ dict2: [String: Any]) -> Bool {
                guard dict1.keys.count == dict2.keys.count else { return false }

                for (key, value1) in dict1 {
                    guard let value2 = dict2[key] else { return false }

                    if !self.areValuesEqual(value1, value2) {
                        return false
                    }
                }

                return true
            }

            private static func areValuesEqual(_ value1: Any, _ value2: Any) -> Bool {
                // String
                if let v1 = value1 as? String, let v2 = value2 as? String {
                    return v1 == v2
                }
                // Int
                else if let v1 = value1 as? Int, let v2 = value2 as? Int {
                    return v1 == v2
                }
                // Double
                else if let v1 = value1 as? Double, let v2 = value2 as? Double {
                    return v1 == v2
                }
                // Bool
                else if let v1 = value1 as? Bool, let v2 = value2 as? Bool {
                    return v1 == v2
                }
                // [String: Any]
                else if let v1 = value1 as? [String: Any], let v2 = value2 as? [String: Any] {
                    return self.areDictionariesEqual(v1, v2)
                }

                else if let v1 = value1 as? [Any], let v2 = value2 as? [Any] {
                    guard v1.count == v2.count else { return false }

                    for i in 0 ..< v1.count {
                        if !self.areValuesEqual(v1[i], v2[i]) {
                            return false
                        }
                    }
                    return true
                } else {
                    return false
                }
            }
        }

        var messages: [Messages] = []

        package func insert(_ message: Messages) {
            self.messages.append(message)

            if message == .send {
                self.sendCallback?()
            }
        }

        package func getMessages() -> [Messages] {
            self.messages
        }

        package func updateSendCallback(_ callback: @escaping () -> Void) {
            self.sendCallback = callback

            // If a send message was already recorded before the callback was set,
            // trigger the callback immediately to avoid missing the event in async tests.
            if self.messages.contains(.send) {
                callback()
            }
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

    @discardableResult
    package func setError(_ error: String) async -> AnalyticsInterface {
        await self.mock.insert(.setError(error))

        return self
    }

    package func send() async {
        await self.mock.insert(.send)
    }
}
