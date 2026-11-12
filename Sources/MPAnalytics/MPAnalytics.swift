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
    func toDictionary() -> [String: any Sendable]
}

package extension AnalyticsEventData {
    var isDevelopment: Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }

    func isFromAppStore() -> Bool {
        guard let receiptURL = Bundle.main.appStoreReceiptURL else {
            return false
        }

        do {
            return try receiptURL.checkResourceIsReachable()
        } catch {
            return false
        }
    }
}

private enum APIAnalytics {
    static let url = "https://api.mercadolibre.com/tracks"
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
    func initialize(version: String, siteID: String) async

    /// Sets custom data on this event builder.
    ///
    /// Call this on the builder returned by `trackEvent(_:)` or `trackView(_:)`.
    /// Data configured before starting a tracking chain is not copied to its builder.
    ///
    /// - Parameter data: Object implementing `AnalyticsEventData` containing event data.
    /// - Returns: Self instance for method chaining.
    @discardableResult
    func setEventData(_ data: AnalyticsEventData) async -> AnalyticsInterface

    /// Sets error data on this event builder.
    ///
    /// Call this on the builder returned by `trackEvent(_:)` or `trackView(_:)`.
    /// Errors configured before starting a tracking chain are not copied to its builder.
    ///
    /// - Parameter error: String of error
    /// - Returns: Self instance for method chaining.
    @discardableResult
    func setError(_ error: String) async -> AnalyticsInterface

    /// Tracks a custom event.
    ///
    /// - Parameter path: Path identifying the event (e.g., "payment/credit_card").
    /// - Returns: An isolated event builder for method chaining.
    @discardableResult
    func trackEvent(_ path: String) async -> AnalyticsInterface

    /// Tracks a screen view.
    ///
    /// - Parameter path: Path identifying the screen (e.g., "checkout/review").
    /// - Returns: An isolated event builder for method chaining.
    @discardableResult
    func trackView(_ path: String) async -> AnalyticsInterface

    /// Sends the current event for processing. Error paths may attach a correlation ID
    /// that is scoped to this one payload.
    func send(observabilityEventID: String?) async
}

package extension AnalyticsInterface {
    /// Convenience for the existing analytics-only call sites.
    func send() async {
        await self.send(observabilityEventID: nil)
    }
}

