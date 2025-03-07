//
//  PaymentMethodMapper.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 07/03/25.
//
import Foundation

protocol PaymentMethodMapperProtocol: Sendable {
    func map(responses: [PaymentMethodResponse]) -> [PaymentMethod]
}

struct PaymentMethodMapper: PaymentMethodMapperProtocol {
    private let dateFormatter: DateFormatter

    init() {
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    }

    func map(responses: [PaymentMethodResponse]) -> [PaymentMethod] {
        return responses.map { self.map(response: $0) }
    }

    func map(response: PaymentMethodResponse) -> PaymentMethod {
        return PaymentMethod(
            id: response.id,
            paymentTypeId: response.paymentTypeId,
            status: response.status,
            processingMode: response.processingMode,
            accreditationTime: response.accreditationTime,
            merchantAccountId: response.merchantAccountId,
            siteId: response.siteId,
            thumbnail: response.thumbnail,
            minAccreditationDays: response.minAccreditationDays,
            maxAccreditationDays: response.maxAccreditationDays,
            totalFinancialCost: response.totalFinancialCost,
            financialInstitution: response.financialInstitutions?.map { self.mapFinancialInstitution($0)
            },
            issuer: response.issuer.map { self.mapIssuer($0) },
            card: response.card.map { self.mapCardInfo($0) },
            bins: response.bins,
            marketplace: response.marketplace,
            deferredCapture: response.deferredCapture,
            agreements: response.agreements?.map { self.mapAgreement($0) },
            payerCosts: response.payerCosts?.map { self.mapPayerCost($0) },
            labels: response.labels,
            additionalInfoNeeded: response.additionalInfoNeeded
        )
    }

    private func mapFinancialInstitution(
        _ financialInstitution: PaymentMethodResponse.FinancialInstitutionResponse
    ) -> PaymentMethod.FinancialInstitution {
        return PaymentMethod.FinancialInstitution(
            id: financialInstitution.id,
            description: financialInstitution.description
        )
    }

    private func mapIssuer(
        _ issuer: PaymentMethodResponse.IssuerResponse
    ) -> PaymentMethod.Issuer {
        return PaymentMethod.Issuer(
            id: issuer.id,
            isDefault: issuer.isDefault,
            thumbnail: issuer.thumbnail
        )
    }

    private func mapCardInfo(
        _ cardInfo: PaymentMethodResponse.CardInfoResponse
    ) -> PaymentMethod.CardInfo {
        return PaymentMethod.CardInfo(
            bin: cardInfo.bin,
            length: self.mapCardLength(cardInfo.length),
            validation: cardInfo.validation,
            securityCode: self.mapSecurityCode(cardInfo.securityCode)
        )
    }

    private func mapCardLength(
        _ cardLength: PaymentMethodResponse.CardInfoResponse.CardLengthResponse
    ) -> PaymentMethod.CardInfo.CardLength {
        return PaymentMethod.CardInfo.CardLength(
            min: cardLength.min,
            max: cardLength.max
        )
    }

    private func mapSecurityCode(
        _ securityCode: PaymentMethodResponse.CardInfoResponse.SecurityCodeResponse
    ) -> PaymentMethod.CardInfo.SecurityCode {
        return PaymentMethod.CardInfo.SecurityCode(
            mode: securityCode.mode,
            location: securityCode.location,
            length: securityCode.length
        )
    }

    private func mapPayerCost(
        _ payerCost: PaymentMethodResponse.PayerCostResponse
    ) -> PaymentMethod.PayerCost {
        return PaymentMethod.PayerCost(
            installments: payerCost.installments,
            installmentRate: payerCost.installmentRate,
            discountRate: payerCost.discountRate,
            reimbursementRate: payerCost.reimbursementRate,
            minAllowedAmount: payerCost.minAllowedAmount,
            maxAllowedAmount: payerCost.maxAllowedAmount,
            paymentMethodOptionId: payerCost.paymentMethodOptionId,
            labels: payerCost.labels
        )
    }

    private func mapAgreement(
        _ agreement: PaymentMethodResponse.AgreementResponse
    ) -> PaymentMethod.Agreement {
        return PaymentMethod.Agreement(
            timeFrame: self.mapTimeFrame(agreement.timeFrame),
            merchantAccounts: agreement.merchantAccounts.map { self.mapMerchantAccount($0) }
        )
    }

    private func mapTimeFrame(
        _ timeFrame: PaymentMethodResponse.AgreementResponse.TimeFrameResponse
    ) -> PaymentMethod.Agreement.TimeFrame {
        let startDate = self.dateFormatter.date(from: timeFrame.startDate) ?? Date()
        let endDate = self.dateFormatter.date(from: timeFrame.endDate) ?? Date()

        return PaymentMethod.Agreement.TimeFrame(
            startDate: startDate,
            endDate: endDate
        )
    }

    private func mapMerchantAccount(
        _ merchantAccount: PaymentMethodResponse.AgreementResponse.MerchantAccountResponse
    ) -> PaymentMethod.Agreement.MerchantAccount {
        return PaymentMethod.Agreement.MerchantAccount(
            id: merchantAccount.id,
            paymentMethodOptionId: merchantAccount.paymentMethodOptionId
        )
    }
}
