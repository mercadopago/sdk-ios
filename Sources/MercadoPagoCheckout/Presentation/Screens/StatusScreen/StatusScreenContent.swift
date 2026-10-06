//
//  StatusScreenContent.swift
//  MercadoPagoSDK
//

import MPComponents
import MPFoundation
import SwiftUI

struct StatusScreenContent: View {
    let output: StatusScreenOutput
    let isPreparingReceipt: Bool
    let onBack: @MainActor @Sendable () -> Void
    let onChangePaymentMethod: @MainActor @Sendable () -> Void
    let onOpenPDF: @MainActor @Sendable (URL) -> Void

    @Environment(\.checkoutTheme) private var theme: MPTheme

    init(
        output: StatusScreenOutput,
        isPreparingReceipt: Bool,
        onBack: @escaping @MainActor @Sendable () -> Void,
        onChangePaymentMethod: @escaping @MainActor @Sendable () -> Void,
        onOpenPDF: @escaping @MainActor @Sendable (URL) -> Void
    ) {
        self.output = output
        self.isPreparingReceipt = isPreparingReceipt
        self.onBack = onBack
        self.onChangePaymentMethod = onChangePaymentMethod
        self.onOpenPDF = onOpenPDF
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    self.headerFeedback
                    .padding(.horizontal, self.theme.spacings.xtiny)
                    .padding(.top, self.theme.spacings.small)
                    .padding(.bottom, self.theme.spacings.xsmall)

                    if let subtitle = self.output.header.subtitle {
                        Text(subtitle)
                            .textStyle(.bodyMedium())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, self.theme.spacings.xtiny)
                            .padding(.bottom, self.theme.spacings.xsmall)
                    }

                    self.statusScreenBody
                }
            }

            self.statusScreenFooter
        }
        .background(self.theme.colors.background.primary.edgesIgnoringSafeArea(.all))
    }

    @ViewBuilder
    private var statusScreenBody: some View {
        VStack(spacing: self.theme.spacings.micro) {
            ForEach(Array(self.output.body.enumerated()), id: \.offset) { _, component in
                self.statusScreenBodyComponent(component)
            }
        }
    }

    @ViewBuilder
    private func statusScreenBodyComponent(
        _ component: StatusScreenOutput.BodyComponent
    ) -> some View {
        switch component {
        case let .listItem(item):
            self.applyingStyle(
                item.style,
                to: MPListItem(
                    leading: self.leading(item.leading),
                    contentInfo: .init(
                        title: item.title,
                        description: item.subtitle
                    )
                )
            )
            .mpThumbnailStyle(.thumbnailCircle)
            .padding(.horizontal, self.theme.spacings.xnano)
            .accessibilityElement(children: .combine)
        case let .barcode(barcode):
            MPBarcode(
                content: barcode.content,
                codeFormatted: barcode.codeFormatted,
                copyLabel: barcode.copyLabel,
                copyFeedback: barcode.copyFeedback,
                icon: barcode.icon.map(self.localIcon)
            )
            .padding(.horizontal, self.theme.spacings.xtiny)
        case let .message(text):
            Text(text)
                .textStyle(.bodyMedium())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, self.theme.spacings.xtiny)
        }
    }

    @ViewBuilder
    private var statusScreenFooter: some View {
        if !self.output.footerButtons.isEmpty {
            VStack(spacing: self.theme.spacings.xmicro) {
                ForEach(Array(self.output.footerButtons.enumerated()), id: \.offset) { index, button in
                    Button(button.label) {
                        self.perform(button.action)
                    }
                    .isLoading(self.isPreparingReceipt && button.action != .back)
                    .mpButtonStyle(variant: self.variant(for: button))
                    .accessibility(
                        identifier: self.accessibilityIdentifier(for: button.action, index: index)
                    )
                }
            }
            .padding(.horizontal, self.theme.spacings.xtiny)
            .padding(.vertical, self.theme.spacings.xtiny)
            .background(self.theme.colors.background.primary)
        }
    }

    @ViewBuilder
    private func applyingStyle(
        _ style: StatusScreenOutput.ListItem.Style,
        to row: some View
    ) -> some View {
        switch style {
        case .standard:
            row
        case .simple:
            row.listItemStyle(.simple)
        }
    }

    private func leading(
        _ leading: StatusScreenOutput.ListItem.Leading?
    ) -> MPListItemLeading? {
        switch leading {
        case let .remoteImage(url):
            return .thumbnail(url)
        case .cardIcon:
            return .image(Image(systemName: "creditcard"))
        case .billIcon:
            return .image(Image(Logos.Icon.bill.assetName, bundle: .bundleMP))
        case .none:
            return nil
        }
    }

    @ViewBuilder
    private var headerFeedback: some View {
        switch self.output.header.icon {
        case let .remote(url):
            MPFeedback(title: self.output.header.title, iconSource: .remote(url: url))
        case let .badge(tone):
            VStack(alignment: .leading, spacing: self.theme.spacings.xtiny) {
                Circle()
                    .fill(self.badgeColor(for: tone))
                    .frame(width: 72, height: 72)
                    .overlay(
                        Image(self.badgeGlyph(for: tone).assetName, bundle: .bundleMP)
                            .resizable()
                            .frame(width: 56, height: 56)
                    )
                    .accessibility(hidden: true)
                Text(self.output.header.title)
                    .textStyle(.headingHuge())
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .accessibilityElement(children: .combine)
        }
    }

    private func badgeGlyph(for tone: StatusScreenOutput.Header.Tone) -> Logos.Icon {
        switch tone {
        case .positive: return .statusCheck
        case .pending: return .statusMinus
        case .negative: return .statusExclamation
        }
    }

    private func badgeColor(for tone: StatusScreenOutput.Header.Tone) -> Color {
        switch tone {
        case .positive: return self.theme.colors.feedback.fillPositiveLoud
        case .pending: return self.theme.colors.feedback.fillCautionLoud
        case .negative: return self.theme.colors.feedback.fillNegativeLoud
        }
    }

    private func localIcon(_ icon: StatusScreenOutput.Icon) -> Logos.Icon {
        switch icon {
        case .copy:
            return .copy
        }
    }

    private func perform(_ action: StatusScreenOutput.FooterButton.Action) {
        switch action {
        case .back:
            self.onBack()
        case let .openPDF(url):
            self.onOpenPDF(url)
        case .changePaymentMethod:
            self.onChangePaymentMethod()
        }
    }

    private func accessibilityIdentifier(
        for action: StatusScreenOutput.FooterButton.Action,
        index: Int
    ) -> String {
        let actionName = switch action {
        case .back:
            "back"
        case .openPDF:
            "open_pdf"
        case .changePaymentMethod:
            "change_payment_method"
        }
        return "mp.status_screen.\(actionName).\(index)"
    }

    private func variant(
        for button: StatusScreenOutput.FooterButton
    ) -> MPButtonStyle.Variant {
        switch button.style {
        case .loud:
            return .loud
        case .quiet:
            return .quiet
        case .transparent:
            return .transparent
        case nil:
            switch button.action {
            case .back:
                return .quiet
            case .openPDF, .changePaymentMethod:
                return .loud
            }
        }
    }
}
