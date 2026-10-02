//
//  PaymentBrickViewModel.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 28/05/26.
//

import Foundation
import MPAnalytics
import MPCore
import SwiftUI

@MainActor
final class PaymentBrickViewModel<T: MPPaymentData.Kind>: ObservableObject {
    enum ScreenState {
        case loading
        case ready(PaymentInitializationOutput)
    }

    @Published private(set) var screenState: ScreenState = .loading
    @Published private(set) var paymentData: MPPaymentData.Payment?

    private var presentedScreens: [MPScreen] = []

    var screensVisited: [MPScreen] {
        self.presentedScreens
    }

    // MARK: - Dependencies

    private let configuration: MPCheckoutConfiguration<T>
    private let appearance: MPCheckoutAppearance
    private let analytics: AnalyticsInterface
    private let fetchInitializationUseCase: FetchPaymentBrickInitializationUseCase
    private let orderTransactionUseCase: OrderTransactionUseCase
    private let initializeCardFormUseCase: InitializeCardFormUseCase
    private let securityCodeUseCase: SecurityCodeUseCase

    var footer: PaymentInitializationOutput.Footer? {
        guard case let .ready(output) = self.screenState else { return nil }
        return output.footer
    }

    init(
        configuration: MPCheckoutConfiguration<T>,
        appearance: MPCheckoutAppearance = MPCheckoutAppearance(),
        analytics: AnalyticsInterface = CoreDependencyContainer.shared.analytics,
        fetchInitializationUseCase: FetchPaymentBrickInitializationUseCase = FetchPaymentBrickInitializationUseCase(),
        orderTransactionUseCase: OrderTransactionUseCase = OrderTransactionUseCase(),
        initializeCardFormUseCase: InitializeCardFormUseCase = InitializeCardFormUseCase(),
        securityCodeUseCase: SecurityCodeUseCase = SecurityCodeUseCase()
    ) {
        self.configuration = configuration
        self.appearance = appearance
        self.analytics = analytics
        self.fetchInitializationUseCase = fetchInitializationUseCase
        self.orderTransactionUseCase = orderTransactionUseCase
        self.initializeCardFormUseCase = initializeCardFormUseCase
        self.securityCodeUseCase = securityCodeUseCase

        if case let .payment(order, _) = configuration.type.kind {
            self.paymentData = .init(orderId: order.orderId, transactionAmount: .zero)
        }
    }

    // MARK: - Screen tracking

    func markScreenPresented(_ screen: MPScreen) {
        if !self.presentedScreens.contains(screen) {
            self.presentedScreens.append(screen)
        }
    }

    // MARK: - Load

    func load() async throws(MercadoPagoCheckoutError) {
        guard case let .payment(order, _) = configuration.type.kind else {
            return
        }
        self.screenState = .loading
        let output = try await fetchInitializationUseCase.execute(
            orderId: order.orderId,
            clientToken: order.clientToken,
            screens: self.configuration.screenConfigs.screensParameter
        )
        self.screenState = .ready(output)
    }

    func loadCardForm(
        for item: PaymentInitializationOutput.Item
    ) async throws(MercadoPagoCheckoutError) -> CardFormViewModel {
        guard case let .payment(order, _) = configuration.type.kind else {
            throw MercadoPagoCheckoutError(
                code: .unknown,
                localizedDescription: "CARD_FORM_INITIALIZATION",
                userInfo: ["checkoutType": "payment"],
                location: .initialization
            )
        }
        do {
            let result = try await withRetry {
                try await self.initializeCardFormUseCase.execute(
                    order: order,
                    checkoutType: self.configuration.type
                )
            }

            let cardFormConfiguration = CardFormViewModel.Configuration(
                amount: result.amount,
                checkoutTypeAnalyticsValue: self.configuration.type.analyticsValue,
                excludedPaymentTypeIds: item.config?.paymentMethod?.notAllowedTypes ?? [],
                excludedPaymentMethodIds: item.config?.paymentMethod?.notAllowedIds ?? [],
                initResult: result,
                minInstallments: nil,
                maxInstallments: nil,
                screens: self.configuration.screenConfigs.screensParameter,
                orderId: order.orderId,
                clientToken: order.clientToken
            )
            return CardFormViewModel(config: cardFormConfiguration, analytics: self.analytics)
        } catch let error as MercadoPagoCheckoutError {
            throw error
        } catch {
            throw MercadoPagoCheckoutError(
                code: .unknown,
                localizedDescription: error.localizedDescription,
                location: .initialization
            )
        }
    }

    // MARK: - Process Order

    func processOrderResult(params: OrderTransactionParams) async -> MercadoPagoCheckoutResult<T> {
        do {
            return try .success(await self.processOrder(params: params))
        } catch {
            return .error(error)
        }
    }

    func processOrder(params: OrderTransactionParams) async throws(MercadoPagoCheckoutError) -> T {
        let result = try await self.processOrderData(params: params)
        return try self.makePaymentResult(from: result)
    }

