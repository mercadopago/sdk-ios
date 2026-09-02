import Foundation

package final class BoundedNativeErrorBuffer: @unchecked Sendable {
    package let capacity: Int
    private let lock = NSLock()
    private var storage: [PendingNativeError?]
    private var headIndex = 0
    private var count = 0

    package init(capacity: Int = 64) {
        precondition(capacity > 0)
        self.capacity = capacity
        self.storage = Array(repeating: nil, count: capacity)
    }

    @discardableResult
    package func append(_ value: PendingNativeError) -> Bool {
        lock.withNativeErrorLock {
            guard count < capacity else { return false }
            storage[(headIndex + count) % capacity] = value
            count += 1
            return true
        }
    }

    package func first() -> PendingNativeError? {
        lock.withNativeErrorLock {
            guard count > 0 else { return nil }
            return storage[headIndex]
        }
    }

    package func removeFirst() {
        lock.withNativeErrorLock {
            guard count > 0 else { return }
            storage[headIndex] = nil
            headIndex = (headIndex + 1) % capacity
            count -= 1
        }
    }

    package var currentCount: Int {
        lock.withNativeErrorLock { count }
    }
}

extension NSLock {
    fileprivate func withNativeErrorLock<T>(_ body: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try body()
    }
}
