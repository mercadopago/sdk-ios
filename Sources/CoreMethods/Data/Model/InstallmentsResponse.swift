//
//  InstallmentsResponse.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 28/02/25.
//

struct InstallmentsResponse: Codable, Sendable {
    let paymentMethodId: String
    let paymentTypeId: String
    let thumbnail: String
    let issuer: Issuer
    let processingMode: String
    let merchantAccountId: String
    let payerCosts: [PayerCost]
    let agreements: [Agreement]

    enum CodingKeys: String, CodingKey {
        case paymentMethodId = "payment_method_id"
        case paymentTypeId = "payment_type_id"
        case thumbnail
        case issuer
        case processingMode = "processing_mode"
        case merchantAccountId = "merchant_account_id"
        case payerCosts = "payer_costs"
        case agreements
    }

    struct Issuer: Codable, Sendable {
        let id: String
        let thumbnail: String
    }

    struct PayerCost: Codable, Sendable {
        let installments: Int
        let installmentAmount: Double
        let installmentRate: Double
        let installmentRateCollector: [String]
        let totalAmount: Double
        let minAllowedAmount: Double
        let maxAllowedAmount: Double
        let discountRate: Double
        let reimbursementRate: Double
        let labels: [String]
        let paymentMethodOptionId: String

        enum CodingKeys: String, CodingKey {
            case installments
            case installmentAmount = "installment_amount"
            case installmentRate = "installment_rate"
            case installmentRateCollector = "installment_rate_collector"
            case totalAmount = "total_amount"
            case minAllowedAmount = "min_allowed_amount"
            case maxAllowedAmount = "max_allowed_amount"
            case discountRate = "discount_rate"
            case reimbursementRate = "reimbursement_rate"
            case labels
            case paymentMethodOptionId = "payment_method_option_id"
        }
    }

    struct Agreement: Codable, Sendable {
        let merchantAccounts: [MerchantAccount]
        let timeFrame: TimeFrame

        enum CodingKeys: String, CodingKey {
            case merchantAccounts = "merchant_accounts"
            case timeFrame = "time_frame"
        }

        struct MerchantAccount: Codable, Sendable {
            let id: String
            let paymentMethodOptionId: String

            enum CodingKeys: String, CodingKey {
                case id
                case paymentMethodOptionId = "payment_method_option_id"
            }
        }

        struct TimeFrame: Codable, Sendable {
            let startDate: String
            let endDate: String

            enum CodingKeys: String, CodingKey {
                case startDate = "start_date"
                case endDate = "end_date"
            }
        }
    }
}
