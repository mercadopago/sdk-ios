//
//  CardFormBrick.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 11/12/25.
//
import SwiftUI
import MPComponents

public enum CardFormBrickError: Error, Equatable {
    case userCancelled
    case serviceError(String)
    case message(String)
}

public struct CardFormBrick: View {
    private enum Route: Hashable {
        case installments
    }
    
    @State private var route: Route?
    @State private var paymentData: MPPaymentData
    
    private let themeDark: MPTheme
    private let themeLight: MPTheme
    
    private let onSubmit: (MPPaymentData) -> Void
    private let onError: (CardFormBrickError) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    public init(
        configuration: MercadoPagoCheckout,
        onSubmit: @escaping (MPPaymentData) -> Void,
        onError: @escaping (CardFormBrickError) -> Void = { _ in }
    ) {
        self.onSubmit = onSubmit
        self.onError = onError
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
        onError(.userCancelled)
        presentationMode.wrappedValue.dismiss()
    }
    
    private func completeCheckout() {
        route = nil
        onSubmit(paymentData)
    }
    
    private func fail(_ error: CardFormBrickError) {
        onError(error)
    }
}
