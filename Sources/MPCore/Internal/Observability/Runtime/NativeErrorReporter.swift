import Foundation

package final class NativeErrorReporter: ErrorObservabilityReporting {
    private let environment: NativeErrorEnvironment
    private let buffer: BoundedNativeErrorBuffer
    private let transport: NativeErrorTransporting
    private let deliveryPolicy: NativeErrorModuleDeliveryPolicy
    private let eventIDProvider: @Sendable () -> UUID
    private let dateProvider: @Sendable () -> Date
    private let wakeContinuation: AsyncStream<Void>.Continuation
    private let worker: Task<Void, Never>

    package init(
        deliveryPolicy: NativeErrorModuleDeliveryPolicy = NativeErrorModuleDeliveryPolicy(),
        environment: NativeErrorEnvironment = NativeErrorEnvironment(),
        buffer: BoundedNativeErrorBuffer = BoundedNativeErrorBuffer(),
        transport: NativeErrorTransporting = NativeErrorTransport(),
        eventIDProvider: @escaping @Sendable () -> UUID = UUID.init,
        dateProvider: @escaping @Sendable () -> Date = Date.init
    ) {
        self.deliveryPolicy = deliveryPolicy
        self.environment = environment
        self.buffer = buffer
        self.transport = transport
        self.eventIDProvider = eventIDProvider
        self.dateProvider = dateProvider

        let (wakeStream, wakeContinuation) = AsyncStream<Void>.makeStream(
            bufferingPolicy: .bufferingNewest(1)
        )
        self.wakeContinuation = wakeContinuation
        worker = Task.detached(priority: .utility) { [buffer, environment, transport] in
            for await _ in wakeStream {
                while !Task.isCancelled, let buffered = buffer.first() {
                    let snapshot: NativeErrorEnvironmentSnapshot
                    if let captured = buffered.environment {
                        snapshot = captured
                    } else if let configured = await environment.snapshot() {
                        snapshot = configured
                    } else {
                        break
                    }
                    do {
                        try await transport.send(NativeErrorReport(
                            pending: buffered.pending(with: snapshot)
                        ))
                    } catch {
                        // Best-effort telemetry must never escape into the SDK operation.
                    }
                    buffer.removeFirst()
                }
            }
        }
    }

    package func configure(_ configuration: NativeObservabilityConfiguration) async {
        await environment.configure(configuration)
        wakeContinuation.yield()
    }

    package func capture(
        operation: NativeErrorOperation,
        input: NativeErrorInput
    ) async -> NativeErrorReceipt {
        await captureClassified(NativeErrorClassifier.classify(operation: operation, input: input))
    }

    private func captureClassified(_ classifiedError: ClassifiedNativeError) async -> NativeErrorReceipt {
        let deliveryMode = deliveryPolicy.mode(for: classifiedError.operation.module)
        let eventID = eventIDProvider()
        let receipt = NativeErrorReceipt(
            eventID: eventID.uuidString.lowercased(),
            shouldSendMelidata: deliveryMode.sendsMelidata
        )

        guard deliveryMode.sendsObservability else {
            return receipt
        }

        let buffered = await BufferedNativeError(
            eventID: eventID,
            occurredAt: dateProvider(),
            environment: environment.snapshot(),
            error: classifiedError
        )
        if buffer.append(buffered) {
            wakeContinuation.yield()
        }
        return receipt
    }

    deinit {
        wakeContinuation.finish()
        worker.cancel()
    }
}
