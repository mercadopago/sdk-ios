import Foundation

package struct BufferedNativeError: Sendable {
    package let eventID: UUID
    package let occurredAt: Date
    package let environment: NativeErrorEnvironmentSnapshot?
    package let error: ClassifiedNativeError

    package init(
        eventID: UUID,
        occurredAt: Date,
        environment: NativeErrorEnvironmentSnapshot?,
        error: ClassifiedNativeError
    ) {
        self.eventID = eventID
        self.occurredAt = occurredAt
        self.environment = environment
        self.error = error
    }

    package init(_ pending: PendingNativeError) {
        self.init(
            eventID: pending.eventID,
            occurredAt: pending.occurredAt,
            environment: pending.environment,
            error: pending.error
        )
    }

    package func pending(with environment: NativeErrorEnvironmentSnapshot) -> PendingNativeError {
        PendingNativeError(
            eventID: eventID,
            occurredAt: occurredAt,
            environment: self.environment ?? environment,
            error: error
        )
    }
}

package final class BoundedNativeErrorBuffer: @unchecked Sendable {
    package let capacity: Int
    private let lock = NSLock()
    private var storage: [BufferedNativeError?]
    private var headIndex = 0
    private var elementCount = 0

    package init(capacity: Int = 64) {
        precondition(capacity > 0)
        self.capacity = capacity
        storage = Array(repeating: nil, count: capacity)
    }

    @discardableResult
    package func append(_ value: BufferedNativeError) -> Bool {
        lock.withNativeErrorLock {
            guard elementCount < capacity else { return false }
            storage[(headIndex + elementCount) % capacity] = value
            elementCount += 1
            return true
        }
    }

    @discardableResult
    package func append(_ value: PendingNativeError) -> Bool {
        append(BufferedNativeError(value))
    }

    package func first() -> BufferedNativeError? {
        lock.withNativeErrorLock {
            guard elementCount > 0 else { return nil }
            return storage[headIndex]
        }
    }

    package func removeFirst() {
        lock.withNativeErrorLock {
            guard elementCount > 0 else { return }
            storage[headIndex] = nil
            headIndex = (headIndex + 1) % capacity
            elementCount -= 1
        }
    }

    package var currentCount: Int {
        lock.withNativeErrorLock { elementCount }
    }
}

private extension NSLock {
    func withNativeErrorLock<T>(_ body: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try body()
    }
}
