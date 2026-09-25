//
//  CoreMethods+Tracking.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 04/11/25.
//
#if SWIFT_PACKAGE
    import MPAnalytics
#endif

private actor AnalyticsEventQueue {
    private var tail: Task<Void, Never>?

    func enqueue(_ operation: @escaping @Sendable () async -> Void) {
        let previous = tail
        let task = Task(priority: .low) {
            await previous?.value
            await operation()
        }
        tail = task
    }
}

private let coreMethodsAnalyticsEventQueue = AnalyticsEventQueue()

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
        tracksErrorEvents: Bool = true,
        extractEventData: (@Sendable (T?) async -> (any AnalyticsEventData)?)? = nil
    ) async throws -> T {
        do {
            let result = try await operation()

            let analytics = self.dependencies.analytics
            let analyticsQueue = coreMethodsAnalyticsEventQueue
            Task(priority: .low) {
                await analyticsQueue.enqueue {
                    let event = await analytics.trackEvent(path)

                    if let extractEventData,
                       let eventData = await extractEventData(result) {
                        await event.setEventData(eventData)
                    }

                    await event.send()
                }
            }

            return result
        } catch {
            guard tracksErrorEvents else {
                throw error
            }

            let errorDescription = "\(error)"
            let receipt = await self.dependencies.errorObservability.capture(
                operation: observabilityOperation,
                input: Self.nativeErrorInput(from: error)
            )
            let analytics = self.dependencies.analytics
            let analyticsQueue = coreMethodsAnalyticsEventQueue
            Task(priority: .low) {
                await analyticsQueue.enqueue {
                    guard receipt.shouldSendMelidata else { return }
                    let event = await analytics
                        .trackEvent(path + "/error")
                        .setError(errorDescription)

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
