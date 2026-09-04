//
//  SecurityCodeViewModel.swift
//  MercadoPagoSDK
//

import MPAnalytics
import MPComponents
import MPCore
import SwiftUI

@MainActor
final class SecurityCodeViewModel: ObservableObject {
    /// Configuration for the security code screen.
    struct Configuration {
        let screenOutput: SecurityCodeScreenOutput
        let item: PaymentInitializationOutput.Item
        let footer: PaymentInitializationOutput.Footer
    }

    // MARK: - Published State

    @Published private(set) var isTokenizing = false

    // MARK: - Dependencies

    private let config: Configuration
    private let securityCodeUseCase: SecurityCodeUseCase
    private let analytics: AnalyticsInterface
    private var analyticsTask: Task<Void, Never>?

    // MARK: - Computed

    var screenOutput: SecurityCodeScreenOutput { self.config.screenOutput }

    /// Total label and amount come from the BFF footer — `MPOrder` carries no amount.
    var totalLabel: String { self.config.footer.totalLabel }
    var amount: MPAmountData { MPAmountData(fromFormatted: self.config.footer.totalAmount) }

    /// Limits input to digits only, capped at the CVV length defined by the BFF.
    var securityCodeFormatter: SecurityCodeFormatter {
        SecurityCodeFormatter(maxLength: self.config.screenOutput.length)
    }

    // MARK: MPListItem Informations

    var cardTitle: String { self.config.item.title }

    var cardDescription: String? { self.config.item.description }

    var cardIcon: PaymentInitializationOutput.Item.Icon { self.config.item.icon }

    // MARK: - Init

    init(
        config: Configuration,
        securityCodeUseCase: SecurityCodeUseCase = SecurityCodeUseCase(),
        analytics: AnalyticsInterface = CoreDependencyContainer.shared.analytics
    ) {
        self.config = config
        self.securityCodeUseCase = securityCodeUseCase
        self.analytics = analytics
    }

    // MARK: - Tokenization

    func submit(code: String) async throws(MercadoPagoCheckoutError) -> String {
        self.isTokenizing = true
        defer { self.isTokenizing = false }

        do {
            let cardToken = try await securityCodeUseCase.execute(
                code: code,
                expectedLength: self.config.screenOutput.length,
                cardId: self.config.item.id
            )
            self.trackSubmit()

            return cardToken.token
        } catch {
            self.trackSubmitError(error)
            throw error
        }
    }

    // MARK: - Navigation

    func goBack() {
        self.trackCanceledError(errorType: "back_pressed")
    }
}

// MARK: - Analytics

extension SecurityCodeViewModel {
    func trackInitialize() {
        guard let cardData = self.config.item.cardData else { return }
        let eventData = SecurityCodeInitializeEventData(
            paymentMethodId: cardData.paymentMethodId,
            paymentTypeId: cardData.paymentTypeId,
            issuerId: cardData.issuerId,
            cardId: self.config.item.id
        )
        self.enqueueAnalytics { [analytics = self.analytics] in
            await analytics.trackView(SecurityCodeAnalyticsPath.initialize)
                .setEventData(eventData)
                .send()
        }
    }

    private func trackSubmit() {
        self.enqueueAnalytics { [analytics = self.analytics] in
            await analytics.trackEvent(SecurityCodeAnalyticsPath.submit).send()
        }
    }

    private func trackSubmitError(_ error: MercadoPagoCheckoutError) {
        self.enqueueAnalytics { [analytics = self.analytics] in
            await analytics.trackEvent(SecurityCodeAnalyticsPath.submitError)
                .setError(error.analyticsErrorType)
                .send()
        }
    }

    func trackCanceledError(errorType: String) {
        self.enqueueAnalytics { [analytics = self.analytics] in
            await analytics.trackEvent(SecurityCodeAnalyticsPath.userCanceledError)
                .setError(errorType)
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
