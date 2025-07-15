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

    public init(cardNumber: String, expirationYear: String, expirationMonth: String, securityCode: String, documentType: String?, documentNumber: String?, cardHolderName: String) {
        self.cardNumber = cardNumber
        self.expirationYear = expirationYear
        self.expirationMonth = expirationMonth
        self.securityCode = securityCode
        self.documentType = documentType
        self.documentNumber = documentNumber
        self.cardHolderName = cardHolderName
    }
}
