//
//  MPAnalytics.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 03/01/25.
//  Copyright © 2024 Mercado Pago. All rights reserved.
//

import Foundation

/// Protocol that defines the structure for analytics event data.
///
/// This protocol ensures that any event data can be:
/// - Serialized to JSON
/// - Safely used in concurrent environments
/// - Converted to a consistent dictionary format
///
/// Example:
/// ```swift
/// struct PaymentEventData: AnalyticsEventData {
///     let amount: Decimal
///     let currencyType: String
///
///     func toDictionary() -> [String: Any] {
///         return [
///             "amount": amount,
///             "currency_type": currencyType
///         ]
///     }
/// }
/// ```
public protocol AnalyticsEventData: Sendable, Encodable {
    /// Converts event data into a JSON-compatible dictionary format
    ///
    /// - Returns: A dictionary containing the formatted event data for JSON serialization
    func toDictionary() -> [String: Any]
}

/// Core analytics implementation for the MercadoPago SDK.
///
/// This class is responsible for:
/// - Collecting events and screen views
/// - Aggregating environment data
/// - Formatting and sending analytics data
///
/// Implemented as a Swift actor to ensure thread-safety in concurrent operations.
///
/// Example:
/// ```swift
/// let analytics = Analytics()
/// await analytics
///     .trackEvent("payment/credit_card")
///     .setEventData(paymentData)
///     .setSiteID("MLB")
///     .send()
/// ```
package final actor MPAnalytics {
    /// Unique identifier for the current analytics session
    let sessionId: String

    /// Custom data for the current event
    var eventData: AnalyticsEventData?

    /// Path identifying the current event or view
    var path = ""

    /// Type of the current tracking (event or view)
    var type: TrackType = .event

    /// SDK version
    static var version = ""

    /// Site ID (e.g., MLB, MLA)
    static var siteId = ""

    /// Service providing seller information
    package let sellerInfo = MPSellerInfo()

    /// Service providing buyer and device information
    package let buyerInfo = MPBuyerInfo()

    /// Initializes a new Analytics instance
    ///
    /// Creates a new UUID session identifier
    package init() {
        self.sessionId = UUID().uuidString
    }

    // MARK: - Interface Implementation

    @discardableResult
    public func setEventData(_ data: AnalyticsEventData) async -> MPAnalytics {
        self.eventData = data
        return self
    }

    @discardableResult
    package func trackEvent(_ path: String) async -> MPAnalytics {
        self.type = .event
        self.path = path
        return self
    }

    @discardableResult
    package func trackView(_ path: String) async -> MPAnalytics {
        self.type = .view
        self.path = path
        return self
    }

    /// Processes and sends the current event
    ///
    /// This method:
    /// 1. Collects user information
    /// 2. Builds the payload with all required data
    /// 3. Serializes to JSON
    /// 4. Sends the data (currently just prints to console)
    ///
    /// - Note: Actual data sending implementation should be added in the future
    package func send() async {
        let idUser = await buyerInfo.getUID()

        let payload: [String: Any] = [
            "path": path,
            "user": [
                "uid": idUser
            ],
            "type": type.rawValue,
            "id": self.sessionId,
            "user_time": Int64(Date().timeIntervalSince1970 * 1000),
            "event_data": getEventData(),
            "application": [
                "business": "mercadopago",
                "site_id": MPAnalytics.siteId,
                "version": MPAnalytics.version
            ],
            "device": [
                "platform": "iOS"
            ]
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)

            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Tracking event:", jsonString)
            }

        } catch {
            print("Error converting to JSON:", error)
        }
    }
}

// MARK: - Private Helpers

private extension MPAnalytics {
    /// Retrieves the current event data in JSON format
    ///
    /// - Returns: Dictionary containing event data or an empty dictionary if no data is present
    func getEventData() -> [String: Any] {
        guard let data = self.eventData else {
            return [String: Any]()
        }

        return data.toDictionary()
    }
}
