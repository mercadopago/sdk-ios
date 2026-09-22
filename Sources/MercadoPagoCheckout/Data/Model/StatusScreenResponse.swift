//
//  StatusScreenResponse.swift
//  MercadoPagoSDK
//

struct StatusScreenResponse: Codable, Sendable {
    struct Header: Codable, Sendable {
        let title: String
        let icon: String
    }

    struct BodyNode: Codable, Sendable {
        enum Component: String, Codable, Sendable {
            case listItem = "MPListItem"
            case barcode = "MPBarcode"
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
            let receiptURL: String?
            let style: String?

            enum CodingKeys: String, CodingKey {
                case label
                case action
                case receiptURL = "receipt_url"
                case style
            }
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
