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

    var quotas: [CardPaymentBrickCardData.Installment.Quota] {
        self.installmentsData.installment.quotas
    }

    // MARK: - Footer

    func selectedTotalAmount(_ selected: CardPaymentBrickCardData.Installment.Quota?) -> MPAmountData {
        let value = selected?.totalAmount ?? self.quotas.first?.totalAmount ?? 0
        return MPAmountData(from: value)
    }

    func color(for quota: CardPaymentBrickCardData.Installment.Quota) -> TextStyleColorType? {
        quota.state == .success ? .feedbackPositive : nil
    }

    func footerDescription() -> String {
        let info = self.installmentsData.cardDisplayInfo
        let issuerName = MPFormatIssuerName.applyCapitalizationRules(
            MPFormatIssuerName.cleanIssuerName(info.issuerName ?? String())
        )
//        let paymentTypeLabel = MPFormatIssuerName.formattedPaymentType(info.paymentTypeId ?? String())
        return "\(issuerName) **** \(info.lastFourDigits)"
    }
}
