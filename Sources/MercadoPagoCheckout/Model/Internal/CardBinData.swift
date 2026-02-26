//
//  CardBinData.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 24/02/26.
//
import CoreMethods

struct CardBinData: Equatable {
    let paymentMethod: PaymentMethod
    let issuer: Issuer?
    let installment: Installment?
    
    static func == (lhs: CardBinData, rhs: CardBinData) -> Bool {
        lhs.paymentMethod.id == rhs.paymentMethod.id &&
        lhs.issuer?.id == rhs.issuer?.id &&
        lhs.installment == rhs.installment
    }
}
