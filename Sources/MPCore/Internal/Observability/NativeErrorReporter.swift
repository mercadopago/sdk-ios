import Foundation

package final class NativeErrorReporter: ErrorObservabilityReporting, @unchecked Sendable {
    private let environment: NativeErrorEnvironment
    private let buffer: BoundedNativeErrorBuffer
    private let transport: NativeErrorTransporting
    private let deliveryMode: NativeErrorDeliveryMode
    private let eventIDProvider: @Sendable () -> UUID
    private let dateProvider: @Sendable () -> Date
    private let wakeContinuation: AsyncStream<Void>.Continuation
    private let worker: Task<Void, Never>

    package init(
        deliveryMode: NativeErrorDeliveryMode = .dualWrite,
        environment: NativeErrorEnvironment = NativeErrorEnvironment(),
        buffer: BoundedNativeErrorBuffer = BoundedNativeErrorBuffer(),
        transport: NativeErrorTransporting = NativeErrorTransport(),
        eventIDProvider: @escaping @Sendable () -> UUID = UUID.init,
        dateProvider: @escaping @Sendable () -> Date = Date.init
    ) {
        self.deliveryMode = deliveryMode
        self.environment = environment
        self.buffer = buffer
        self.transport = transport
        self.eventIDProvider = eventIDProvider
        self.dateProvider = dateProvider

        let (wakeStream, wakeContinuation) = AsyncStream<Void>.makeStream(
            bufferingPolicy: .bufferingNewest(1)
        )
        self.wakeContinuation = wakeContinuation
        self.worker = Task.detached(priority: .utility) { [buffer, transport] in
            for await _ in wakeStream {
                while !Task.isCancelled, let pending = buffer.first() {
                    do {
                        _ = try await transport.send(NativeErrorReport(pending: pending))
                    } catch {
                        // Best-effort telemetry must never escape into the SDK operation.
                    }
                    buffer.removeFirst()
                }
            }
        }
    }

    package func configure(sdkVersion: String, country: MercadoPagoSDK.Country) {
        environment.configure(sdkVersion: sdkVersion, country: country)
    }

    package func capture(_ classifiedError: ClassifiedNativeError) -> NativeErrorReceipt {
        let eventID = eventIDProvider()
        let receipt = NativeErrorReceipt(
            eventID: eventID.uuidString.lowercased(),
            shouldSendMelidata: deliveryMode.sendsMelidata
        )

        guard deliveryMode.sendsObservability, let snapshot = environment.snapshot() else {
            return receipt
        }

        let pending = PendingNativeError(
            eventID: eventID,
            occurredAt: dateProvider(),
            environment: snapshot,
            error: classifiedError
        )
        if buffer.append(pending) {
            wakeContinuation.yield()
        }
        return receipt
    }

    deinit {
        wakeContinuation.finish()
        worker.cancel()
    }
}
