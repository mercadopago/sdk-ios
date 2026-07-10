//
//  OrderTransactionRepository.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 01/06/26.
//

protocol OrderTransactionRepository: Sendable {
    func processOrder(orderId: String, clientToken: String, params: OrderTransactionParams) async throws -> OrderTransactionProcessData
}
