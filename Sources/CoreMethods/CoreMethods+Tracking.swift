//
//  CoreMethods+Tracking.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 04/11/25.
//
#if SWIFT_PACKAGE
    import MPAnalytics
    import MPCore
#endif

// MARK: Execute Operation of Core Methods

extension CoreMethods {
    enum AnalyticsPath {
        static let identificationTypes = "/checkout_api_native/core_methods/identification_types"
        static let installments = "/checkout_api_native/core_methods/installments"
        static let paymentMethods = "/checkout_api_native/core_methods/payment_methods"
        static let tokenization = "/checkout_api_native/core_methods/tokenization"
        static let issuers = "/checkout_api_native/core_methods/issuers"
    }

    func executeWithTracking<T: Sendable>(
        operation: @Sendable () async throws -> T,
        path: String,
        observabilityOperation: NativeErrorOperation,
        extractEventData: (@Sendable (T?) async -> (any AnalyticsEventData)?)? = nil
    ) async throws -> T {
        do {
            let result = try await operation()

            Task(priority: .low) {
                let event = await self.dependencies.analytics.trackEvent(path)

                if let extractEventData,
                   let eventData = await extractEventData(result) {
                    await event.setEventData(eventData)
                }

                await event.send()
            }

            return result
        } catch {
            let classified = Self.classifiedNativeError(from: error, operation: observabilityOperation)
            let receipt = self.dependencies.errorObservability.capture(classified)
            let legacyError = String(describing: error)

            if receipt.shouldSendMelidata {
                Task(priority: .low) {
                    let event = await self.dependencies.analytics
                        .trackEvent(path + "/error")
                        .setError(legacyError)

                    if let extractEventData,
                       let eventData = await extractEventData(nil) {
                        await event.setEventData(eventData)
                    }

                    await event.send(observabilityEventID: receipt.eventID)
                }
            }

            throw error
        }
    }
}
