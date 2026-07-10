//
//  CardFormInitializationInput.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 16/03/26.
//

import CoreMethods
import Foundation

/// Input entity returned by the repository.
/// Contains all raw data needed for business decisions (e.g. button variants in future).
/// The UseCase consumes this and produces a `CardFormInitializationOutput` (output entity).
struct CardFormInitializationInput {
    let title: String
    let buttonLabel: String
    let currencySymbol: String
    let amount: Decimal?
    let fields: CardFormFields.Fields
    let identificationTypes: [IdentificationType]
}
