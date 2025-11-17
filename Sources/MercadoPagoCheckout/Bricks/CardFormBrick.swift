//
//  CardFormBrick.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 14/11/25.
//
import SwiftUI
import MPComponents

struct CardFormBrick: View {
    @Environment(\.checkoutTheme) var theme: MPTheme
    
    var body: some View {
        NavigationView {
            MPHeader(
                title: "Product",
                onBack: {
                    print("Back tapped")
                }
            ) {
                Spacer()
                NavigationLink(destination: InstallmentScreen()) {
                    Text("Choose Installment")
                }
            }
        }
    }
}

struct TelaCartao_Previews: PreviewProvider {
    static var previews: some View {
        ThemeProvider(
            light: MPLightTheme(),
            dark: MPLightTheme()
        ) {
            CardFormBrick()
        }

    }
}
