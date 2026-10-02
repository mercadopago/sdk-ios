//
//  StatusScreenMapper.swift
//  MercadoPagoSDK
//

import Foundation

struct StatusScreenMapper: Sendable {
    func map(_ response: StatusScreenResponse) throws -> StatusScreenOutput {
        guard let headerURL = URL(string: response.header.icon) else {
            throw StatusScreenContractError.invalidHeader
        }

        let header = StatusScreenOutput.Header(
            title: response.header.title,
            iconURL: headerURL,
            subtitle: response.header.subtitle
        )
        let footer = try self.mapFooter(response.footer)
        // An invalid body item is dropped so the rest of the screen still renders.
        let body = response.body.compactMap(self.mapBodyNode)
        return StatusScreenOutput(
            statusType: response.statusType,
            header: header,
            body: body,
            footerButtons: footer,
            canRetry: response.canRetry
        )
    }

    private func mapBodyNode(_ node: StatusScreenResponse.BodyNode) -> StatusScreenOutput.BodyComponent? {
        switch node.component {
        case .listItem:
            return self.mapListItem(node.data).map { .listItem($0) }
        case .barcode:
            return self.mapBarcode(node.data).map { .barcode($0) }
        case .message:
            return self.mapMessage(node.data).map { .message($0) }
        }
    }

    private func mapListItem(_ data: StatusScreenResponse.BodyNode.Data) -> StatusScreenOutput.ListItem? {
        let title = data.title ?? ""
        guard data.content == nil,
              data.codeFormatted == nil,
              data.copyLabel == nil,
              data.copyFeedback == nil,
              data.text == nil
        else {
            return nil
        }

        let leading: StatusScreenOutput.ListItem.Leading?
        if let imageURL = data.imageURL {
            guard data.leadingType == nil, data.leadingValue == nil,
                  let url = URL(string: imageURL)
            else {
                return nil
            }
            leading = .remoteImage(url)
        } else {
            switch (data.leadingType, data.leadingValue) {
            case ("icon", "card"): leading = .cardIcon
            case ("icon", "bill"): leading = .billIcon
            case (nil, nil): leading = nil
            default: return nil
            }
        }

        return .init(
            title: title,
            subtitle: data.subtitle,
            leading: leading,
            style: data.style == "simple" ? .simple : .standard
        )
    }

    private func mapBarcode(_ data: StatusScreenResponse.BodyNode.Data) -> StatusScreenOutput.Barcode? {
        guard let content = data.content,
              let codeFormatted = data.codeFormatted,
              let copyLabel = data.copyLabel,
              let copyFeedback = data.copyFeedback,
              data.title == nil,
              data.subtitle == nil,
              data.imageURL == nil,
              data.leadingType == nil,
              data.leadingValue == nil,
              data.text == nil
        else {
            return nil
        }
        return .init(
            content: content,
            codeFormatted: codeFormatted,
            copyLabel: copyLabel,
            copyFeedback: copyFeedback,
            icon: self.mapIcon(data.icon)
        )
    }

    private func mapMessage(_ data: StatusScreenResponse.BodyNode.Data) -> String? {
        guard let text = data.text,
              data.title == nil,
              data.subtitle == nil,
              data.imageURL == nil,
              data.leadingType == nil,
              data.leadingValue == nil,
              data.content == nil,
              data.codeFormatted == nil,
              data.copyLabel == nil,
              data.copyFeedback == nil,
              data.icon == nil
        else {
            return nil
        }
        return text
    }

    private func mapIcon(_ rawIcon: String?) -> StatusScreenOutput.Icon? {
        switch rawIcon {
        case "COPY": .copy
        default: nil
        }
    }

    private func mapFooter(_ footer: StatusScreenResponse.Footer) throws -> [StatusScreenOutput.FooterButton] {
        return try footer.buttons.map { button in
            let style = self.mapStyle(button.style)
            switch button.action {
            case .back:
                return .init(label: button.label, action: .back, style: style)
            case .openPDF:
                guard let rawURL = button.value, let url = URL(string: rawURL) else {
                    throw StatusScreenContractError.invalidURL
                }
                return .init(label: button.label, action: .openPDF(url), style: style)
            case .changePaymentMethod:
                return .init(label: button.label, action: .changePaymentMethod, style: style)
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
