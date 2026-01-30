//
//  CardFormBrick.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 11/12/25.
//
import SwiftUI
import MPComponents

public struct CardFormBrick: View {
    private enum Route: Hashable {
        case installments
    }
    
    @State private var route: Route?
    @State private var paymentData: MPPaymentData
    
    private let themeDark: MPTheme
    private let themeLight: MPTheme
    
    private let onResult: (CardFormResult) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    public init(
        configuration: MercadoPagoCheckout,
        onResult: @escaping (CardFormResult) -> Void,
    ) {
        self.onResult = onResult
        self.themeDark = configuration.theme.dark
        self.themeLight = configuration.theme.light
        self.paymentData = MPPaymentData(transactionAmount: 100)
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
            onBack: { cancelCheckout() },
            onContinue: {
                print("onContinue")
                route = .installments
            }
        )
    }
    
    private func installmentScreen() -> some View {
        InstallmentScreen(
            onBack: { route = nil },
            onContinue: { completeCheckout() },
            onError: {
                fail($0)
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
    
    private func fail(_ error: CardFormBrickError) {
        onResult(.error(error))
    }
}
