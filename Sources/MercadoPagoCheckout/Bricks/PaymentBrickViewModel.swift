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

    @Published private(set) var paymentData: MPPaymentData.PaymentTransaction?

    private var transactionAmount: Double {
        switch self.configuration.type.kind {
        case let .payment(order):
            return order.amount
        default: return .zero
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

        if case let .payment(order) = configuration.type.kind {
            self.paymentData = .init(orderId: order.orderId, transactionAmount: order.amount)
        }
    }
}
