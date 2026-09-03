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

    private var transactionAmount: Decimal {
        return self.result?.amount ?? .zero
    }

    private var orderId: String? {
        switch self.configuration.type.kind {
        case .saveCard, .payment:
            return nil
        case let .cardTransaction(order):
            return order.orderId
        }
    }

    private var clientToken: String? {
        switch self.configuration.type.kind {
        case .saveCard:
            return nil
        case let .payment(order), let .cardTransaction(order):
            return order.clientToken
        }
    }

    private var order: MPOrder? {
        switch self.configuration.type.kind {
        case .saveCard:
            return nil
        case let .payment(order), let .cardTransaction(order):
            return order
        }
    }

    private var result: CardFormInitializationOutput?

    // MARK: - Published State

    @Published private(set) var screenState: ScreenState = .loading
    @Published private(set) var installmentsWasPresented = false

    // MARK: - Dependencies

    private let configuration: MPCheckoutConfiguration<T>
    private let appearance: MPCheckoutAppearance
    private let initializeUseCase: InitializeCardFormUseCase
    private let orderUseCase: OrderTransactionUseCase
    private let analytics: AnalyticsInterface
    private let errorObservability: ErrorObservabilityReporting

    // MARK: - Init

    init(
        configuration: MPCheckoutConfiguration<T>,
        appearance: MPCheckoutAppearance = MPCheckoutAppearance(),
        initializeUseCase: InitializeCardFormUseCase = InitializeCardFormUseCase(),
        orderUseCase: OrderTransactionUseCase = OrderTransactionUseCase(),
        analytics: AnalyticsInterface = CoreDependencyContainer.shared.analytics,
        errorObservability: ErrorObservabilityReporting = CoreDependencyContainer.shared.errorObservability
    ) {
        self.configuration = configuration
        self.appearance = appearance
        self.initializeUseCase = initializeUseCase
        self.orderUseCase = orderUseCase
        self.analytics = analytics
        self.errorObservability = errorObservability
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
                    order: self.order,
                    checkoutType: self.configuration.type
                )
            }
            self.result = result

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
                analytics: self.analytics,
                errorObservability: self.errorObservability
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
        guard let params = OrderTransactionParams(cardTransaction: paymentData), let clientToken = self.clientToken else {
            assertionFailure("processOrderTask: invalid payment data")
            throw MercadoPagoCheckoutError(code: .unknown, localizedDescription: "invalid payment data", location: .orderProcess)
        }
        do {
            let data = try await orderUseCase.execute(orderId: paymentData.orderId, clientToken: clientToken, params: params)
            var updatedPaymentData = paymentData
            updatedPaymentData.orderStatus = data.status
            self.trackOrderSubmit(updatedPaymentData)
            return updatedPaymentData
        } catch {
            self.trackOrderError(error, orderId: paymentData.orderId)
            throw error
        }
    }

    private func trackOrderSubmit(_ paymentData: MPPaymentData.CardTransaction) {
        let eventData = OrderSubmitEventData(
            orderId: paymentData.orderId,
            orderStatus: paymentData.orderStatus
        )
        let analytics = self.analytics
        Task(priority: .low) {
            await analytics.trackEvent(OrderAnalyticsPath.orderSubmit)
                .setEventData(eventData)
                .send()
        }
    }

    private func trackOrderError(_ error: MercadoPagoCheckoutError, orderId: String) {
        let receipt = self.errorObservability.capture(
            error.classifiedNativeError(operation: .orderSubmission)
        )
        guard receipt.shouldSendMelidata else { return }
        let eventData = OrderErrorEventData(
            errorType: error.analyticsErrorType,
            orderId: orderId
        )
        let analytics = self.analytics
        Task(priority: .low) {
            await analytics.trackEvent(OrderAnalyticsPath.orderError)
                .setEventData(eventData)
                .send(observabilityEventID: receipt.eventID)
        }
    }

    // MARK: - Payment Data Mapping

    func buildPaymentData(from output: CardFormSubmitResult) -> T? {
        let payer = output.payer.map {
            MPPaymentData.Payer(documentType: $0.documentType, documentNumber: $0.documentNumber)
        }

        switch self.configuration.type.kind {
        case let .cardTransaction(order):
            return MPPaymentData.CardTransaction(
                transactionAmount: self.transactionAmount,
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

        case .payment:
            return nil
        }
    }

    // MARK: - Analytics

    private func trackInitialize() {
        let eventData = CardFormInitializeEventData(
            checkoutType: self.configuration.type.analyticsValue,
            appearance: self.appearance.style.analyticsValue,
            sellerCustomization: self.appearance.sellerCustomization,
            excludedPaymentTypes: self.configuration.paymentMethod.excludedPaymentTypeIds,
            excludedPaymentMethods: self.configuration.paymentMethod.excludedPaymentMethodIds,
            orderId: self.orderId ?? MPAnalytics.dataNotApply
        )

        let analytics = self.analytics
        Task(priority: .low) {
            await analytics.trackEvent(CardFormAnalyticsPath.initialize)
                .setEventData(eventData)
                .send()
        }
    }

    private func trackInitializeError(_ error: MercadoPagoCheckoutError) {
        let receipt = self.errorObservability.capture(
            error.classifiedNativeError(operation: .cardFormInitialization)
        )
        guard receipt.shouldSendMelidata else { return }
        let eventData = CardFormErrorEventData(errorType: error.analyticsErrorType)
        let analytics = self.analytics
        Task(priority: .low) {
            await analytics.trackEvent(CardFormAnalyticsPath.initializeError)
                .setEventData(eventData)
                .send(observabilityEventID: receipt.eventID)
        }
    }
}