    func processOrderData(
        params: OrderTransactionParams
    ) async throws(MercadoPagoCheckoutError) -> OrderTransactionProcessData {
        guard case let .payment(order, _) = configuration.type.kind else {
            throw MercadoPagoCheckoutError(
                code: .unknown,
                localizedDescription: "ORDER_PROCESS",
                userInfo: ["checkoutType": "payment"],
                location: .orderProcess
            )
        }
        return try await self.orderTransactionUseCase.execute(
            orderId: order.orderId,
            clientToken: order.clientToken,
            params: params
        )
    }

    func makePaymentResult(
        from result: OrderTransactionProcessData
    ) throws(MercadoPagoCheckoutError) -> T {
        guard case let .payment(order, _) = configuration.type.kind else {
            throw MercadoPagoCheckoutError(
                code: .unknown,
                localizedDescription: "ORDER_PROCESS",
                userInfo: ["checkoutType": "payment"],
                location: .orderProcess
            )
        }
        guard let payment = result.payments.first else {
            throw MercadoPagoCheckoutError(
                code: .serviceError,
                localizedDescription: "",
                userInfo: ["checkoutType": "payment"],
                location: .orderProcess
            )
        }
        guard let amount = Decimal(
            string: payment.amount ?? result.totalAmount,
            locale: Locale(identifier: "en_US_POSIX")
        ) else {
            throw MercadoPagoCheckoutError(
                code: .serviceError,
                localizedDescription: "Invalid payment amount",
                userInfo: ["checkoutType": "payment"],
                location: .orderProcess
            )
        }

        let data = MPPaymentData.Payment(
            orderId: order.orderId,
            orderStatus: result.status,
            transactionAmount: amount,
            paymentMethodId: payment.paymentMethodId,
            paymentTypeId: payment.paymentTypeId,
            orderStatusDetail: result.statusDetail
        )
        guard let typed = data as? T else {
            throw MercadoPagoCheckoutError(
                code: .unknown,
                localizedDescription: "Typed Error",
                userInfo: ["checkoutType": "payment"],
                location: .orderProcess
            )
        }

        return typed
    }

    func shouldSkipSecurityCode(from item: PaymentInitializationOutput.Item) -> Bool {
        return item.cardData?.securityCodeScreen == nil
    }

    /// Tokenizes a saved card whose payment method doesn't require a CVV
    func tokenizeSavedCard(cardId: String) async throws(MercadoPagoCheckoutError) -> String {
        try await self.securityCodeUseCase.executeWithoutSecurityCode(cardId: cardId).token
    }

    func installmentsData(from item: PaymentInitializationOutput.Item) -> MPInstallmentsData? {
        guard let cardData = item.cardData,
              let installments = cardData.installments
        else { return nil }

        return MPInstallmentsData(
            installment: installments,
            cardDisplayInfo: CardDisplayInfo(
                issuerName: item.description ?? String(),
                paymentTypeId: cardData.paymentTypeId,
                lastFourDigits: cardData.lastFourDigits ?? String()
            )
        )
    }

    func cardTransaction(
        from item: PaymentInitializationOutput.Item,
        token: String?
    ) -> MPPaymentData.CardTransaction? {
        guard let cardData = item.cardData else { return nil }

        return MPPaymentData.CardTransaction(
            transactionAmount: cardData.installments?.quotas.first?.totalAmount ?? .zero,
            token: token ?? String(),
            paymentMethodId: cardData.paymentMethodId,
            paymentTypeId: cardData.paymentTypeId,
            issuerId: String(cardData.issuerId),
            orderId: self.paymentData?.orderId ?? String()
        )
    }

    func cardTransaction(from result: CardFormSubmitResult, amount: Decimal) -> MPPaymentData.CardTransaction {
        MPPaymentData.CardTransaction(
            transactionAmount: amount,
            token: result.token,
            paymentMethodId: result.paymentMethodId,
            paymentTypeId: result.paymentTypeId,
            issuerId: result.issuerId,
            orderId: self.paymentData?.orderId ?? String()
        )
    }

    // MARK: - Review & Confirm

    /// Builds the data the review and confirm screen needs, or `nil` when the integrator did not
    /// opt into it via `withReviewAndConfirm`.
    func reviewConfirmInput(
        for params: OrderTransactionParams,
        cardDetails: ReviewConfirmCardDetails
    ) -> PendingReviewConfirmInput? {
        guard self.configuration.reviewAndConfirmConfig != nil,
              case let .payment(order, sellerInfo) = self.configuration.type.kind
        else { return nil }

        return PendingReviewConfirmInput(
            order: order,
            checkoutType: self.configuration.type.analyticsValue,
            sellerInfo: sellerInfo,
            paymentParams: params,
            cardDetails: cardDetails
        )
    }

    /// The seller's callback for "Modificar" on the email row (ticket flow only), or `nil` when
    /// review and confirm is not configured or the seller did not opt into email changes.
    var onEmailChangeRequested: (@MainActor @Sendable () -> Void)? {
        guard case let .reviewAndConfirm(callback) = self.configuration.reviewAndConfirmConfig else {
            return nil
        }
        return callback
    }
}
