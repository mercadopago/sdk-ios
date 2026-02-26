//
//  CheckoutServiceProtocol.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 23/02/26.
//
import CoreMethods

protocol CheckoutServiceProtocol: Sendable {
    func identificationTypes() async throws -> [IdentificationType]
    func fetchBinData(bin: String, amount: Double?, acceptedPaymentTypeIds: [String], acceptedPaymentMethodIds: [String]) async throws -> CardBinData
}
