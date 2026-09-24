//
//  StatusScreenViewModel.swift
//  MercadoPagoSDK
//

import SwiftUI

@MainActor
final class StatusScreenViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case ready(StatusScreenOutput)
        case unavailable
    }

    struct SharedReceipt: Identifiable, Equatable {
        let url: URL
        var id: URL { self.url }
    }

    enum ReceiptState: Equatable {
        case idle
        case preparing
        case sharing(SharedReceipt)
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var receiptState: ReceiptState = .idle

    var isPreparingReceipt: Bool { self.receiptState == .preparing }

    var sharedReceipt: SharedReceipt? {
        guard case let .sharing(receipt) = self.receiptState else { return nil }
        return receipt
    }

    private let orderID: String
    private let clientToken: String
    private let lastFourDigits: String?
    private let sellerInfo: MPSellerInfo?
    private let paymentTypeId: String?
    private let useCase: any StatusScreenUseCaseProtocol
    private let receiptUseCase: GenerateReceiptDocumentUseCase
    private var receiptTask: Task<Void, Never>?

    init(
        orderID: String,
        clientToken: String,
        lastFourDigits: String?,
        sellerInfo: MPSellerInfo?,
        paymentTypeId: String?,
        useCase: any StatusScreenUseCaseProtocol = StatusScreenUseCase(),
        receiptUseCase: GenerateReceiptDocumentUseCase = GenerateReceiptDocumentUseCase()
    ) {
        self.orderID = orderID
        self.clientToken = clientToken
        self.lastFourDigits = lastFourDigits
        self.sellerInfo = sellerInfo
        self.paymentTypeId = paymentTypeId
        self.useCase = useCase
        self.receiptUseCase = receiptUseCase
    }

    func load() async {
        guard self.state == .idle else { return }
        self.state = .loading

        do {
            let output = try await self.useCase.execute(
                orderID: self.orderID,
                clientToken: self.clientToken,
                lastFourDigits: self.lastFourDigits,
                sellerInfo: self.sellerInfo
            )
            try Task.checkCancellation()
            guard self.state == .loading else { return }
            self.state = .ready(output)
        } catch is CancellationError {
            guard self.state == .loading else { return }
            self.state = .idle
        } catch {
            guard self.state == .loading else { return }
            self.state = Task.isCancelled ? .idle : .unavailable
        }
    }

    func prepareReceipt(from remoteURL: URL) {
        guard self.receiptState == .idle else { return }
        self.receiptState = .preparing
        self.receiptTask = Task {
            let localURL = try? await self.receiptUseCase.execute(
                from: remoteURL,
                paymentTypeId: self.paymentTypeId
            )
            guard !Task.isCancelled else {
                if let localURL { Self.removeFile(at: localURL) }
                return
            }
            self.receiptTask = nil
            self.receiptState = localURL.map { .sharing(SharedReceipt(url: $0)) } ?? .idle
        }
    }

    /// Deletes the temporary PDF once the share sheet is done with it.
    func finishSharing() {
        if let receipt = self.sharedReceipt { Self.removeFile(at: receipt.url) }
        self.receiptState = .idle
    }

    /// Cancels an in-flight PDF generation. A receipt already being shared is left to `finishSharing()`.
    func cancelReceipt() {
        guard self.receiptState == .preparing else { return }
        self.receiptTask?.cancel()
        self.receiptTask = nil
        self.receiptState = .idle
    }

    private static func removeFile(at url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
}
