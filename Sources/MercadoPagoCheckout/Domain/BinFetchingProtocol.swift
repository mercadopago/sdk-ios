//
//  BinFetchingProtocol.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 24/02/26.
//
import CoreMethods

protocol BinFetchingProtocol: Sendable {
    func paymentMethod(bin: String) async throws -> [PaymentMethod]
    func issuers(bin: String, paymentMethodID: String) async throws -> [Issuer]
    func installments(amount: Double, bin: String) async throws -> [Installment]
}
