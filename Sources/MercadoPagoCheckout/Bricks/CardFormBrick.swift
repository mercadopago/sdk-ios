//
//  CardFormBrick.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 11/12/25.
//
import MPComponents
import SwiftUI

struct CardFormBrick: View {
    private enum Route: Hashable {
        case installments
        case reviewAndConfirm
    }

    @State private var route: Route?
    @State private var paymentData: MPPaymentData
    @State private var cardFormViewModel: CardFormViewModel

    private let themeDark: MPTheme
    private let themeLight: MPTheme
    private let transactionAmount: Double?

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
        self.transactionAmount = configuration.type.configuration.amount
        self._paymentData = State(initialValue: MPPaymentData(transactionAmount: self.transactionAmount, token: ""))
        self._cardFormViewModel = State(initialValue: CardFormViewModel(configuration: configuration))
    }

    var body: some View {
        ThemeProvider(
            light: self.themeLight,
            dark: self.themeDark
        ) {
            NavigationView {
                ZStack {
                    self.cardFormScreen()
                    self.navigationLinks()
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }

    private func cardFormScreen() -> some View {
        CardFormScreen(
            transactionAmount: self.transactionAmount,
            viewModel: self.cardFormViewModel,
            onBack: { self.cancelCheckout() },
            onSuccess: { paymentData in
                self.paymentData = paymentData
                self.completeCheckout()
            },
            onFailure: { error in
                self.fail(error)
            }
        )
    }

    private func installmentScreen() -> some View {
        InstallmentScreen(
            paymentData: self.$paymentData,
            installments: InstallmentMock.visa,
            onBack: {
                self.presentationMode.wrappedValue.dismiss()
            },
            onContinue: {
                self.route = .reviewAndConfirm
            }
        )
        .listItemStyle(.radioButton)
    }

    private func navigationLinks() -> some View {
        Group {
            NavigationLink(
                destination: self.installmentScreen(),
                tag: .installments,
                selection: self.$route
            ) {
                EmptyView()
            }
            .hidden()
        }
    }

    private func cancelCheckout() {
        self.route = nil
        self.onResult(.userCancelled)
        self.presentationMode.wrappedValue.dismiss()
    }

    private func completeCheckout() {
        self.route = nil
        self.onResult(.success(self.paymentData))
        self.presentationMode.wrappedValue.dismiss()
    }

    private func fail(_ error: MercadoPagoCheckoutError) {
        self.onResult(.error(error))
    }
}
