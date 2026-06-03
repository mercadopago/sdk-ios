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
        case ready(CardFormInitializationOutput, CardFormViewModel)
    }

    private var transactionAmount: Double {
        switch self.configuration.type.kind {
        case .saveCard:
            return .zero
        case let .cardTransaction(order):
            return order.amount
        }
    }

    // MARK: - Published State

    @Published private(set) var screenState: ScreenState = .loading
    @Published private(set) var installmentsWasPresented = false

    // MARK: - Dependencies

    private let configuration: MPCheckoutConfiguration<T>
    private let appearance: MPCheckoutAppearance
    private let initializeUseCase: InitializeCardFormUseCase
    private let orderUseCase: OrderTransactionUseCase
    private let analytics: AnalyticsInterface

    // MARK: - Init

    init(
        configuration: MPCheckoutConfiguration<T>,
        appearance: MPCheckoutAppearance = MPCheckoutAppearance(),
        initializeUseCase: InitializeCardFormUseCase = InitializeCardFormUseCase(),
        orderUseCase: OrderTransactionUseCase = OrderTransactionUseCase(),
        analytics: AnalyticsInterface = CoreDependencyContainer.shared.analytics
    ) {
        self.configuration = configuration
        self.appearance = appearance
        self.initializeUseCase = initializeUseCase
        self.orderUseCase = orderUseCase
        self.analytics = analytics
    }

    func markInstallmentsPresented() {
        self.installmentsWasPresented = true
    }

    // MARK: - Initialization

    func load() async throws(MercadoPagoCheckoutError) {
        guard case .loading = self.screenState else { return }
        do {
            let result = try await withRetry {
                try await self.initializeUseCase.execute(
                    amount: self.transactionAmount,
                    checkoutType: self.configuration.type
                )
            }

            let configuration = CardFormViewModel.Configuration(
                amount: self.transactionAmount,
                checkoutTypeAnalyticsValue: self.configuration.type.analyticsValue,
                excludedPaymentTypeIds: self.configuration.paymentMethod.excludedPaymentTypeIds,
                excludedPaymentMethodIds: self.configuration.paymentMethod.excludedPaymentMethodIds,
                initResult: result,
                minInstallments: self.configuration.paymentMethod.installmentConfig?.minInstallments,
                maxInstallments: self.configuration.paymentMethod.installmentConfig?.maxInstallments
            )

            let viewModel = CardFormViewModel(
                config: configuration,
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
    
    // MARK: - Process Order

    func processOrderTask(_ paymentData: MPPaymentData.CardTransaction) async throws(MercadoPagoCheckoutError) -> MPPaymentData.CardTransaction {
        guard let params = OrderTransactionParams(cardTransaction: paymentData) else {
            assertionFailure("processOrderTask: invalid payment data")
            throw MercadoPagoCheckoutError(code: .unknown, localizedDescription: "invalid payment data", location: .orderProcess)
        }
        let data = try await orderUseCase.execute(orderId: paymentData.orderId, params: params)
        var updatedPaymentData = paymentData
        updatedPaymentData.orderStatus = data.status
        return updatedPaymentData
    }
    
    // MARK: - Payment Data Mapping

    func buildPaymentData(from output: CardFormOutput) -> T? {
        let payer = output.payer.map {
            MPPaymentData.Payer(documentType: $0.documentType, documentNumber: $0.documentNumber)
        }

        switch self.configuration.type.kind {
        case let .cardTransaction(order):
            return MPPaymentData.CardTransaction(
                transactionAmount: order.amount,
                token: output.token,
                installment: 1,
                paymentMethodId: output.paymentMethodId,
                paymentTypeId: output.paymentTypeId,
                issuerId: output.issuerId,
                orderId: order.orderId,
                orderStatus: "",
                payer: payer
            ) as? T

        case .saveCard:
            return MPPaymentData.CardSave(
                token: output.token,
                paymentMethodId: output.paymentMethodId,
                paymentTypeId: output.paymentTypeId,
                issuerId: output.issuerId,
                payer: payer
            ) as? T
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
