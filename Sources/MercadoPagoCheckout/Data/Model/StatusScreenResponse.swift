//
//  StatusScreenResponse.swift
//  MercadoPagoSDK
//

struct StatusScreenResponse: Codable, Sendable {
    struct Header: Codable, Sendable {
        let title: String
        let subtitle: String?
        let icon: String

        init(title: String, icon: String, subtitle: String? = nil) {
            self.title = title
            self.icon = icon
            self.subtitle = subtitle
        }
    }

    struct BodyNode: Codable, Sendable {
        enum Component: String, Codable, Sendable {
            case listItem = "MPListItem"
            case barcode = "MPBarcode"
            case message = "MPMessage"
        }

        struct Data: Codable, Sendable {
            let title: String?
            let subtitle: String?
            let imageURL: String?
            let leadingType: String?
            let leadingValue: String?
            let content: String?
            let codeFormatted: String?
            let copyLabel: String?
            let copyFeedback: String?
            let icon: String?
            let text: String?

            enum CodingKeys: String, CodingKey {
                case title
                case subtitle
                case imageURL = "image_url"
                case leadingType = "leading_type"
                case leadingValue = "leading_value"
                case content
                case codeFormatted = "code_formatted"
                case copyLabel = "copy_label"
                case copyFeedback = "copy_feedback"
                case icon
                case text
            }
        }

        let component: Component
        let data: Data
    }

    struct Footer: Codable, Sendable {
        struct Button: Codable, Sendable {
            enum Action: String, Codable, Sendable {
                case back = "back_action"
                case openPDF = "open_pdf"
            }

            let label: String
            let action: Action
            let value: String?
            let style: String?
        }

        let buttons: [Button]
    }

    let statusType: String
    let header: Header
    let body: [BodyNode]
    let footer: Footer

    enum CodingKeys: String, CodingKey {
        case statusType = "status_type"
        case header
        case body
        case footer
    }
}

extension StatusScreenResponse {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.statusType = try container.decode(String.self, forKey: .statusType)
        self.header = try container.decode(Header.self, forKey: .header)
        self.body = try container.decode([LossyBodyNode].self, forKey: .body).compactMap(\.node)
        self.footer = try container.decode(Footer.self, forKey: .footer)
    }

    private struct LossyBodyNode: Decodable {
        let node: BodyNode?

        init(from decoder: Decoder) throws {
            self.node = try? BodyNode(from: decoder)
        }
    }
}
