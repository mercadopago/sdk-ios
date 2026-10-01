//
//  StatusScreenOutput.swift
//  MercadoPagoSDK
//

import Foundation

struct StatusScreenOutput: Equatable, Sendable {
    /// Icons bundled in the SDK. An icon key outside this list is not rendered.
    enum Icon: Equatable, Sendable {
        case copy
    }

    struct Header: Equatable, Sendable {
        let title: String
        let iconURL: URL
        let subtitle: String?

        init(title: String, iconURL: URL, subtitle: String? = nil) {
            self.title = title
            self.iconURL = iconURL
            self.subtitle = subtitle
        }
    }

    struct ListItem: Equatable, Sendable {
        enum Leading: Equatable, Sendable {
            case remoteImage(URL)
            case cardIcon
        }

        let title: String
        let subtitle: String?
        let leading: Leading?
    }

    struct Barcode: Equatable, Sendable {
        let content: String
        let codeFormatted: String
        let copyLabel: String
        let copyFeedback: String
        let icon: Icon?
    }

    enum BodyComponent: Equatable, Sendable {
        case listItem(ListItem)
        case barcode(Barcode)
        case message(String)
    }

    struct FooterButton: Equatable, Sendable {
        enum Action: Equatable, Sendable {
            case back
            case openPDF(URL)
        }

        enum Style: Equatable, Sendable {
            case loud
            case quiet
            case transparent
        }

        let label: String
        let action: Action
        let style: Style?
    }

    let statusType: String
    let header: Header
    let body: [BodyComponent]
    let footerButtons: [FooterButton]
}

enum StatusScreenContractError: Error, Equatable, Sendable {
    case invalidHeader
    case invalidFooter
    case invalidURL
}
