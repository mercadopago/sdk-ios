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

    var screensVisited: [MPScreen] { self.presentedScreens }

    // MARK: - Dependencies

    private let configuration: MPCheckoutConfiguration<T>
    private let appearance: MPCheckoutAppearance
    private let analytics: AnalyticsInterface
    private let fetchInitializationUseCase: FetchPaymentBrickInitializationUseCase
    private let orderTransactionUseCase: OrderTransactionUseCase

    var transactionAmount: Decimal { .zero }

    var footer: PaymentInitializationOutput.Footer? {
        guard case let .ready(output) = self.screenState else { return nil }
        return output.footer
    }

    init(
        configuration: MPCheckoutConfiguration<T>,
        appearance: MPCheckoutAppearance = MPCheckoutAppearance(),
        analytics: AnalyticsInterface = CoreDependencyContainer.shared.analytics,
        fetchInitializationUseCase: FetchPaymentBrickInitializationUseCase = FetchPaymentBrickInitializationUseCase(),
        orderTransactionUseCase: OrderTransactionUseCase = OrderTransactionUseCase()
    ) {
        self.configuration = configuration
        self.appearance = appearance
        self.analytics = analytics
        self.fetchInitializationUseCase = fetchInitializationUseCase
        self.orderTransactionUseCase = orderTransactionUseCase

        if case let .payment(order) = configuration.type.kind {
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
        guard case let .payment(order) = configuration.type.kind else {
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

    // MARK: - Process Order

    func processOrder(params: OrderTransactionParams) async throws(MercadoPagoCheckoutError) -> T {
        guard case let .payment(order) = configuration.type.kind else {
            throw MercadoPagoCheckoutError(
                code: .unknown,
                localizedDescription: "ORDER_PROCESS",
                userInfo: ["checkoutType": "payment"],
                location: .orderProcess
            )
        }
        let result = try await orderTransactionUseCase.execute(
            orderId: order.orderId,
            clientToken: order.clientToken,
            params: params
        )
        return try self.makePaymentResult(from: result)
    }

    func makePaymentResult(
        from result: OrderTransactionProcessData
    ) throws(MercadoPagoCheckoutError) -> T {
        guard case let .payment(order) = configuration.type.kind else {
            throw MercadoPagoCheckoutError(
                code: .unknown,
                localizedDescription: "ORDER_PROCESS",
                userInfo: ["checkouType": "payment"],
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

        let data = MPPaymentData.Payment(
            orderId: order.orderId,
            orderStatus: result.status,
            transactionAmount: Decimal(string: result.totalAmount) ?? .zero,
            paymentMethodId: payment.paymentMethodId,
            paymentTypeId: payment.paymentTypeId
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

    // MARK: - Review & Confirm

    /// Builds the data the review and confirm screen needs, or `nil` when the integrator did not
    /// opt into it via `withReviewAndConfirm`.
    func reviewConfirmInput(
        for params: OrderTransactionParams,
        cardDetails: ReviewConfirmCardDetails
    ) -> PendingReviewConfirmInput? {
        guard self.configuration.reviewAndConfirmConfig != nil,
              case let .payment(order) = self.configuration.type.kind
        else { return nil }

        return PendingReviewConfirmInput(
            order: order,
            paymentParams: params,
            cardDetails: cardDetails
        )
    }

    /// The seller's callback for "Modificar" on the email row (ticket flow only), or `nil` when
    /// review and confirm is not configured or the seller did not opt into email changes.
    var onEmailChangeRequested: (@MainActor @Sendable () -> Void)? {
        guard case let .reviewAndConfirm(_, _, callback) = self.configuration.reviewAndConfirmConfig else {
            return nil
        }
        return callback
    }
}
