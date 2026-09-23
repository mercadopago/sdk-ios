//
//  StatusScreenContent.swift
//  MercadoPagoSDK
//

import MPComponents
import MPFoundation
import SwiftUI

struct StatusScreenContent: View {
    let output: StatusScreenOutput
    let onBack: @MainActor @Sendable () -> Void
    let onOpenPDF: @MainActor @Sendable (URL) -> Void
    let onCopy: @MainActor @Sendable () -> Void
    private let feedbackIconSource: MPIconSource

    @Environment(\.checkoutTheme) private var theme: MPTheme

    init(
        output: StatusScreenOutput,
        onBack: @escaping @MainActor @Sendable () -> Void,
        onOpenPDF: @escaping @MainActor @Sendable (URL) -> Void,
        onCopy: @escaping @MainActor @Sendable () -> Void
    ) {
        self.output = output
        self.feedbackIconSource = .remote(url: output.header.iconURL)
        self.onBack = onBack
        self.onOpenPDF = onOpenPDF
        self.onCopy = onCopy
    }

    #if DEBUG
        init(
            output: StatusScreenOutput,
            feedbackIconSource: MPIconSource,
            onBack: @escaping @MainActor @Sendable () -> Void,
            onOpenPDF: @escaping @MainActor @Sendable (URL) -> Void,
            onCopy: @escaping @MainActor @Sendable () -> Void
        ) {
            self.output = output
            self.feedbackIconSource = feedbackIconSource
            self.onBack = onBack
            self.onOpenPDF = onOpenPDF
            self.onCopy = onCopy
        }
    #endif

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    MPFeedback(
                        title: self.output.header.title,
                        iconSource: self.feedbackIconSource
                    )
                    .padding(.horizontal, self.theme.spacings.xtiny)
                    .padding(.top, self.theme.spacings.small)
                    .padding(.bottom, self.theme.spacings.xsmall)

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
            MPListItem(
                leading: self.leading(item.leading),
                contentInfo: .init(
                    title: item.title,
                    description: item.subtitle
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
                onCopy: self.onCopy
            )
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

    private func leading(
        _ leading: StatusScreenOutput.ListItem.Leading?
    ) -> MPListItemLeading? {
        switch leading {
        case let .remoteImage(url):
            return .thumbnail(url)
        case .cardIcon:
            return .image(Image(systemName: "creditcard"))
        case .none:
            return nil
        }
    }

    private func perform(_ action: StatusScreenOutput.FooterButton.Action) {
        switch action {
        case .back:
            self.onBack()
        case let .openPDF(url):
            self.onOpenPDF(url)
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
            case .openPDF:
                return .loud
            }
        }
    }
}
