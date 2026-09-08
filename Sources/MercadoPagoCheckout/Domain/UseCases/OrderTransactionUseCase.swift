//
//  OrderTransactionUseCase.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 01/06/26.
//

import MPCore

struct OrderTransactionUseCase {
    private let repository: OrderTransactionRepository

    init(repository: OrderTransactionRepository = RemoteOrderTransactionRepository()) {
        self.repository = repository
    }

    func execute(
        orderId: String,
        clientToken: String,
        params: OrderTransactionParams
    ) async throws(ObservedCheckoutError) -> OrderTransactionProcessData {
        do {
            return try await self.repository.processOrder(orderId: orderId, clientToken: clientToken, params: params)
        } catch {
            throw ObservedCheckoutErrorFactory.make(from: error, location: .orderProcess)
        }
    }
}
