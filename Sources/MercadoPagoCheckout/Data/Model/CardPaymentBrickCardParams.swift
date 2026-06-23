//
//  CardPaymentBrickCardParams.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 13/04/26.
//
import Foundation

struct CardPaymentBrickCardParams {
    let bin: String
    let amount: Decimal?
    let checkoutType: String
    let processingMode: String
    let excludedCardTypes: [String]
    let excludedCardBrands: [String]
    let maxInstallments: Int?
    let minInstallments: Int?
}
