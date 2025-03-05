//
//  InstallmentsMapper.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 05/03/25.
//

protocol InstallmentsMapperProtocol: Sendable {
    func map(responses: [InstallmentsResponse]) -> [Installment]
}

struct InstallmentsMapper: InstallmentsMapperProtocol {
    func map(responses: [InstallmentsResponse]) -> [Installment] {
        return responses.map { self.map(response: $0) }
    }

    func map(response: InstallmentsResponse) -> Installment {
        return Installment(
            paymentMethodId: response.paymentMethodId,
            paymentTypeId: response.paymentTypeId,
            thumbnail: response.thumbnail,
            issuer: self.mapIssuer(response.issuer),
            processingMode: response.processingMode,
            merchantAccountId: response.merchantAccountId,
            payerCosts: response.payerCosts.map { self.mapPayerCost($0) },
            agreements: response.agreements.map { self.mapAgreement($0) }
        )
    }

    private func mapIssuer(_ issuer: InstallmentsResponse.Issuer) -> Installment.Issuer {
        return Installment.Issuer(
            id: issuer.id,
            thumbnail: issuer.thumbnail
        )
    }

    private func mapPayerCost(
        _ payerCost: InstallmentsResponse.PayerCost
    ) -> Installment.PayerCost {
        return Installment.PayerCost(
            installments: payerCost.installments,
            installmentAmount: payerCost.installmentAmount,
            installmentRate: payerCost.installmentRate,
            installmentRateCollector: payerCost.installmentRateCollector,
            totalAmount: payerCost.totalAmount,
            minAllowedAmount: payerCost.minAllowedAmount,
            maxAllowedAmount: payerCost.maxAllowedAmount,
            discountRate: payerCost.discountRate,
            reimbursementRate: payerCost.reimbursementRate,
            labels: payerCost.labels,
            paymentMethodOptionId: payerCost.paymentMethodOptionId
        )
    }

    private func mapAgreement(
        _ agreement: InstallmentsResponse.Agreement
    ) -> Installment.Agreement {
        return Installment.Agreement(
            merchantAccounts: agreement.merchantAccounts.map { self.mapMerchantAccount($0) },
            timeFrame: self.mapTimeFrame(agreement.timeFrame)
        )
    }

    private func mapMerchantAccount(
        _ merchantAccount: InstallmentsResponse.Agreement.MerchantAccount
    ) -> Installment.Agreement.MerchantAccount {
        return Installment.Agreement.MerchantAccount(
            id: merchantAccount.id,
            paymentMethodOptionId: merchantAccount.paymentMethodOptionId
        )
    }

    private func mapTimeFrame(
        _ timeFrame: InstallmentsResponse.Agreement.TimeFrame
    ) -> Installment.Agreement.TimeFrame {
        return Installment.Agreement.TimeFrame(
            startDate: timeFrame.startDate,
            endDate: timeFrame.endDate
        )
    }
}
