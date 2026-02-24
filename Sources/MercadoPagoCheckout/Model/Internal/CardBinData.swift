//
//  CardBinData.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 24/02/26.
//
import CoreMethods

struct CardBinData {
    let paymentMethod: PaymentMethod
    let issuer: Issuer?
    let installment: Installment?
}
