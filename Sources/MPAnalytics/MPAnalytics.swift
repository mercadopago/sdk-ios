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
package protocol AnalyticsEventData: Sendable, Encodable {
    /// Converts event data into a JSON-compatible dictionary format.
    ///
    /// - Returns: A dictionary containing the formatted event data for JSON serialization.
    func toDictionary() -> [String: Any]
}

/// Defines the core analytics tracking functionality.
///
/// This protocol provides methods for:
/// - Tracking custom events
/// - Tracking screen views
/// - Configuring event data
/// - Accessing seller and buyer information
///
/// All operations are asynchronous and thread-safe.
package protocol AnalyticsInterface: Sendable {
    /// Information related to the seller/merchant.
    var sellerInfo: MPSellerInfo { get }

    /// Information related to the buyer and device.
    var buyerInfo: MPBuyerInfo { get }

    /// Initializes the analytics system.
    ///
    /// - Parameter version: Version of SDK.
    /// - Parameter siteID: Site ID of the app.
    func initialize(version: String, siteID: String)

    /// Sets custom data for the next event.
    ///
    /// - Parameter data: Object implementing `AnalyticsEventData` containing event data.
    /// - Returns: Self instance for method chaining.
    @discardableResult
    func setEventData(_ data: AnalyticsEventData) async -> AnalyticsInterface

    /// Tracks a custom event.
    ///
    /// - Parameter path: Path identifying the event (e.g., "payment/credit_card").
    /// - Returns: Self instance for method chaining.
    @discardableResult
    func trackEvent(_ path: String) async -> AnalyticsInterface

    /// Tracks a screen view.
    ///
    /// - Parameter path: Path identifying the screen (e.g., "checkout/review").
    /// - Returns: Self instance for method chaining.
    @discardableResult
    func trackView(_ path: String) async -> AnalyticsInterface

    /// Sends the current event for processing.
    func send() async
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
/// let analytics = MPAnalytics()
/// await analytics
///     .trackEvent("payment/credit_card")
///     .setEventData(paymentData)
///     .send()
/// ```
package final class MPAnalytics: AnalyticsInterface {
    /// Unique identifier for the current analytics session.
    private let sessionId: String

    actor TrackEvent {
        /// Custom data for the current event.
        private var eventData: AnalyticsEventData?

        /// Path identifying the current event or view.
        private var path = ""

        /// Type of the current tracking (event or view).
        private var type: TrackType = .event

        func setEventData(_ data: AnalyticsEventData) {
            self.eventData = data
        }

        func getEventData() -> AnalyticsEventData? {
            return self.eventData
        }

        func setType(_ type: TrackType) {
            self.type = type
        }

        func getType() -> TrackType {
            return self.type
        }

        func setPath(_ path: String) {
            self.path = path
        }

        func getPath() -> String {
            return self.path
        }
    }

    let track = TrackEvent()

    /// Service providing seller information.
    package let sellerInfo = MPSellerInfo()

    /// Service providing buyer and device information.
    package let buyerInfo = MPBuyerInfo()

    /// Initializes a new Analytics instance.
    ///
    /// Creates a new UUID session identifier.
    package init() {
        self.sessionId = UUID().uuidString
    }

    // MARK: - Interface Implementation

    package func initialize(version: String, siteID: String) {
        MPAnalyticsConfiguration.version = version
        MPAnalyticsConfiguration.siteID = siteID
    }

    @discardableResult
    package func setEventData(_ data: AnalyticsEventData) async -> AnalyticsInterface {
        await self.track.setEventData(data)

        return self
    }

    @discardableResult
    package func trackEvent(_ path: String) async -> AnalyticsInterface {
        await self.track.setType(.event)
        await self.track.setPath(path)

        return self
    }

    @discardableResult
    package func trackView(_ path: String) async -> AnalyticsInterface {
        await self.track.setType(.view)
        await self.track.setPath(path)

        return self
    }

    /// Processes and sends the current event.
    ///
    /// This method:
    /// 1. Collects user information,
    /// 2. Builds the payload with all required data,
    /// 3. Serializes to JSON,
    /// 4. Sends the data (currently just prints to console).
    ///
    /// - Note: Actual data sending implementation should be added in the future.
    package func send() async {
        assert(
            !MPAnalyticsConfiguration.version.isEmpty && !MPAnalyticsConfiguration.siteID.isEmpty,
            "Analytics not initialized. You must call initialize(version:siteID:) before sending events."
        )

        guard !MPAnalyticsConfiguration.version.isEmpty,
              !MPAnalyticsConfiguration.siteID.isEmpty else {
            return
        }

        let payload: [String: Any] = await [
            "path": track.getPath(),
            "user": [
                "uid": self.buyerInfo.getUID()
            ],
            "type": self.track.getType().rawValue,
            "id": self.sessionId,
            "user_time": Int64(Date().timeIntervalSince1970 * 1000),
            "event_data": getEventData(),
            "application": [
                "business": "mercadopago",
                "site_id": MPAnalyticsConfiguration.siteID,
                "version": MPAnalyticsConfiguration.version
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
    /// Retrieves the current event data in JSON format.
    ///
    /// - Returns: Dictionary containing event data or an empty dictionary if no data is present.
    func getEventData() async -> [String: Any] {
        guard let data = await track.getEventData() else {
            return [:]
        }

        return data.toDictionary()
    }
}
