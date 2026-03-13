//
//  CheckoutService.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 23/02/26.
//
import CoreMethods
import MPCore

struct CheckoutService: CheckoutServiceProtocol {
    private let coreMethods: CoreMethods

    init(coreMethods: CoreMethods = CoreMethods()) {
        self.coreMethods = coreMethods
    }

    func identificationTypes() async throws(MercadoPagoCheckoutError) -> [IdentificationType] {
        do {
            return try await self.coreMethods.identificationTypes()
        } catch let error as APIClientError {
            throw MercadoPagoCheckoutError(from: error, location: .identification)
        } catch {
            throw MercadoPagoCheckoutError(code: .unknown, _localizedDescription: error.localizedDescription, location: .identification)
        }
    }

    func paymentMethod(bin: String) async throws -> [PaymentMethod] {
        try await self.coreMethods.paymentMethods(bin: bin)
    }

    func issuers(bin: String, paymentMethodID: String) async throws -> [Issuer] {
        try await self.coreMethods.issuers(bin: bin, paymentMethodID: paymentMethodID)
    }

    func installments(amount: Double, bin: String) async throws -> [Installment] {
        try await self.coreMethods.installments(amount: amount, bin: bin)
    }

    func createCardToken(cardParams: CardParams) async throws(MercadoPagoCheckoutError) -> CardToken {
        do {
            return try await self.coreMethods.createToken(cardParams)
        } catch let error as APIClientError {
            throw MercadoPagoCheckoutError(from: error, location: .tokenization)
        } catch {
            throw MercadoPagoCheckoutError(code: .unknown, _localizedDescription: error.localizedDescription, location: .tokenization)
        }
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
