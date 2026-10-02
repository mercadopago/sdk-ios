//
//  MockStatusScreenUseCase.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout

final actor MockStatusScreenUseCase: StatusScreenUseCaseProtocol {
    enum Behavior: Sendable {
        case success(StatusScreenOutput)
        case failure(MercadoPagoCheckoutError)
        case suspended(StatusScreenOutput)
        case suspendedFailure(MercadoPagoCheckoutError)
    }

    struct Invocation: Equatable, Sendable {
        let orderID: String
        let clientToken: String
        let lastFourDigits: String?
        let sellerInfo: MPSellerInfo?
    }

    private(set) var invocations: [Invocation] = []

    var callCount: Int { self.invocations.count }

    private let behavior: Behavior
    private let startedStream: AsyncStream<Void>
    private let startedContinuation: AsyncStream<Void>.Continuation
    private var resumeContinuation: CheckedContinuation<Void, Never>?
    private var isResumeRequested = false

    init(behavior: Behavior) {
        let startedPair = AsyncStream<Void>.makeStream()
        self.behavior = behavior
        self.startedStream = startedPair.stream
        self.startedContinuation = startedPair.continuation
    }

    func execute(
        orderID: String,
        clientToken: String,
        lastFourDigits: String?,
        sellerInfo: MPSellerInfo?
    ) async throws(MercadoPagoCheckoutError) -> StatusScreenOutput {
        self.invocations.append(
            Invocation(
                orderID: orderID,
                clientToken: clientToken,
                lastFourDigits: lastFourDigits,
                sellerInfo: sellerInfo
            )
        )
        self.startedContinuation.yield()

        switch self.behavior {
        case let .success(output):
            return output
        case let .failure(error):
            throw error
        case let .suspended(output):
            await self.waitForResume()
            return output
        case let .suspendedFailure(error):
            await self.waitForResume()
            throw error
        }
    }

    func waitUntilCalled() async {
        var iterator = self.startedStream.makeAsyncIterator()
        _ = await iterator.next()
    }

    func resume() {
        guard let resumeContinuation else {
            self.isResumeRequested = true
            return
        }
        resumeContinuation.resume()
        self.resumeContinuation = nil
    }

    private func waitForResume() async {
        guard !self.isResumeRequested else {
            self.isResumeRequested = false
            return
        }
        await withCheckedContinuation { continuation in
            self.resumeContinuation = continuation
        }
    }
}
