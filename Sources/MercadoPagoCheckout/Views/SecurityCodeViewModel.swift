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
        let transactionAmount: Decimal
    }

    // MARK: - Published State

    @Published private(set) var isTokenizing = false

    // MARK: - Dependencies

    private let config: Configuration
    private let securityCodeUseCase: SecurityCodeUseCase
    private let analytics: AnalyticsInterface

    // MARK: - Computed

    var screenOutput: SecurityCodeScreenOutput { self.config.screenOutput }
    var amount: MPAmountData { MPAmountData(from: self.config.transactionAmount) }

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

        let cardToken = try await securityCodeUseCase.execute(
            code: code,
            expectedLength: self.config.screenOutput.length,
            cardId: self.config.item.id
        )
        self.trackSubmit()

        return cardToken.token
    }

    // MARK: - Navigation

    func goBack() {
        self.trackCanceledError(errorType: "back_pressed")
    }
}

// MARK: - Analytics

// TODO: define SecurityCodeAnalyticsPath and event data.
extension SecurityCodeViewModel {
    func trackInitialize() {
        // TODO: SecurityCodeAnalyticsPath.initialize
    }

    private func trackSubmit() {
        // TODO: SecurityCodeAnalyticsPath.submit
    }

    private func trackSubmitError(_: MercadoPagoCheckoutError) {
        // TODO: SecurityCodeAnalyticsPath.submitError
    }

    func trackCanceledError(errorType _: String) {
        // TODO: SecurityCodeAnalyticsPath.userCanceledError
    }
}
