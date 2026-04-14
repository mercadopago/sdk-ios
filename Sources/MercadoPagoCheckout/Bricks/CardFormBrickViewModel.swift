//
//  CardFormBrickViewModel.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 18/03/26.
//
import Foundation
import MPAnalytics
import MPCore
import MPFoundation

@MainActor
final class CardFormBrickViewModel: ObservableObject {
    enum ScreenState {
        case loading
        case ready(CardFormInitializationOutput, CardFormViewModel)
    }

    // MARK: - Published State

    @Published private(set) var screenState: ScreenState = .loading

    // MARK: - Dependencies

    private let configuration: MercadoPagoCheckout.CheckoutConfiguration
    private let appearance: MercadoPagoCheckout.CheckoutAppearance
    private let initializeUseCase: InitializeCardFormUseCase
    private let analytics: AnalyticsInterface

    // MARK: - Init

    init(
        configuration: MercadoPagoCheckout.CheckoutConfiguration,
        appearance: MercadoPagoCheckout.CheckoutAppearance = MercadoPagoCheckout.CheckoutAppearance(),
        initializeUseCase: InitializeCardFormUseCase = InitializeCardFormUseCase(),
        analytics: AnalyticsInterface = CoreDependencyContainer.shared.analytics
    ) {
        self.configuration = configuration
        self.appearance = appearance
        self.initializeUseCase = initializeUseCase
        self.analytics = analytics
    }

    // MARK: - Initialization

    func load() async throws(MercadoPagoCheckoutError) {
        guard case .loading = self.screenState else { return }
        let config = self.extractCardFormConfig()
        do {
            let result = try await withRetry {
                try await self.initializeUseCase.execute(
                    config: config,
                    checkoutType: self.configuration.type.analyticsValue
                )
            }
            let viewModel = CardFormViewModel(
                configuration: self.configuration,
                initResult: result,
                analytics: self.analytics
            )
            self.screenState = .ready(result, viewModel)
            self.trackInitialize()
        } catch let error as MercadoPagoCheckoutError {
            self.trackInitializeError(error)
            throw error
        } catch {
            let checkoutError = MercadoPagoCheckoutError(
                code: .unknown,
                localizedDescription: error.localizedDescription,
                location: .initialization
            )
            self.trackInitializeError(checkoutError)
            throw checkoutError
        }
    }

    // MARK: - Private

    private func extractCardFormConfig() -> MercadoPagoCheckout.CardFormConfiguration {
        if case let .cardForm(config) = configuration.type {
            return config
        }
        return MercadoPagoCheckout.CardFormConfiguration()
    }

    // MARK: - Analytics

    private func trackInitialize() {
        let eventData = CardFormInitializeEventData(
            checkoutType: self.configuration.type.analyticsValue,
            appearance: self.appearance.style.analyticsValue,
            sellerCustomization: self.appearance.sellerCustomization,
            allowedPaymentTypes: self.configuration.paymentMethod.acceptedPaymentTypeIds,
            allowedPaymentMethods: self.configuration.paymentMethod.acceptedPaymentMethodIds
        )

        let analytics = self.analytics
        Task(priority: .low) {
            await analytics.trackEvent(CardFormAnalyticsPath.initialize)
                .setEventData(eventData)
                .send()
        }
    }

    private func trackInitializeError(_ error: MercadoPagoCheckoutError) {
        let eventData = CardFormErrorEventData(errorType: error.analyticsErrorType)
        let analytics = self.analytics
        Task(priority: .low) {
            await analytics.trackEvent(CardFormAnalyticsPath.initializeError)
                .setEventData(eventData)
                .send()
        }
    }
}
