//
//  PaymentBrickInitializationResponse.swift
//  MercadoPagoSDK
//
//  Created by SDK on 22/06/26.
//
import Foundation

struct PaymentBrickInitializationResponse: Codable {
    let headerTitle: String
    let sections: [PaymentSection]
    let footer: Footer

    enum CodingKeys: String, CodingKey {
        case headerTitle = "header_title"
        case sections
        case footer
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.headerTitle = try container.decode(String.self, forKey: .headerTitle)
        self.sections = try container.decode([PaymentSection].self, forKey: .sections)
        self.footer = try container.decode(Footer.self, forKey: .footer)
    }

    // MARK: - PaymentSection

    struct PaymentSection: Codable {
        let title: String
        let methods: [PaymentMethod]
    }

    // MARK: - PaymentMethod

    struct PaymentMethod: Codable {
        let type: String
        let title: String
        let subtitle: String?
        let iconUrl: String
        let cardData: CardData?
        let options: [TicketOption]?
        let screen: MethodSelectionScreen?

        enum CodingKeys: String, CodingKey {
            case type
            case title
            case subtitle
            case iconUrl = "icon_url"
            case cardData = "card_data"
            case options
            case screen
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.type = try container.decode(String.self, forKey: .type)
            self.title = try container.decode(String.self, forKey: .title)
            self.subtitle = try? container.decodeIfPresent(String.self, forKey: .subtitle)
            self.iconUrl = try container.decode(String.self, forKey: .iconUrl)
            self.cardData = try? container.decodeIfPresent(CardData.self, forKey: .cardData)
            self.options = try? container.decodeIfPresent([TicketOption].self, forKey: .options)
            self.screen = try? container.decodeIfPresent(MethodSelectionScreen.self, forKey: .screen)
        }
    }

    // MARK: - CardData

    struct CardData: Codable {
        let id: String
        let bin: String
        let lastFourDigits: String
        let paymentMethodId: String
        let paymentTypeId: String
        let issuerId: Int
        let securityCode: SecurityCode
        let installments: Installments?

        enum CodingKeys: String, CodingKey {
            case id
            case bin
            case lastFourDigits = "last_four_digits"
            case paymentMethodId = "payment_method_id"
            case paymentTypeId = "payment_type_id"
            case issuerId = "issuer_id"
            case securityCode = "security_code"
            case installments
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(String.self, forKey: .id)
            self.bin = try container.decode(String.self, forKey: .bin)
            self.lastFourDigits = try container.decode(String.self, forKey: .lastFourDigits)
            self.paymentMethodId = try container.decode(String.self, forKey: .paymentMethodId)
            self.paymentTypeId = try container.decode(String.self, forKey: .paymentTypeId)
            self.issuerId = try container.decode(Int.self, forKey: .issuerId)
            self.securityCode = try container.decode(SecurityCode.self, forKey: .securityCode)
            self.installments = try? container.decodeIfPresent(Installments.self, forKey: .installments)
        }
    }

    // MARK: - SecurityCode

    struct SecurityCode: Codable {
        let length: Int
        let screen: SecurityCodeScreen?

        enum CodingKeys: String, CodingKey {
            case length
            case screen
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.length = try container.decode(Int.self, forKey: .length)
            self.screen = try? container.decodeIfPresent(SecurityCodeScreen.self, forKey: .screen)
        }
    }

    // MARK: - SecurityCodeScreen

    struct SecurityCodeScreen: Codable {
        let headerTitle: String
        let field: Field
        let continueButtonLabel: String

        enum CodingKeys: String, CodingKey {
            case headerTitle = "header_title"
            case field
            case continueButtonLabel = "continue_button_label"
        }

        struct Field: Codable {
            let label: String
            let placeholder: String
            let helper: String
            let error: String
        }
    }

    // MARK: - Installments

    struct Installments: Codable {
        let header: Header
        let totalLabel: String
        let payButtonLabel: String
        let selectionType: String
        let quotas: [Quota]

        enum CodingKeys: String, CodingKey {
            case header
            case totalLabel = "total_label"
            case payButtonLabel = "pay_button_label"
            case selectionType = "selection_type"
            case quotas
        }

        struct Header: Codable {
            let title: String
        }
    }

    // MARK: - Quota

    struct Quota: Codable {
        let installments: Int
        let installmentAmount: Decimal
        let totalAmount: Decimal
        let primaryLabel: String
        let secondaryLabel: String
        let state: String

        enum CodingKeys: String, CodingKey {
            case installments
            case installmentAmount = "installment_amount"
            case totalAmount = "total_amount"
            case primaryLabel = "primary_label"
            case secondaryLabel = "secondary_label"
            case state
        }
    }

    // MARK: - TicketOption

    struct TicketOption: Codable {
        let id: String
        let name: String
        let iconUrl: String

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case iconUrl = "icon_url"
        }
    }

    // MARK: - MethodSelectionScreen

    struct MethodSelectionScreen: Codable {
        let headerTitle: String
        let selectionType: String
        let footer: Footer
        let options: [Option]

        enum CodingKeys: String, CodingKey {
            case headerTitle = "header_title"
            case selectionType = "selection_type"
            case footer
            case options
        }

        struct Option: Codable {
            let id: String
            let name: String
            let subtitle: String
            let iconUrl: String

            enum CodingKeys: String, CodingKey {
                case id
                case name
                case subtitle
                case iconUrl = "icon_url"
            }
        }
    }

    // MARK: - Footer

    struct Footer: Codable {
        let totalLabel: String
        let totalAmount: String
        let button: Button?

        enum CodingKeys: String, CodingKey {
            case totalLabel = "total_label"
            case totalAmount = "total_amount"
            case button
        }

        struct Button: Codable {
            let label: String
        }
    }
}
