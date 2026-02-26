//
//  FetchBinDataUseCase.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 26/02/26.
//
import CoreMethods

struct FetchBinDataUseCase {
    private let service: BinFetchingProtocol

    init(service: BinFetchingProtocol) {
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
            throw BinFetchError.paymentMethodNotFound
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

private enum BinFetchError: Error {
    case paymentMethodNotFound
}
