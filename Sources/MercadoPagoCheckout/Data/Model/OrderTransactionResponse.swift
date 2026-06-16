//
//  OrderTransactionResponse.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 02/06/26.
//

struct OrderTransactionResponse: Codable {
    let id: String
    let productId: String
    let type: String
    let totalAmount: String
    let totalPaidAmount: String
    let siteId: String
    let status: String
    let statusDetail: String
    let dateCreated: String
    let lastUpdated: String
    let userId: String
    let captureMode: String
    let processingMode: String
    let payer: PayerData
    let transactions: TransactionsData

    enum CodingKeys: String, CodingKey {
        case id
        case productId = "product_id"
        case type
        case totalAmount = "total_amount"
        case totalPaidAmount = "total_paid_amount"
        case siteId = "site_id"
        case status
        case statusDetail = "status_detail"
        case dateCreated = "date_created"
        case lastUpdated = "last_updated"
        case userId = "user_id"
        case captureMode = "capture_mode"
        case processingMode = "processing_mode"
        case payer
        case transactions
    }

    struct PayerData: Codable {
        let id: String
        let email: String
    }

    struct TransactionsData: Codable {
        let payments: [PaymentData]

        struct PaymentData: Codable {
            let id: String
            let status: String
            let statusDetail: String
            let amount: String
            let paidAmount: String
            let paymentMethod: PaymentMethodData
            let reference: ReferenceData

            enum CodingKeys: String, CodingKey {
                case id
                case status
                case statusDetail = "status_detail"
                case amount
                case paidAmount = "paid_amount"
                case paymentMethod = "payment_method"
                case reference
            }

            struct PaymentMethodData: Codable {
                let id: String
                let type: String
                let installments: Int
            }

            struct ReferenceData: Codable {
                let id: String
                let source: String
            }
        }
    }
}
