//
//  OrderTransactionResponse.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 02/06/26.
//

/// Order process response. Only the current attempt is read: legacy `transactions` history the
/// backend may still send stays unknown JSON on purpose.
struct OrderTransactionResponse: Codable, Sendable {
    let id: String
    let status: String
    let statusDetail: String
    let totalAmount: String
    let totalPaidAmount: String?
    let paymentProcessed: PaymentData

    enum CodingKeys: String, CodingKey {
        case id
        case status
        case statusDetail = "status_detail"
        case totalAmount = "total_amount"
        case totalPaidAmount = "total_paid_amount"
        case paymentProcessed = "payment_processed"
    }

    struct PaymentData: Codable, Sendable {
        let id: String
        let status: String
        let statusDetail: String
        let amount: String?
        let paymentMethod: PaymentMethodData

        enum CodingKeys: String, CodingKey {
            case id
            case status
            case statusDetail = "status_detail"
            case amount
            case paymentMethod = "payment_method"
        }

        struct PaymentMethodData: Codable, Sendable {
            let id: String
            let type: String
            let installments: Int?
            let barcodeContent: String?
            let ticketURL: String?
            let redirectURL: String?

            enum CodingKeys: String, CodingKey {
                case id
                case type
                case installments
                case barcodeContent = "barcode_content"
                case ticketURL = "ticket_url"
                case redirectURL = "redirect_url"
            }
        }
    }
}
