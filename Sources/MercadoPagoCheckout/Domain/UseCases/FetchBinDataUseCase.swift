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
        var methods: [PaymentMethod] = try await getPaymentMethods(from: bin)

        let method = try filterPaymentMethod(
            methods,
            acceptedPaymentTypeIds: acceptedPaymentTypeIds,
            acceptedPaymentMethodIds: acceptedPaymentMethodIds
        )

        async let issuersTask = self.filterIssuer(method, bin: bin)
        async let installmentsTask = self.filterInstallmentsRaw(amount: amount, bin: bin)

        let fetchedIssuer = try await issuersTask
        let allInstallments = try await installmentsTask
        let fetchedInstallment = self.pickInstallment(from: allInstallments, issuer: fetchedIssuer)

        return CardBinData(
            paymentMethod: method,
            issuer: fetchedIssuer,
            installment: fetchedInstallment
        )
    }

    private func getPaymentMethods(from bin: String) async throws -> [PaymentMethod] {
        try await self.service.paymentMethod(bin: bin)
    }

    private func filterPaymentMethod(
        _ methods: [PaymentMethod],
        acceptedPaymentTypeIds: [String],
        acceptedPaymentMethodIds: [String]
    ) throws -> PaymentMethod {
        guard let method = methods.first(where: {
            let matchesType = acceptedPaymentTypeIds.contains($0.paymentTypeId)
            let matchesBrand = acceptedPaymentMethodIds.isEmpty || acceptedPaymentMethodIds.contains($0.id)
            return matchesType && matchesBrand
        }) else {
            if let typeMatchedMethod = methods.first(where: {
                acceptedPaymentTypeIds.contains($0.paymentTypeId) &&
                    !acceptedPaymentMethodIds.contains($0.id)
            }) {
                throw CardAcceptanceError.paymentMethodNotAllowed(typeMatchedMethod.id)
            } else {
                let detectedMethod = methods.first(where: { !acceptedPaymentTypeIds.contains($0.paymentTypeId) })
                let detectedCardType = MercadoPagoCheckout.CardType(paymentTypeId: detectedMethod?.paymentTypeId)
                // To be removed
                throw CardAcceptanceError.paymentTypeNotAllowed("")
            }
        }
        return method
    }

    private func filterIssuer(
        _ method: PaymentMethod,
        bin: String
    ) async throws -> Issuer? {
        guard method.additionalInfoNeeded?.contains("issuer_id") == true else { return nil }
        return try await self.service.issuers(bin: bin, paymentMethodID: method.id).first
    }

    private func filterInstallmentsRaw(amount: Double?, bin: String) async throws -> [Installment] {
        guard let amount else { return [] }
        return try await self.service.installments(amount: amount, bin: bin)
    }

    private func pickInstallment(from installments: [Installment], issuer: Issuer?) -> Installment? {
        if let issuer {
            return installments.first(where: { $0.issuer.id == issuer.id })
        }
        return installments.first
    }
}
