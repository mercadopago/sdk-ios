//
//  PaymentsViewModel.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 28/05/26.
//

import Foundation
import MPComponents
import MPFoundation

@MainActor
final class PaymentsViewModel: ObservableObject {
    @Published private(set) var initialization: PaymentInitializationOutput

    let amount: MPAmountData
    let title: String

    init(amount: Double, initialization: PaymentInitializationOutput = .mock) {
        self.initialization = initialization
        self.amount = MPAmountData(from: amount)
        self.title = "Escolha como pagar"
    }
}
