//
//  CardParams.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 08/05/25.
//

public struct CardParams: Sendable {
    let cardNumber: String
    let expirationYear: String
    let expirationMonth: String
    let securityCode: String
    let documentType: String?
    let documentNumber: String?
    let cardHolderName: String
}
