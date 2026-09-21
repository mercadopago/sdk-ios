//
//  StatusScreenMapper.swift
//  MercadoPagoSDK
//

import Foundation

struct StatusScreenMapper: Sendable {
    func map(_ response: StatusScreenResponse) throws -> StatusScreenOutput {
        guard response.statusType == "approved" else {
            throw StatusScreenContractError.unsupportedStatus
        }
        guard let headerURL = URL(string: response.header.icon) else {
            throw StatusScreenContractError.invalidHeader
        }

        let body = try response.body.map(self.mapBodyNode)
        let footer = try self.mapFooter(response.footer)
        return StatusScreenOutput(
            header: .init(title: response.header.title, iconURL: headerURL),
            body: body,
            footerButtons: footer
        )
    }

    private func mapBodyNode(_ node: StatusScreenResponse.BodyNode) throws -> StatusScreenOutput.BodyComponent {
        switch node.component {
        case .listItem:
            return try .listItem(self.mapListItem(node.data))
        case .barcode:
            return try .barcode(self.mapBarcode(node.data))
        }
    }

    private func mapListItem(_ data: StatusScreenResponse.BodyNode.Data) throws -> StatusScreenOutput.ListItem {
        let title = data.title ?? ""
        guard data.content == nil,
              data.codeFormatted == nil,
              data.copyLabel == nil,
              data.copyFeedback == nil
        else {
            throw StatusScreenContractError.invalidBody
        }

        let leading: StatusScreenOutput.ListItem.Leading?
        if let imageURL = data.imageURL {
            guard data.leadingType == nil, data.leadingValue == nil,
                  let url = URL(string: imageURL)
            else {
                throw StatusScreenContractError.invalidBody
            }
            leading = .remoteImage(url)
        } else if data.leadingType == "icon", data.leadingValue == "card" {
            leading = .cardIcon
        } else if data.leadingType == nil, data.leadingValue == nil {
            leading = nil
        } else {
            throw StatusScreenContractError.invalidBody
        }

        return .init(title: title, subtitle: data.subtitle, leading: leading)
    }

    private func mapBarcode(_ data: StatusScreenResponse.BodyNode.Data) throws -> StatusScreenOutput.Barcode {
        guard let content = data.content,
              let codeFormatted = data.codeFormatted,
              let copyLabel = data.copyLabel,
              let copyFeedback = data.copyFeedback,
              data.title == nil,
              data.subtitle == nil,
              data.imageURL == nil,
              data.leadingType == nil,
              data.leadingValue == nil
        else {
            throw StatusScreenContractError.invalidBody
        }
        return .init(
            content: content,
            codeFormatted: codeFormatted,
            copyLabel: copyLabel,
            copyFeedback: copyFeedback
        )
    }

    private func mapFooter(_ footer: StatusScreenResponse.Footer) throws -> [StatusScreenOutput.FooterButton] {
        return try footer.buttons.map { button in
            let style = self.mapStyle(button.style)
            switch button.action {
            case .back:
                guard button.receiptURL == nil else {
                    throw StatusScreenContractError.invalidFooter
                }
                return .init(label: button.label, action: .back, style: style)
            case .openPDF:
                guard let rawURL = button.receiptURL, let url = URL(string: rawURL) else {
                    throw StatusScreenContractError.invalidURL
                }
                return .init(label: button.label, action: .openPDF(url), style: style)
            }
        }
    }

    private func mapStyle(_ rawStyle: String?) -> StatusScreenOutput.FooterButton.Style? {
        switch rawStyle {
        case "loud": .loud
        case "quiet": .quiet
        case "transparent": .transparent
        default: nil
        }
    }
}
