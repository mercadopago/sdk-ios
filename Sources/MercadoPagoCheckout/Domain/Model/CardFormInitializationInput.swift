//
//  CardFormInitializationInput.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 16/03/26.
//

import CoreMethods

/// Input entity returned by the repository.
/// Contains all raw data needed for business decisions (e.g. button variants in future).
/// The UseCase consumes this and produces a `CardFormInitializationOutput` (output entity).
struct CardFormInitializationInput {
    let title: String
    let buttonVariants: ButtonVariants
    let fields: CardFormTexts.Fields
    let identificationTypes: [IdentificationType]

    struct ButtonVariants {
        let save: String
        let pay: String
    }
}
