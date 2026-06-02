//
//  EmailInitializationOutput.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 02/06/26.
//

/// Text data shown on the ``EmailScreen``.
struct EmailInitializationOutput: Equatable {
    let title: String
    let button: String
    let label: String
    let email: String
    let placeholder: String
    let errorEmpty: String
    let errorInvalid: String
}
