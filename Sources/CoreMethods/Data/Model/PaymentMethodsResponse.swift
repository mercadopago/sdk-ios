//
//  PaymentMethodsResponse.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 07/03/25.
//

struct PaymentMethodResponse: Codable {
    let id: String
    let paymentTypeId: String
    let status: String
    let processingMode: String
    let accreditationTime: Int
    let merchantAccountId: String
    let siteId: String
    let thumbnail: String?
    let minAccreditationDays: Int
    let maxAccreditationDays: Int
    let totalFinancialCost: Double
    let financialInstitutions: [FinancialInstitutionResponse]?
    let issuer: IssuerResponse?
    let card: CardInfoResponse?
    let bins: [Int]?
    let marketplace: String?
    let deferredCapture: String?
    let agreements: [AgreementResponse]?
    let payerCosts: [PayerCostResponse]?
    let labels: [String]?
    let additionalInfoNeeded: [String]?

    enum CodingKeys: String, CodingKey {
        case id
        case paymentTypeId = "payment_type_id"
        case status
        case processingMode = "processing_mode"
        case accreditationTime = "accreditation_time"
        case merchantAccountId = "merchant_account_id"
        case siteId = "site_id"
        case thumbnail
        case minAccreditationDays = "min_accreditation_days"
        case maxAccreditationDays = "max_accreditation_days"
        case totalFinancialCost = "total_financial_cost"
        case financialInstitutions = "financial_institutions"
        case issuer
        case card
        case bins
        case marketplace
        case deferredCapture = "deferred_capture"
        case agreements
        case payerCosts = "payer_costs"
        case labels
        case additionalInfoNeeded = "additional_info_needed"
    }

    struct FinancialInstitutionResponse: Codable {
        let id: String
        let description: String
    }

    struct IssuerResponse: Codable {
        let id: Int
        let isDefault: Bool
        let thumbnail: String?

        enum CodingKeys: String, CodingKey {
            case id
            case isDefault = "default"
            case thumbnail
        }
    }

    struct CardInfoResponse: Codable {
        let bin: Int
        let length: CardLengthResponse
        let validation: String
        let securityCode: SecurityCodeResponse

        enum CodingKeys: String, CodingKey {
            case bin
            case length
            case validation
            case securityCode = "security_code"
        }

        struct CardLengthResponse: Codable {
            let min: Int
            let max: Int
        }

        struct SecurityCodeResponse: Codable {
            let mode: String
            let location: String
            let length: Int
        }
    }

    struct PayerCostResponse: Codable {
        let installments: Int
        let installmentRate: Double
        let discountRate: Double
        let reimbursementRate: Double
        let minAllowedAmount: Double
        let maxAllowedAmount: Double
        let paymentMethodOptionId: String
        let labels: [String]?

        enum CodingKeys: String, CodingKey {
            case installments
            case installmentRate = "installment_rate"
            case discountRate = "discount_rate"
            case reimbursementRate = "reimbursement_rate"
            case minAllowedAmount = "min_allowed_amount"
            case maxAllowedAmount = "max_allowed_amount"
            case paymentMethodOptionId = "payment_method_option_id"
            case labels
        }
    }

    struct AgreementResponse: Codable {
        let timeFrame: TimeFrameResponse
        let merchantAccounts: [MerchantAccountResponse]

        enum CodingKeys: String, CodingKey {
            case timeFrame = "time_frame"
            case merchantAccounts = "merchant_accounts"
        }

        struct TimeFrameResponse: Codable {
            let startDate: String
            let endDate: String

            enum CodingKeys: String, CodingKey {
                case startDate = "start_date"
                case endDate = "end_date"
            }
        }

        struct MerchantAccountResponse: Codable {
            let id: String
            let paymentMethodOptionId: String

            enum CodingKeys: String, CodingKey {
                case id
                case paymentMethodOptionId = "payment_method_option_id"
            }
        }
    }
}
