//
//  MockPaymentBrickRepository.swift
//  MercadoPagoSDK
//

import Foundation
@testable import MercadoPagoCheckout

final class MockPaymentBrickRepository: PaymentBrickRepository {
    nonisolated(unsafe) var mockOutput: PaymentInitializationOutput = .mock
    nonisolated(unsafe) var shouldThrow = false
    nonisolated(unsafe) var fetchCallCount = 0
    nonisolated(unsafe) var capturedOrderId: String?
    nonisolated(unsafe) var capturedCustomerId: String?
    nonisolated(unsafe) var capturedCardIds: [String]?

    /// When `true`, `fetchInitialization` suspends until `resumeFetch()` is called.
    /// Use this to inspect ViewModel state while a fetch is in progress.
    nonisolated(unsafe) var shouldSuspendOnFetch = false
    private nonisolated(unsafe) var resumeContinuation: CheckedContinuation<Void, Never>?

    func resumeFetch() {
        self.resumeContinuation?.resume()
        self.resumeContinuation = nil
    }

    func fetchInitialization(
        orderId: String,
        customerId: String?,
        cardIds: [String]
    ) async throws -> PaymentInitializationOutput {
        self.fetchCallCount += 1
        self.capturedOrderId = orderId
        self.capturedCustomerId = customerId
        self.capturedCardIds = cardIds

        if self.shouldSuspendOnFetch {
            await withCheckedContinuation { self.resumeContinuation = $0 }
        }

        if self.shouldThrow { throw NSError(domain: "test", code: -1) }
        return self.mockOutput
    }
}
