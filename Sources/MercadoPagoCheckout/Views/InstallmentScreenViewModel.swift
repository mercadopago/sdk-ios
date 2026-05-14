//
//  InstallmentScreenViewModel.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 28/01/26.
//

import MPComponents
import MPFoundation
import SwiftUI

final class InstallmentsScreenViewModel: ObservableObject {
    @Binding var installmentsData: MPInstallmentsData

    init(installmentsData: Binding<MPInstallmentsData>) {
        self._installmentsData = installmentsData
    }

    // MARK: - Computed Properties

    var headerTitle: String {
        self.installmentsData.installment.translations.headerTitle
    }

    var totalLabel: String {
        self.installmentsData.installment.translations.totalLabel
    }

    var payButtonLabel: String {
        self.installmentsData.installment.translations.payButtonLabel
    }

    var quotas: [CardPaymentBrickCardData.Installment.Quota] {
        self.installmentsData.installment.quotas
    }

    // MARK: - Footer

    func selectedTotalAmount(_ selected: CardPaymentBrickCardData.Installment.Quota?) -> MPAmountData {
        let value = selected?.totalAmount ?? self.quotas.first?.totalAmount ?? 0
        return MPAmountData(from: value, currencySymbol: self.installmentsData.installment.translations.currencySymbol)
    }

    func color(for quota: CardPaymentBrickCardData.Installment.Quota) -> TextStyleColorType? {
        quota.state == .success ? .feedbackPositive : nil
    }

    func primaryLabelComponents(_ label: String) -> (title: String, decimalSuffix: String?) {
        guard
            let commaIndex = label.lastIndex(of: ","),
            label.distance(from: commaIndex, to: label.endIndex) == 3
        else { return (label, nil) }

        let decimalPart = label[label.index(after: commaIndex)...]
        return (String(label[..<commaIndex]), String(decimalPart))
    }

    func contentInfo(for quota: CardPaymentBrickCardData.Installment.Quota) -> MPListItemContentInfo {
        let components = self.primaryLabelComponents(quota.primaryLabel)
        return .init(
            title: components.title,
            titleDecimalSuffix: components.decimalSuffix,
            description: quota.tertiaryLabel
        )
    }

    func footerDescription() -> String {
        let info = self.installmentsData.cardDisplayInfo
        let issuerName = MPFormatIssuerName.applyCapitalizationRules(
            MPFormatIssuerName.cleanIssuerName(info.issuerName ?? String())
        )
        return "\(issuerName) **** \(info.lastFourDigits)"
    }
}
