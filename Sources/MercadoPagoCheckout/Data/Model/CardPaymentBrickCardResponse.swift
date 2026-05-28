//
//  CardPaymentBrickCardResponse.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 13/04/26.
//

struct CardPaymentBrickCardResponse: Codable {
    let translations: CardFormTranslationsResponse
    let installment: InstallmentData?
    let paymentMethods: [PaymentMethodData]

    enum CodingKeys: String, CodingKey {
        case translations
        case installment
        case paymentMethods = "payment_methods"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.translations = try container.decode(CardFormTranslationsResponse.self, forKey: .translations)
        self.paymentMethods = try container.decode([PaymentMethodData].self, forKey: .paymentMethods)
        self.installment = try? container.decodeIfPresent(InstallmentData.self, forKey: .installment)
    }

    // MARK: - InstallmentData

    struct InstallmentData: Codable {
        let selectionType: String
        let quotas: [QuotaData]

        enum CodingKeys: String, CodingKey {
            case selectionType = "selection_type"
            case quotas
        }

        struct QuotaData: Codable {
            let installments: Int
            let installmentAmount: Double
            let totalAmount: Double
            let primaryLabel: String
            let secondaryLabel: String
            let state: String
            let tertiaryLabel: String?
            let accessibilityLabel: String?

            enum CodingKeys: String, CodingKey {
                case installments
                case installmentAmount = "installment_amount"
                case totalAmount = "total_amount"
                case primaryLabel = "primary_label"
                case secondaryLabel = "secondary_label"
                case state
                case tertiaryLabel = "tertiary_label"
                case accessibilityLabel = "accessibility_label"
            }
        }
    }

    // MARK: - PaymentMethodData

    struct PaymentMethodData: Codable {
        let id: String
        let paymentTypeId: String
        let cardNumber: CardNumberData
        let securityCode: SecurityCodeData?
        let issuers: [IssuerData]

        enum CodingKeys: String, CodingKey {
            case id
            case paymentTypeId = "payment_type_id"
            case cardNumber = "card_number"
            case securityCode = "security_code"
            case issuers
        }

        struct CardNumberData: Codable {
            let type: String
            let length: LengthData
            let mask: String

            struct LengthData: Codable {
                let min: Int
                let max: Int
            }
        }

        struct SecurityCodeData: Codable {
            let mode: String
            let length: Int
            let type: String
            let tooltip: String
            let placeholder: String
        }

        struct IssuerData: Codable {
            let id: String
            let name: String
        }
    }
}
