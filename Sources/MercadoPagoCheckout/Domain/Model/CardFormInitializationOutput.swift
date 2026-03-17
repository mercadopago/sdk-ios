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
    let fields: CardFormTexts.Fields
    let identificationTypes: [IdentificationType]
}
