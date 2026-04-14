//
//  CardPaymentBrickCardParams.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 13/04/26.
//

struct CardPaymentBrickCardParams {
    let bin: String
    let amount: Double?
    let checkoutType: String
    let processingMode: String
    let locale: String
    let allowCardTypes: [String]
    let allowCardBrands: [String]
}
