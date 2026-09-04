//
//  CardFormSubmitResult.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 21/07/26.
//

struct CardFormSubmitResult: Sendable {
    let token: String
    let paymentMethodId: String
    let paymentTypeId: String
    let issuerId: String?
    let payer: Payer?
    let installmentsData: MPInstallmentsData?
    let bin: String?
    let lastFourDigits: String?

    struct Payer: Sendable {
        let documentType: String
        let documentNumber: String
    }
}
