//
//  CardFormInitializationOutput.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 16/03/26.
//

import CoreMethods
import Foundation

struct CardFormInitializationOutput {
    let title: String
    let button: String
    let currencySymbol: String
    let amount: Decimal
    let fields: CardFormFields.Fields
    let identificationTypes: [IdentificationType]
}
