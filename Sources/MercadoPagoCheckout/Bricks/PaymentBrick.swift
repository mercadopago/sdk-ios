//
//  PaymentBrick.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 28/05/26.
//
import MPComponents
import MPFoundation
import SwiftUI

struct PaymentBrick<T: MPPaymentData.Kind>: View {
    private enum Route: Hashable {
        case cardForm
        case installments
        case reviewAndConfirm
    }

    @State private var route: Route?
    @ObservedObject private var viewModel: PaymentBrickViewModel<T>

    @Environment(\.checkoutTheme) private var theme: MPTheme

    private var configuration: MPCheckoutConfiguration<T>
    private let themeDark: MPTheme
    private let themeLight: MPTheme
    private let transactionAmount: Double

    private let onResult: (MercadoPagoCheckoutResult<T>) -> Void

    @MainActor
    init(
        configuration: MPCheckoutConfiguration<T>,
        appearance: MPCheckoutAppearance,
        onResult: @escaping (MercadoPagoCheckoutResult<T>) -> Void
    ) {
        self.configuration = configuration
        self.themeDark = appearance.themeConfiguration.dark
        self.themeLight = appearance.themeConfiguration.light
        self.onResult = onResult

        self.transactionAmount = configuration.type.configuration.amount
        self.viewModel = PaymentBrickViewModel<T>(configuration: configuration, appearance: appearance)
    }

    var body: some View {
        ThemeProvider(
            light: self.themeLight,
            dark: self.themeDark
        ) {
            NavigationView {
                ZStack {
                    switch self.viewModel.screenState {
                    case .loading:
                        ZStack {
                            self.theme.colors.background.primary
                                .edgesIgnoringSafeArea(.all)
                            MPProgressIndicator()
                                .size(.xlarge)
                        }
                    case .ready:
                        PaymentsScreen()
                    }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
