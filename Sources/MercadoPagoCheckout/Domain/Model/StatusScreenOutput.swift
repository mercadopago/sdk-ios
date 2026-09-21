//
//  StatusScreenOutput.swift
//  MercadoPagoSDK
//

import Foundation

struct StatusScreenOutput: Equatable, Sendable {
    struct Header: Equatable, Sendable {
        let title: String
        let iconURL: URL
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
    }

    enum BodyComponent: Equatable, Sendable {
        case listItem(ListItem)
        case barcode(Barcode)
    }

    struct FooterButton: Equatable, Sendable {
        enum Action: Equatable, Sendable {
            case back
            case openPDF(URL)
        }

        let label: String
        let action: Action
    }

    let header: Header
    let body: [BodyComponent]
    let footerButtons: [FooterButton]
}

enum StatusScreenContractError: Error, Equatable, Sendable {
    case unsupportedStatus
    case invalidHeader
    case invalidBody
    case invalidFooter
    case invalidURL
    case limitExceeded
}
