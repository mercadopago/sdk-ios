//
//  InstallmentViewViewModel.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 28/01/26.
//

import CoreMethods
import MPComponents
import MPFoundation
import SwiftUI

final class InstallmentsScreenViewModel: ObservableObject {
    
    private(set) var payerCosts: [Installment.PayerCost] = []
    private let installment: Installment?
    
    init(installments: Installment) {
        self.installment = installments
        self.payerCosts = installment?.payerCosts ?? []
    }
    
    // MARK: - Formatted strings
    
    func formatInstallmentLabel(for payerCost: Installment.PayerCost) -> String {
        "\(payerCost.installments)x \(MPStrings.formatPrice(payerCost.installmentAmount))"
    }

    func formatInterestLabel(for payerCost: Installment.PayerCost) -> String {
        if payerCost.installments == 1 {
            return String()
        } else {
            return  payerCost.installmentRate == 0 ?
            MPStrings.Installments.interestFree :
            MPStrings.formatPrice(payerCost.totalAmount)
        }
    }
    
    // MARK: - Actions

    func isSelected(_ payerCost: Installment.PayerCost, selectedPayerCost: Installment.PayerCost?) -> Bool {
        selectedPayerCost?.id == payerCost.id
    }
    
    // MARK: - Footer
    
    func selectedTotalAmount(_ selected: Installment.PayerCost?) -> String {
        guard
            let selected
        else {
            return "\(MPStrings.formatPrice(payerCosts.first?.installmentAmount ?? 0))"
        }
        
        return "\(MPStrings.formatPrice(selected.totalAmount))"
    }
    
    func formatFooterDescription() -> String {
        guard
            let issuerName = installment?.issuer.name,
            let type = installment?.paymentTypeId
        else {
            return String()
        }

        return getSavedCardName(
            issuerName: issuerName,
            paymentTypeLabel: MPFormatIssuerName.formattedPaymentType(type),
            lastDigits:  "1234"
        )
    }
    
    func getSavedCardName(
        issuerName: String,
        paymentTypeLabel: String,
        lastDigits: String,
        isMercadoPagoCard: Bool = false
    ) -> String {
        let normalizedIssuerName = MPFormatIssuerName.applyCapitalizationRules(
            MPFormatIssuerName.cleanIssuerName(issuerName)
        )
        
        if isMercadoPagoCard {
            return "\(normalizedIssuerName) \(paymentTypeLabel)"
        }
        
        return "\(normalizedIssuerName) \(paymentTypeLabel) **** \(lastDigits)"
    }
}
