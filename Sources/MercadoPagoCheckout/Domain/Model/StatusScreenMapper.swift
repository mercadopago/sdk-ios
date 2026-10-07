//
//  StatusScreenMapper.swift
//  MercadoPagoSDK
//

import Foundation
import MPFoundation

struct StatusScreenMapper: Sendable {
    private typealias Strings = MPStrings.StatusScreenFallback

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

    func map(
        _ processData: OrderTransactionProcessData,
        lastFourDigits: String?,
        paymentMethodName: String? = nil
    ) -> StatusScreenOutput? {
        // `rejected` belongs to the Error Status Screen and is deliberately not mapped here.
        guard let payment = processData.payments.first, payment.status != "rejected" else { return nil }
        let amount = payment.amount ?? processData.totalAmount

        switch self.fallbackScenario(for: payment) {
        case .approved:
            let isDebit = payment.paymentTypeId == "debit_card"
            let paidAmount = processData.totalPaidAmount ?? amount
            return StatusScreenOutput(
                statusType: "approved",
                header: .init(
                    title: Strings.approvedTitle(self.formattedAmount(paidAmount)),
                     tone: .positive
                ),
                body: [.listItem(.init(
                    title: self.paymentMethodTitle(payment.paymentMethodId, lastFourDigits: lastFourDigits),
                    subtitle: self.approvedSubtitle(
                        installments: isDebit ? nil : payment.installments,
                        paidAmount: processData.totalPaidAmount,
                        fallbackAmount: amount,
                        orderTotal: processData.totalAmount
                    ),
                    leading: nil,
                    style: .simple
                ))],
                footerButtons: [self.backButton()]
            )
        case .ticket:
            let methodName = paymentMethodName ?? self.capitalizedFirst(payment.paymentMethodId)
            var body: [StatusScreenOutput.BodyComponent] = []
            if let barcode = payment.barcodeContent, !barcode.isEmpty {
                body.append(.barcode(.init(
                    content: barcode,
                    codeFormatted: barcode,
                    copyLabel: Strings.ticketCodeLabel,
                    copyFeedback: Strings.copyFeedback,
                    icon: .copy
                )))
            }
            // The primary action comes first, "back" is the quiet one below it.
            var footer: [StatusScreenOutput.FooterButton] = []
            if let ticketURL = (payment.ticketURL ?? payment.redirectURL).flatMap(URL.init(string:)) {
                footer.append(.init(label: Strings.openTicket, action: .openPDF(ticketURL), style: .loud))
            }
            footer.append(self.backButton())
            return StatusScreenOutput(
                statusType: "pending",
                header: .init(
                    title: Strings.ticketTitle(amount: self.formattedAmount(amount), method: methodName),
                     tone: .positive
                ),
                body: body,
                footerButtons: footer
            )
        case .pending:
            return StatusScreenOutput(
                statusType: "pending",
                header: .init(title: Strings.pendingTitle, tone: .pending),
                // The Figma pending screen has no body and no description.
                body: [],
                footerButtons: [self.backButton()]
            )
        }
    }

    private enum FallbackScenario {
        case approved, ticket, pending
    }

    private func fallbackScenario(for payment: OrderTransactionProcessData.Payment) -> FallbackScenario {
        switch payment.status {
        case "processed": .approved
        case "action_required": .ticket
        default: .pending
        }
    }

    private func paymentMethodTitle(_ methodId: String, lastFourDigits: String?) -> String {
        let name = self.capitalizedFirst(methodId)
        guard let lastFourDigits, !lastFourDigits.isEmpty else { return name }
        return "\(name) •••• \(lastFourDigits)"
    }

    private func approvedSubtitle(
        installments: Int?,
        paidAmount: String?,
        fallbackAmount: String,
        orderTotal: String
    ) -> String {
        guard let count = installments, count > 1,
              let paidRaw = paidAmount, let paid = Double(paidRaw)
        else {
            return self.formattedAmount(paidAmount ?? fallbackAmount)
        }
        let isInterestFree = Double(orderTotal).map { paid <= $0 + 0.005 } ?? false
        return Strings.installments(
            count,
            amount: MPStrings.formatPrice(paid / Double(count)),
            total: self.formattedAmount(paidRaw),
            hasInterest: !isInterestFree
        )
    }

    private func capitalizedFirst(_ value: String) -> String {
        value.prefix(1).uppercased() + value.dropFirst()
    }

    private func backButton() -> StatusScreenOutput.FooterButton {
        .init(label: MPStrings.StatusScreenFallback.back, action: .back, style: .transparent)
    }

    private func formattedAmount(_ raw: String) -> String {
        Double(raw).map(MPStrings.formatPrice) ?? raw
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

// MARK: - Failed /process
extension StatusScreenMapper {
    func mapProcessFailure() -> StatusScreenOutput {
        StatusScreenOutput(
            statusType: "rejected",
            header: .init(title: Strings.rejectedTitle, tone: .negative),
            body: [],
            footerButtons: [self.backButton()]
        )
    }
}
