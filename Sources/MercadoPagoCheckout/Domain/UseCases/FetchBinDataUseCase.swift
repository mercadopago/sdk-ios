//
//  FetchBinDataUseCase.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 26/02/26.
//
import CoreMethods

struct FetchBinDataUseCase {
    private let service: CheckoutServiceProtocol

    init(service: CheckoutServiceProtocol) {
        self.service = service
    }

    func execute(
        bin: String,
        amount: Double?,
        acceptedPaymentTypeIds: [String],
        acceptedPaymentMethodIds: [String]
    ) async throws -> CardBinData {
        let methods = try await service.paymentMethod(bin: bin)
        guard let method = methods.first(where: {
            let matchesType = acceptedPaymentTypeIds.contains($0.paymentTypeId)
            let matchesBrand = acceptedPaymentMethodIds.isEmpty || acceptedPaymentMethodIds.contains($0.id)
            return matchesType && matchesBrand
        }) else {
            if let typeMatchedMethod = methods.first(where: {
                acceptedPaymentTypeIds.contains($0.paymentTypeId) &&
                !acceptedPaymentMethodIds.contains($0.id)
            }) {
                throw BinFetchError.paymentMethodNotAllowed(typeMatchedMethod.id)
            } else {
                let detectedMethod = methods.first(where: { !acceptedPaymentTypeIds.contains($0.paymentTypeId) })
                let detectedCardType = MercadoPagoCheckout.CardType(paymentTypeId: detectedMethod?.paymentTypeId)
                throw BinFetchError.paymentTypeNotAllowed(detectedCardType)
            }
        }

        var fetchedIssuer: Issuer?
        if method.additionalInfoNeeded?.contains("issuer_id") == true {
            fetchedIssuer = try await service.issuers(bin: bin, paymentMethodID: method.id).first
        }

        var fetchedInstallment: Installment?
        if let amount {
            let installments = try await service.installments(amount: amount, bin: bin)
            if let fetchedIssuer {
                fetchedInstallment = installments.first(where: { $0.issuer.id == fetchedIssuer.id })
            } else {
                fetchedInstallment = installments.first
            }
        }

        return CardBinData(
            paymentMethod: method,
            issuer: fetchedIssuer,
            installment: fetchedInstallment
        )
    }
}

// MARK: - Private

package enum BinFetchError: Error, Equatable {
    case paymentMethodNotAllowed(String)
    case paymentTypeNotAllowed(MercadoPagoCheckout.CardType?)
}
