//
//  InstallmentScreenViewModel.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 28/01/26.
//

import MPAnalytics
import MPComponents
import MPCore
import MPFoundation
import SwiftUI

@MainActor
final class InstallmentsScreenViewModel: ObservableObject {
    @Binding var installmentsData: MPInstallmentsData

    private let checkoutType: String
    private let analytics: AnalyticsInterface
    private let errorObservability: ErrorObservabilityReporting
    private var analyticsTask: Task<Void, Never>?

    init(
        installmentsData: Binding<MPInstallmentsData>,
        checkoutType: String,
        analytics: AnalyticsInterface = CoreDependencyContainer.shared.analytics,
        errorObservability: ErrorObservabilityReporting = CoreDependencyContainer.shared.errorObservability
    ) {
        self._installmentsData = installmentsData
        self.checkoutType = checkoutType
        self.analytics = analytics
        self.errorObservability = errorObservability
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

    // MARK: - Analytics

    func trackInitialize(transactionAmount: Decimal, paymentMethodId: String, orderId: String) {
        let eventData = InstallmentInitializeEventData(
            checkoutType: self.checkoutType,
            paymentMethodId: paymentMethodId,
            paymentType: self.installmentsData.cardDisplayInfo.paymentTypeId,
            selectionType: self.installmentsData.installment.selectionType,
            quotasCount: self.installmentsData.installment.quotas.count,
            transactionAmount: transactionAmount,
            orderId: orderId.isEmpty ? MPAnalytics.dataNotApply : orderId
        )
        let analytics = self.analytics
        Task(priority: .low) {
            await analytics.trackView(InstallmentAnalyticsPath.initialize)
                .setEventData(eventData)
                .send()
        }
    }

    func trackSelected(_ quota: CardPaymentBrickCardData.Installment.Quota) {
        let eventData = InstallmentSelectedEventData(installments: quota.installments)
        self.enqueueAnalytics { [analytics = self.analytics] in
            await analytics.trackEvent(InstallmentAnalyticsPath.selected)
                .setEventData(eventData)
                .send()
        }
    }

    func trackSubmit(_ quota: CardPaymentBrickCardData.Installment.Quota?) {
        guard let quota else { return }
        let eventData = InstallmentSubmitEventData(
            installments: quota.installments,
            installmentAmount: quota.installmentAmount,
            totalAmount: quota.totalAmount
        )
        self.enqueueAnalytics { [analytics = self.analytics] in
            await analytics.trackEvent(InstallmentAnalyticsPath.submit)
                .setEventData(eventData)
                .send()
        }
    }

    func trackCanceledError(errorType: String) {
        let eventData = InstallmentCanceledErrorEventData(errorType: errorType)
        self.enqueueAnalytics { [analytics = self.analytics] in
            await analytics.trackEvent(InstallmentAnalyticsPath.userCanceledError)
                .setEventData(eventData)
                .send()
        }
    }

    private func enqueueAnalytics(_ block: @escaping @Sendable () async -> Void) {
        let previous = self.analyticsTask
        self.analyticsTask = Task {
            await previous?.value
            await block()
        }
    }
}