/// Core analytics implementation for the MercadoPago SDK.
///
/// This class is responsible for:
/// - Collecting events and screen views
/// - Aggregating environment data
/// - Formatting and sending analytics data
///
/// Each tracking chain owns actor-isolated event state.
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
    actor TrackEvent {
        struct Snapshot: Sendable {
            let path: String
            let type: TrackType
            let eventData: AnalyticsEventData?
            let error: String?
        }

        /// Custom data for the current event.
        private var eventData: AnalyticsEventData?

        /// Path identifying the current event or view.
        private var path = ""

        /// Type of the current tracking (event or view).
        private var type: TrackType = .event

        private var error: String?

        init(path: String = "", type: TrackType = .event) {
            self.path = path
            self.type = type
        }

        func consume() -> Snapshot {
            let snapshot = Snapshot(path: self.path, type: self.type, eventData: self.eventData, error: self.error)
            self.eventData = nil
            self.error = nil
            return snapshot
        }

        func setError(_ error: String?) {
            self.error = error
        }

        func getError() -> String? {
            return self.error
        }

        func setEventData(_ data: AnalyticsEventData?) {
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

    let track: TrackEvent
    private let sendRequest: @Sendable (URLRequest) async throws -> Void

    /// Service providing seller information.
    package let sellerInfo: MPSellerInfo

    /// Service providing buyer and device information.
    package let buyerInfo: MPBuyerInfo

    /// Initializes a new Analytics instance.
    ///
    /// Creates a new UUID session identifier.
    package convenience init() {
        self.init { request in
            _ = try await URLSession.shared.data(for: request)
        }
    }

    init(sendRequest: @escaping @Sendable (URLRequest) async throws -> Void) {
        self.track = TrackEvent()
        self.sellerInfo = MPSellerInfo()
        self.buyerInfo = MPBuyerInfo()
        self.sendRequest = sendRequest
    }

    private init(path: String, type: TrackType, analytics: MPAnalytics) {
        self.track = TrackEvent(path: path, type: type)
        self.sellerInfo = analytics.sellerInfo
        self.buyerInfo = analytics.buyerInfo
        self.sendRequest = analytics.sendRequest
    }

    // MARK: - Interface Implementation

    package func initialize(version: String, siteID: String) async {
        await MPAnalyticsConfiguration.shared.initialize(version: version, siteID: siteID)
    }

    @discardableResult
    package func setEventData(_ data: AnalyticsEventData) async -> AnalyticsInterface {
        await self.track.setEventData(data)

        return self
    }

    @discardableResult
    package func setError(_ error: String) async -> AnalyticsInterface {
        await self.track.setError(error)

        return self
    }

    @discardableResult
    package func trackEvent(_ path: String) async -> AnalyticsInterface {
        return MPAnalytics(path: path, type: .event, analytics: self)
    }

    @discardableResult
    package func trackView(_ path: String) async -> AnalyticsInterface {
        return MPAnalytics(path: path, type: .view, analytics: self)
    }

    /// Processes and sends the current event.
    ///
    /// This method:
    /// 1. Collects user information,
    /// 2. Builds the payload with all required data,
    /// 3. Serializes to JSON,
    /// 4. Sends the data without retaining mutable payload state.
    package func send(observabilityEventID: String?) async {
        let snapshot = await self.track.consume()
        guard await !MPAnalyticsConfiguration.shared.version.isEmpty,
              await !MPAnalyticsConfiguration.shared.siteID.isEmpty else {
            return
        }
        let payload = await buildPayload(snapshot: snapshot, observabilityEventID: observabilityEventID)

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])

            guard let url = URL(string: APIAnalytics.url) else {
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            try await self.sendRequest(request)
        } catch {}
    }

    private func buildPayload(snapshot: TrackEvent.Snapshot, observabilityEventID: String?) async -> [String: Any] {
        var identifierVendor = ""

        await MainActor.run {
            identifierVendor = self.buyerInfo.getUID()
        }

        let payload: [String: Any] = await [
            "path": snapshot.path,
            "user": [
                "uid": identifierVendor,
                "melidata_session_id": await MPAnalyticsConfiguration.shared.sessionID
            ],
            "type": snapshot.type.rawValue,
            "id": UUID().uuidString,
            "user_time": Int64(Date().timeIntervalSince1970 * 1000),
            "event_data": self.getEventData(snapshot: snapshot, observabilityEventID: observabilityEventID),
            "application": [
                "app_name": self.sellerInfo.getBundleIdentifier(),
                "business": "mercadopago",
                "site_id": await MPAnalyticsConfiguration.shared.siteID,
                "version": await MPAnalyticsConfiguration.shared.version
            ],
            "device": [
                "platform": "/mobile/ios",
                "device_name": self.buyerInfo.getDeviceInfo(),
                "connectivity_type": self.buyerInfo.getNetworkType(),
                "os_version": self.buyerInfo.getiOSVersion()
            ]
        ]

        return [
            "tracks": [
                payload
            ]
        ]
    }
}

extension MPAnalytics {
    package static let dataNotApply = "NOT_APPLY"
}

// MARK: - Private Helpers

private extension MPAnalytics {
    /// Retrieves the current event data in JSON format.
    ///
    /// - Returns: Dictionary containing event data or an empty dictionary if no data is present.
    func getEventData(snapshot: TrackEvent.Snapshot, observabilityEventID: String?) -> [String: Any] {
        var eventData = snapshot.eventData?.toDictionary() ?? [:]

        if let error = snapshot.error {
            eventData["error_type"] = error
        }

        if let observabilityEventID {
            eventData["observability_event_id"] = observabilityEventID
        }

        return eventData
    }
}
