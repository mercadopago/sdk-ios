//
//  OrderTransactionProcessData.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 01/06/26.
//

struct OrderTransactionProcessData: Sendable {
    let id: String
    let status: String
    let statusDetail: String
    let totalAmount: String
    /// Always the payment processed in the current attempt — never earlier attempts.
    let payments: [Payment]

    struct Payment: Sendable {
        let id: String
        let status: String
        let statusDetail: String
        let amount: String?
        let paymentMethodId: String
        let paymentTypeId: String
        let installments: Int?
    }
}
