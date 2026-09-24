//
//  MockReceiptDocumentRepository.swift
//  MercadoPagoSDK
//

import Foundation
@testable import MercadoPagoCheckout

@MainActor
final class MockReceiptDocumentRepository: ReceiptDocumentRepository {
    enum Behavior {
        case success(Data)
        case failure(MercadoPagoCheckoutError)
        case suspended(Data)
    }

    private(set) var requestedURLs: [URL] = []

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

    func fetchPDF(from url: URL) async throws -> Data {
        self.requestedURLs.append(url)
        self.startedContinuation.yield()

        switch self.behavior {
        case let .success(data):
            return data
        case let .failure(error):
            throw error
        case let .suspended(data):
            await self.waitForResume()
            return data
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
        await withCheckedContinuation { self.resumeContinuation = $0 }
    }
}

extension Error {
    /// The `receipt_reason` a receipt failure carries in `MercadoPagoCheckoutError.errorUserInfo`.
    var receiptReason: String? {
        (self as? MercadoPagoCheckoutError)?.errorUserInfo["receipt_reason"] as? String
    }
}
