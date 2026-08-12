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

    // MARK: - Dependencies

    private let configuration: MPCheckoutConfiguration<T>
    private let appearance: MPCheckoutAppearance
    private let analytics: AnalyticsInterface
    private let fetchInitializationUseCase: FetchPaymentBrickInitializationUseCase
    private let orderTransactionUseCase: OrderTransactionUseCase

    @Published private(set) var paymentData: MPPaymentData.Payment?

    var transactionAmount: Decimal {
        switch self.configuration.type.kind {
        case let .payment(order, _, _):
            return order.amount
        default: return .zero
        }
    }

    var payerEmail: String {
        switch self.configuration.type.kind {
        case let .payment(order, _, _), let .cardTransaction(order):
            return order.payer.email
        case .saveCard:
            return ""
        }
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

        if case let .payment(order, _, _) = configuration.type.kind {
            self.paymentData = .init(orderId: order.orderId, transactionAmount: order.amount)
        }
    }

    // MARK: - Load

    func load() async throws(MercadoPagoCheckoutError) {
        guard case let .payment(order, cardIds: cardIds, customerId: customerId) = configuration.type.kind else {
            return
        }
        self.screenState = .loading
        let output = try await fetchInitializationUseCase.execute(
            orderId: order.orderId,
            totalAmount: order.amount,
            customerId: customerId,
            cardIds: cardIds
        )
        self.screenState = .ready(output)
    }

    // MARK: - Process Order

    func processOrder(params: OrderTransactionParams) async throws(MercadoPagoCheckoutError) -> T {
        guard case let .payment(order, _, _) = configuration.type.kind else {
            throw MercadoPagoCheckoutError(
                code: .unknown,
                localizedDescription: "ORDER_PROCESS",
                userInfo: ["checkouType": "payment"],
                location: .orderProcess
            )
        }
        let result = try await orderTransactionUseCase.execute(
            orderId: order.orderId,
            clientToken: order.clientToken,
            params: params
        )
        guard let payment = result.payments.first else {
            throw MercadoPagoCheckoutError(
                code: .serviceError,
                localizedDescription: "",
                userInfo: ["checkouType": "payment"],
                location: .orderProcess
            )
        }

        let data = MPPaymentData.Payment(
            orderId: order.orderId,
            orderStatus: result.status,
            transactionAmount: order.amount,
            paymentMethodId: payment.paymentMethodId,
            paymentTypeId: payment.paymentTypeId
        )
        guard let typed = data as? T else {
            throw MercadoPagoCheckoutError(
                code: .unknown,
                localizedDescription: "Typed Error",
                userInfo: ["checkouType": "payment"],
                location: .orderProcess
            )
        }

        return typed
    }

    func makeEmailViewModel() -> EmailViewModel {
        EmailViewModel(
            config: .init(
                initResult: EmailInitializationOutput(
                    title: "Completá el e-mail",
                    button: "Continuar",
                    label: "E-mail",
                    email: self.payerEmail,
                    placeholder: "Ejemplo: juan.perez@gmail.com",
                    errorEmpty: "Completá este campo.",
                    errorInvalid: "Ingresá un e-mail válido."
                )
            )
        )
    }
}
