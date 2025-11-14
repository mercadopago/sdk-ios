//
//  InstallmentScreen.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 14/11/25.
//
import MPComponents
import SwiftUI

struct InstallmentScreen: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Installment")
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .navigationBarTitle("Escolha sua parcela", displayMode: .large)
        .withHeader()
    }
}
