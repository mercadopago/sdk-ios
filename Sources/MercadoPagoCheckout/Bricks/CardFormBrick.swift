//
//  CardFormBrick.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 11/12/25.
//
import SwiftUI
import MPComponents

public struct CardFormBrick: View {
    public struct Configuration: Sendable {
        public let cardFormConfiguration: any MercadoPagoCheckout.CheckoutTypeConfiguration
        public let paymentMethods: [MercadoPagoCheckout.PaymentMethod]

        public init(
            cardFormConfiguration: any MercadoPagoCheckout.CheckoutTypeConfiguration,
            paymentMethods: [MercadoPagoCheckout.PaymentMethod]
        ) {
            self.cardFormConfiguration = cardFormConfiguration
            self.paymentMethods = paymentMethods
        }
    }

    private enum Route: Hashable {
        case installments
        case reviewAndConfirm
    }

    @State private var route: Route?
    @State private var paymentData: MPPaymentData

    private let themeDark: MPTheme
    private let themeLight: MPTheme
    private let configuration: Configuration

    private let onResult: (MercadoPagoCheckoutResult) -> Void

    @Environment(\.presentationMode) var presentationMode

    public init(
        configuration: Configuration,
        appearance: MercadoPagoCheckout.CheckoutAppearance,
        onResult: @escaping (MercadoPagoCheckoutResult) -> Void
    ) {
        self.onResult = onResult
        self.themeDark = appearance.dark
        self.themeLight = appearance.light
        self.configuration = configuration
        self.paymentData = MPPaymentData(transactionAmount: configuration.cardFormConfiguration.amount ?? 0)
    }
    
    public var body: some View {
        ThemeProvider(
            light: self.themeLight,
            dark: self.themeDark
        ) {
            NavigationView {
                ZStack {
                    cardFormScreen()
                    navigationLinks()
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    private func cardFormScreen() -> some View {
        CardFormScreen(
            paymentData: $paymentData,
            viewModel: .init(configuration: configuration),
            onBack: { cancelCheckout() },
            onContinue: {
                route = .installments
            }
        )
    }
    
    private func installmentScreen() -> some View {
        InstallmentScreen(
            paymentData: $paymentData,
            installments: InstallmentMock.visa,
            onBack: {
                presentationMode.wrappedValue.dismiss()
            },
            onContinue: {
                route = .reviewAndConfirm
            }
        )
    }
    
    @ViewBuilder
    private func navigationLinks() -> some View {
        Group {
            NavigationLink(
                destination: installmentScreen(),
                tag: .installments,
                selection: $route
            ) {
                EmptyView()
            }
            .hidden()
            
        }
    }
    
    private func cancelCheckout() {
        route = nil
        onResult(.userCancelled)
        presentationMode.wrappedValue.dismiss()
    }
    
    private func completeCheckout() {
        route = nil
        onResult(.success(paymentData))
    }
    
    private func fail(_ error: MercadoPagoCheckoutError) {
        onResult(.error(error))
    }
}
