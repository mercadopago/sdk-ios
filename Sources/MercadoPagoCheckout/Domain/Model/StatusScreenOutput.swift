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
        enum HeaderIcon: Equatable, Sendable {
            case remote(URL)
            case badge(Tone)
        }

        enum Tone: Equatable, Sendable {
            case positive
            case pending
            case negative
        }

        let title: String
        let icon: HeaderIcon
        let subtitle: String?

        var iconURL: URL? {
            guard case let .remote(url) = self.icon else { return nil }
            return url
        }

        init(title: String, iconURL: URL, subtitle: String? = nil) {
            self.title = title
            self.icon = .remote(iconURL)
            self.subtitle = subtitle
        }

        init(title: String, tone: Tone, subtitle: String? = nil) {
            self.title = title
            self.icon = .badge(tone)
            self.subtitle = subtitle
        }
    }

    struct ListItem: Equatable, Sendable {
        enum Leading: Equatable, Sendable {
            case remoteImage(URL)
            case cardIcon
            case billIcon
        }

        enum Style: Equatable, Sendable {
            case standard
            case simple
        }

        let title: String
        let subtitle: String?
        let leading: Leading?
        let style: Style

        init(title: String, subtitle: String?, leading: Leading?, style: Style = .standard) {
            self.title = title
            self.subtitle = subtitle
            self.leading = leading
            self.style = style
        }
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
            case changePaymentMethod
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
    var canRetry: Bool?
}

enum StatusScreenContractError: Error, Equatable, Sendable {
    case invalidHeader
    case invalidURL
}
