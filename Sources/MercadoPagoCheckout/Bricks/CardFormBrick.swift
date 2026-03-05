//
//  CardFormBrick.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 11/12/25.
//
import SwiftUI
import MPComponents

struct CardFormBrick: View {
    private enum Route: Hashable {
        case installments
        case reviewAndConfirm
    }

    @State private var route: Route?
    @State private var paymentData: MPPaymentData

    private let themeDark: MPTheme
    private let themeLight: MPTheme
    private let configuration: MercadoPagoCheckout.CheckoutConfiguration

    private let onResult: (MercadoPagoCheckoutResult) -> Void

    @Environment(\.presentationMode) var presentationMode

    init(
        configuration: MercadoPagoCheckout.CheckoutConfiguration,
        appearance: MercadoPagoCheckout.CheckoutAppearance,
        onResult: @escaping (MercadoPagoCheckoutResult) -> Void
    ) {
        self.onResult = onResult
        self.themeDark = appearance.dark
        self.themeLight = appearance.light
        self.configuration = configuration
        self.paymentData = MPPaymentData(transactionAmount: configuration.type.configuration.amount ?? 0)
    }
    
    var body: some View {
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
        .listItemStyle(.radioButton)
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
