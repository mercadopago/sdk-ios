//
//  InstallmentScreen.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 14/11/25.
//

import MPComponents
import MPFoundation
import SwiftUI

struct InstallmentScreen: View {
    var body: some View {
        MPHeader(
            title: MPStrings.Installments.title,
            onBack: {
                print("Back tapped")
            }
        ) {
            Spacer()
        }
    }
}
