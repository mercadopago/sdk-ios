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
        MPHeader(
            title: "Product",
            onBack: {
                print("Back tapped")
            }
        ) {
            Spacer()
        }
    }
}
