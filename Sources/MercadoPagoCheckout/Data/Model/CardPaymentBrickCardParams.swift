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
    let screens: String?
    let orderId: String?
    let clientToken: String?

    init(
        bin: String,
        amount: Decimal?,
        checkoutType: String,
        processingMode: String,
        excludedCardTypes: [String],
        excludedCardBrands: [String],
        maxInstallments: Int?,
        minInstallments: Int?,
        screens: String?,
        orderId: String? = nil,
        clientToken: String? = nil
    ) {
        self.bin = bin
        self.amount = amount
        self.checkoutType = checkoutType
        self.processingMode = processingMode
        self.excludedCardTypes = excludedCardTypes
        self.excludedCardBrands = excludedCardBrands
        self.maxInstallments = maxInstallments
        self.minInstallments = minInstallments
        self.screens = screens
        self.orderId = orderId
        self.clientToken = clientToken
    }
}
