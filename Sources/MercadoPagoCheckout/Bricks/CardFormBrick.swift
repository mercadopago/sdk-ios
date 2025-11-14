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
            VStack(alignment: .leading) {
                Spacer()
                NavigationLink(destination: InstallmentScreen()) {
                    Text("Choose Installment")
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .navigationBarTitle("Insira seu cartão")
            .withHeader()
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
