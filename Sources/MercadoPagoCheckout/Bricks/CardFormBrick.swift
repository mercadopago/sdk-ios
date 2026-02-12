//
//  CardFormFlow.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 11/12/25.
//
import SwiftUI
import MPComponents

/// Fluxo interno do formulário de cartão.
/// Gerencia as etapas: formulário → parcelas → (revisa e confirma) → resultado.
struct CardFormFlow: View {

    private enum Step: Hashable {
        case installments
        case reviewAndConfirm
    }

    @State private var step: Step?
    @State private var paymentData: MPPaymentData

    private let checkout: MercadoPagoCheckout
    private let onResult: @MainActor @Sendable (CheckoutResult) -> Void

    @Environment(\.presentationMode) var presentationMode

    init(checkout: MercadoPagoCheckout) {
        self.checkout = checkout
        self.onResult = checkout.onResult
        self.paymentData = MPPaymentData(transactionAmount: 100)
    }

    var body: some View {
        ZStack {
            cardFormScreen()
            navigationLinks()
        }
    }

    // MARK: - Screens

    private func cardFormScreen() -> some View {
        CardFormScreen(
            paymentData: $paymentData,
            onBack: { cancelCheckout() },
            onContinue: {
                step = .installments
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
                advanceAfterInstallments()
            }
        )
    }

    // MARK: - Navigation

    @ViewBuilder
    private func navigationLinks() -> some View {
        Group {
            NavigationLink(
                destination: installmentScreen(),
                tag: .installments,
                selection: $step
            ) {
                EmptyView()
            }
            .hidden()
        }
    }

    // MARK: - Flow Decisions

    private func advanceAfterInstallments() {
        if checkout.reviewAndConfirm {
            step = .reviewAndConfirm
        } else {
            completeCheckout()
        }
    }

    // MARK: - Result Handlers

    private func cancelCheckout() {
        step = nil
        onResult(.userCancelled)
        presentationMode.wrappedValue.dismiss()
    }

    private func completeCheckout() {
        step = nil
        onResult(.success(paymentData))
    }

    private func fail(_ error: CheckoutError) {
        onResult(.error(error))
    }
}
