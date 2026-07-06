//
//  SecurityCodeViewModel.swift
//  MercadoPagoSDK
//

import MPAnalytics
import MPCore
import SwiftUI

@MainActor
final class SecurityCodeViewModel: ObservableObject {
    struct Configuration {
        let screenOutput: SecurityCodeScreenOutput

        let expectedLength: Int

        let cardId: String
    }

    // MARK: - Published State

    @Published private(set) var isTokenizing = false

    // MARK: - Dependencies

    private let config: Configuration
    private let securityCodeUseCase: SecurityCodeUseCase
    private let analytics: AnalyticsInterface

    // MARK: - Computed

    var screenOutput: SecurityCodeScreenOutput { self.config.screenOutput }
    var expectedLength: Int { self.config.expectedLength }

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
            expectedLength: self.config.expectedLength,
            cardId: self.config.cardId
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
