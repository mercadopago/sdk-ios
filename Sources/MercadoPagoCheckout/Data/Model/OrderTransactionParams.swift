//
//  TransactionOrderParams.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 01/06/26.
//

struct OrderTransactionParams: Encodable {
    let amount: String
    let paymentMethodId: String
    let paymentMethodType: String
    let token: String
    let installments: Int
    
    enum CodingKeys: String, CodingKey {
        case amount
        case paymentMethodId = "payment_method_id"
        case paymentMethodType = "payment_method_type"
        case token
        case installments
    }
}
