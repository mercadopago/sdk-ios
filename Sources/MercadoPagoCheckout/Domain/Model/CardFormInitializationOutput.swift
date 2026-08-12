//
//  CardFormInitializationOutput.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 16/03/26.
//

import CoreMethods

struct CardFormInitializationOutput {
    let title: String
    let button: String
    let currencySymbol: String
    let fields: CardFormFields.Fields
    let identificationTypes: [IdentificationType]
}
