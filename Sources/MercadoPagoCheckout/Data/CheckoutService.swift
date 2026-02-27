//
//  CheckoutService.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 23/02/26.
//
import CoreMethods

struct CheckoutService: CheckoutServiceProtocol {
    private let coreMethods: CoreMethods

    init(coreMethods: CoreMethods = CoreMethods()) {
        self.coreMethods = coreMethods
    }

    func identificationTypes() async throws -> [IdentificationType] {
        try await coreMethods.identificationTypes()
    }

    func paymentMethod(bin: String) async throws -> [PaymentMethod] {
        try await coreMethods.paymentMethods(bin: bin)
    }

    func issuers(bin: String, paymentMethodID: String) async throws -> [Issuer] {
        try await coreMethods.issuers(bin: bin, paymentMethodID: paymentMethodID)
    }

    func installments(amount: Double, bin: String) async throws -> [Installment] {
        try await coreMethods.installments(amount: amount, bin: bin)
    }

    func createCardToken(cardParams: CardParams) async throws -> CardToken {
        try await coreMethods.createToken(cardParams)
    }

    func fetchBinData(
        bin: String,
        amount: Double?,
        acceptedPaymentTypeIds: [String],
        acceptedPaymentMethodIds: [String]
    ) async throws -> CardBinData {
        try await FetchBinDataUseCase(service: self).execute(
            bin: bin,
            amount: amount,
            acceptedPaymentTypeIds: acceptedPaymentTypeIds,
            acceptedPaymentMethodIds: acceptedPaymentMethodIds
        )
    }
}
