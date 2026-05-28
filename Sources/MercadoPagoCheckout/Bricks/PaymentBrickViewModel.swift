//
//  PaymentBrickViewModel.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 28/05/26.
//

import Foundation
import MPAnalytics
import MPCore

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

    init(
        configuration: MPCheckoutConfiguration<T>,
        appearance: MPCheckoutAppearance = MPCheckoutAppearance(),
        analytics: AnalyticsInterface = CoreDependencyContainer.shared.analytics
    ) {
        self.configuration = configuration
        self.appearance = appearance
        self.analytics = analytics
    }
}
