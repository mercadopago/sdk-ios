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
final class CardFormBrickViewModel<T: MPPaymentData.Kind>: ObservableObject {
    enum ScreenState {
        case loading
        case ready(CardFormInitializationOutput, CardFormViewModel<T>)
    }

    // MARK: - Published State

    @Published private(set) var screenState: ScreenState = .loading

    // MARK: - Dependencies

    private let configuration: MPCheckoutConfiguration<T>
    private let appearance: MPCheckoutAppearance
    private let initializeUseCase: InitializeCardFormUseCase
    private let analytics: AnalyticsInterface

    // MARK: - Init

    init(
        configuration: MPCheckoutConfiguration<T>,
        appearance: MPCheckoutAppearance = MPCheckoutAppearance(),
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
        do {
            let result = try await withRetry {
                try await self.initializeUseCase.execute(
                    checkoutType: self.configuration.type
                )
            }
            let viewModel = CardFormViewModel<T>(
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

    // MARK: - Analytics

    private func trackInitialize() {
        let eventData = CardFormInitializeEventData(
            checkoutType: self.configuration.type.analyticsValue,
            appearance: self.appearance.style.analyticsValue,
            sellerCustomization: self.appearance.sellerCustomization,
            excludedPaymentTypes: self.configuration.paymentMethod.excludedPaymentTypeIds,
            excludedPaymentMethods: self.configuration.paymentMethod.excludedPaymentMethodIds
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
