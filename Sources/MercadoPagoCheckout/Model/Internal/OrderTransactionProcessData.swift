//
//  OrderTransactionProcessData.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 01/06/26.
//

struct OrderTransactionProcessData {
    let id: String
    let status: String
    let statusDetail: String
    let totalAmount: String
    let payments: [Payment]

    struct Payment {
        let id: String
        let status: String
        let statusDetail: String
        let amount: String
        let paymentMethodId: String
        let paymentTypeId: String
        let installments: Int
    }
}
