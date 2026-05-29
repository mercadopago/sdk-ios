//
//  CardFormOutput.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 29/05/26.
//

struct CardFormOutput: Sendable {
    let token: String
    let paymentMethodId: String
    let paymentTypeId: String
    let issuerId: String?
    let payer: Payer?

    struct Payer: Sendable {
        let documentType: String
        let documentNumber: String
    }
}
