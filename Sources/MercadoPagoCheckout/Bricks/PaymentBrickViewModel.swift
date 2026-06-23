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
        case ready
    }

    @Published private(set) var screenState: ScreenState = .ready

    // MARK: - Dependencies

    private let configuration: MPCheckoutConfiguration<T>
    private let appearance: MPCheckoutAppearance
    private let analytics: AnalyticsInterface

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
            return order.payer.email ?? ""
        case .saveCard:
            return ""
        }
    }

    init(
        configuration: MPCheckoutConfiguration<T>,
        appearance: MPCheckoutAppearance = MPCheckoutAppearance(),
        analytics: AnalyticsInterface = CoreDependencyContainer.shared.analytics
    ) {
        self.configuration = configuration
        self.appearance = appearance
        self.analytics = analytics

        if case let .payment(order, _, _) = configuration.type.kind {
            self.paymentData = .init(orderId: order.orderId, transactionAmount: order.amount)
        }
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
