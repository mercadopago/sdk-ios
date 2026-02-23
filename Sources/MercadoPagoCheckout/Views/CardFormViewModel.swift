//
//  CardFormViewModel.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 28/01/26.
//
import SwiftUI
import CoreMethods
import MPComponents

@MainActor
final class CardFormViewModel: ObservableObject {

    let configuration: MercadoPagoCheckout.CheckoutConfiguration

    // Formatters
    let cardNumberFormatter = CardNumberFormatter()
    let expirationDateFormatter = ExpirationDateFormatter()
    let securityCodeFormatter = SecurityCodeFormatter()

    @Published var selectTypeDocument: IdentificationType = .init(name: "CPF")

    init(configuration: MercadoPagoCheckout.CheckoutConfiguration) {
        self.configuration = configuration
    }
}
