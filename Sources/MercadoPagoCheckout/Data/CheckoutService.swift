//
//  CheckoutService.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 23/02/26.
//
import CoreMethods

struct CheckoutService: CheckoutServiceProtocol, BinFetchingProtocol {
    private let coreMethods: CoreMethods

    init(coreMethods: CoreMethods = CoreMethods()) {
        self.coreMethods = coreMethods
    }

    func identificationTypes() async throws -> [IdentificationType] {
        try await coreMethods.identificationTypes()
    }

    // MARK: - BinFetchingProtocol

    func paymentMethod(bin: String) async throws -> [PaymentMethod] {
        try await coreMethods.paymentMethods(bin: bin)
    }

    func issuers(bin: String, paymentMethodID: String) async throws -> [Issuer] {
        try await coreMethods.issuers(bin: bin, paymentMethodID: paymentMethodID)
    }

    func installments(amount: Double, bin: String) async throws -> [Installment] {
        try await coreMethods.installments(amount: amount, bin: bin)
    }

    // MARK: - CheckoutServiceProtocol

    func fetchBinData(bin: String, amount: Double?, acceptedPaymentTypeIds: [String]) async throws -> CardBinData {
        let methods = try await paymentMethod(bin: bin)
        guard let method = methods.first(where: { acceptedPaymentTypeIds.contains($0.paymentTypeId) }) ?? methods.first else {
            throw BinFetchError.paymentMethodNotFound
        }

        var fetchedIssuer: Issuer?
        if method.additionalInfoNeeded?.contains("issuer_id") == true {
            fetchedIssuer = try await issuers(bin: bin, paymentMethodID: method.id).first
        }

        var fetchedInstallment: Installment?
        if let amount {
            fetchedInstallment = try await installments(amount: amount, bin: bin).first
        }

        return CardBinData(
            paymentMethod: method,
            issuer: fetchedIssuer,
            installment: fetchedInstallment
        )
    }
}

// MARK: - Private

private enum BinFetchError: Error {
    case paymentMethodNotFound
}
