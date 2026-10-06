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
    let totalPaidAmount: String?
    /// Always the payment processed in the current attempt — never earlier attempts.
    let payments: [Payment]

    init(
        id: String,
        status: String,
        statusDetail: String,
        totalAmount: String,
        totalPaidAmount: String? = nil,
        payments: [Payment]
    ) {
        self.id = id
        self.status = status
        self.statusDetail = statusDetail
        self.totalAmount = totalAmount
        self.totalPaidAmount = totalPaidAmount
        self.payments = payments
    }

    struct Payment: Sendable {
        let id: String
        let status: String
        let statusDetail: String
        let amount: String?
        let paymentMethodId: String
        let paymentTypeId: String
        let installments: Int?
        let barcodeContent: String?
        let ticketURL: String?
        let redirectURL: String?

        init(
            id: String,
            status: String,
            statusDetail: String,
            amount: String?,
            paymentMethodId: String,
            paymentTypeId: String,
            installments: Int?,
            barcodeContent: String? = nil,
            ticketURL: String? = nil,
            redirectURL: String? = nil
        ) {
            self.id = id
            self.status = status
            self.statusDetail = statusDetail
            self.amount = amount
            self.paymentMethodId = paymentMethodId
            self.paymentTypeId = paymentTypeId
            self.installments = installments
            self.barcodeContent = barcodeContent
            self.ticketURL = ticketURL
            self.redirectURL = redirectURL
        }
    }
}
