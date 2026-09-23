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

    @Published private(set) var state: State = .idle

    private let orderID: String
    private let clientToken: String
    private let lastFourDigits: String?
    private let sellerInfo: MPSellerInfo?
    private let useCase: any StatusScreenUseCaseProtocol

    init(
        orderID: String,
        clientToken: String,
        lastFourDigits: String?,
        sellerInfo: MPSellerInfo?,
        useCase: any StatusScreenUseCaseProtocol = StatusScreenUseCase()
    ) {
        self.orderID = orderID
        self.clientToken = clientToken
        self.lastFourDigits = lastFourDigits
        self.sellerInfo = sellerInfo
        self.useCase = useCase
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
}
