//
//  CheckoutServiceProtocol.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 23/02/26.
//
import CoreMethods

protocol CheckoutServiceProtocol: Sendable {
    func identificationTypes() async throws -> [IdentificationType]
    func paymentMethod(bin: String) async throws -> [PaymentMethod]
    func issuers(bin: String, paymentMethodID: String) async throws -> [Issuer]
    func installments(amount: Double, bin: String) async throws -> [Installment]
    func createCardToken(cardParams: CardParams) async throws -> CardToken
    func fetchBinData(
        bin: String,
        amount: Double?,
        acceptedPaymentTypeIds: [String],
        acceptedPaymentMethodIds: [String]
    ) async throws -> CardBinData
}
