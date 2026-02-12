//
//  CheckoutFlowView.swift
//  MercadoPagoSDK
//

import SwiftUI
import MPComponents

/// View interna que orquestra o fluxo completo do checkout.
/// Roteia para o fluxo correto com base no `checkoutType` configurado no builder.
struct CheckoutFlowView: View {

    let checkout: MercadoPagoCheckout

    var body: some View {
        ThemeProvider(
            light: checkout.theme.light,
            dark: checkout.theme.dark
        ) {
            NavigationView {
                flowContent()
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }

    @ViewBuilder
    private func flowContent() -> some View {
        switch checkout.checkoutType {
        case .cardForm:
            CardFormFlow(checkout: checkout)
        }
    }
}

// MARK: - Canvas Preview

struct CheckoutFlowView_Previews: PreviewProvider {
    static var previews: some View {
        // Card Form com Review e Confirma
        MercadoPagoCheckout.Builder(.cardForm, theme: MercadoPagoCheckout.Theme())
            .reviewAndConfirm(true)
            .onResult { result in
                print("Preview result: \(result)")
            }
            .build()
            .createView()
            .previewDisplayName("Card Form - com Review")

        // Card Form sem Review e Confirma
        MercadoPagoCheckout.Builder(.cardForm, theme: MercadoPagoCheckout.Theme())
            .reviewAndConfirm(false)
            .onResult { result in
                print("Preview result: \(result)")
            }
            .build()
            .createView()
            .previewDisplayName("Card Form - sem Review")
    }
}
