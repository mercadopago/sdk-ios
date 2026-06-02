//
//  OrderTransactionUseCase.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 01/06/26.
//

import MPCore

struct OrderTransactionUseCase {
    private let repository: RemoteOrderTransactionRepository

    init(repository: RemoteOrderTransactionRepository = RemoteOrderTransactionRepository()) {
        self.repository = repository
    }

    func execute(
        orderId: String,
        params: OrderTransactionParams
    ) async throws(MercadoPagoCheckoutError) -> OrderTransactionProcessData {
        do {
            return try await repository.processOrder(orderId: orderId, params: params)
        } catch let error as MercadoPagoCheckoutError {
            throw error
        } catch let error as APIClientError {
            throw MercadoPagoCheckoutError(from: error, location: .tokenization)
        } catch {
            throw MercadoPagoCheckoutError(code: .unknown, localizedDescription: error.localizedDescription, location: .tokenization)
        }
    }
}
