//
//  MPFooter.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 24/11/25.
//

import MPFoundation
import SwiftUI

/// A footer component that displays payment summary information such as total amount and payment method details.
/// ## Usage
///
/// ```swift
/// MPFooter(
///     title: "Total",
///     amount: .init(currencySymbol: "R$", integerPart: "500", decimalPart: "00"),
///     subtitle: "Santander Crédito **** 4561",
///     buttonData: .init(text: "Pay") {
///         print("action")
///     }
/// )
/// ```
///
package struct MPFooter: View {
    // MARK: - Properties

    private let title: String
    private let amount: MPAmountData?
    private let subtitle: String?
    private let buttonData: MPFixedFooterButtonData?

    // MARK: - Environment

    @Environment(\.mpFooterStyle) private var style: any MPFooterStyle
    @Environment(\.checkoutTheme) var theme: MPTheme

    // MARK: - Tasks

    @State private var submitTask: Task<Void, Never>?

    // MARK: - Initialization

    /// Creates a new footer with the specified configuration.
    ///
    /// - Parameters:
    ///   - title: Label displayed on the left side of the summary line (e.g., "Total").
    ///   - amount: Structured amount displayed on the right side. Pass `nil` to hide the summary line entirely.
    ///   - subtitle: Optional text displayed below the summary line, right-aligned (e.g., selected card info).
    ///   - buttonData: Optional call-to-action button configuration. The button is hidden when `isEnabled` is `false`.
    package init(
        title: String = String(),
        amount: MPAmountData? = nil,
        subtitle: String? = nil,
        buttonData: MPFixedFooterButtonData? = nil
    ) {
        self.title = title
        self.amount = amount
        self.subtitle = subtitle
        self.buttonData = buttonData
    }

    package init(
        title: String,
        amount: MPAmountData? = nil,
        subtitle: String? = nil
    ) {
        self.title = title
        self.amount = amount
        self.subtitle = subtitle
        self.buttonData = nil
    }

    // MARK: - Body

    package var body: some View {
        let configuration = MPFooterStyleConfiguration(
            summaryLine: summaryLineView,
            descriptionLine: descriptionLineView,
            button: button,
            hasDescription: subtitle != nil
        )

        return AnyView(
            self.style.resolve(configuration: configuration)
        )
    }

    // MARK: - Summary Line View

    @ViewBuilder
    private var summaryLineView: some View {
        if !self.title.isEmpty, self.amount != nil {
            HStack(alignment: .center, spacing: self.theme.spacings.xtiny) {
                // Label
                Text(self.title)
                    .textStyle(.largeEmphasis())
                    .lineLimit(1)

                Spacer()

                // Amount
                self.amountView
            }
            .accessibilityElement(children: .ignore)
            .accessibility(label: Text(self.createAccessibilityLabel()))
        }
    }

    // MARK: - Description Line View

    @ViewBuilder
    private var descriptionLineView: some View {
        if let descriptionText = subtitle {
            HStack {
                Spacer()

                Text(descriptionText)
                    .textStyle(.bodyMedium(colorType: .secondary))
                    .lineLimit(1)
            }
        }
    }

    @ViewBuilder
    private var button: some View {
        if let buttonData {
            Button {
                Task {
                    await buttonData.onClick()
                }
            } label: {
                HStack(spacing: self.theme.spacings.xmicro) {
                    if let icon = buttonData.icon {
                        MPIcon(
                            source: .asset(name: icon.assetName),
                            size: .medium,
                            color: .inverse,
                            isDecorative: true
                        )
                    }
                    Text(buttonData.text)
                }
            }
            .mpButtonStyle(variant: buttonData.style)
            .accessibility(identifier: "mp.footer.primary")
            .onDisappear {
                self.submitTask?.cancel()
            }
        }
    }

    @ViewBuilder
    private var amountView: some View {
        if let amount {
            HStack(alignment: .top, spacing: self.theme.spacings.xnano) {
                Text(amount.currencySymbol)
                    .textStyle(.largeEmphasis())
                    .foregroundColor(self.theme.colors.text.primary)
                    .lineLimit(1)
                Text(amount.integerPart)
                    .textStyle(.largeEmphasis())
                    .foregroundColor(self.theme.colors.text.primary)
                    .lineLimit(1)
                if !amount.decimalPart.isEmpty {
                    VStack(alignment: .leading) {
                        Text(amount.decimalPart)
                            .textStyle(.smallMediumEmphasis())
                            .foregroundColor(self.theme.colors.text.primary)
                            .lineLimit(1)
                        Spacer()
                    }
                    .fixedSize()
                }
            }
        }
    }

    private func createAccessibilityLabel() -> String {
        guard let amount else { return self.title }
        if amount.decimalPart.isEmpty {
            return "\(self.title) \(amount.currencySymbol) \(amount.integerPart)"
        }
        return "\(self.title) \(amount.currencySymbol) \(amount.integerPart), \(amount.decimalPart)"
    }
}

// MARK: - Preview

#if DEBUG
    struct MPFooter_Previews: PreviewProvider {
        static var previews: some View {
            VStack(spacing: 20) {
                Spacer()

                // Footer with description
                MPFooter(
                    title: "Total",
                    amount: .init(currencySymbol: "R$", integerPart: "500", decimalPart: "00"),
                    subtitle: "Santander Crédito **** 4561",
                    buttonData: .init(
                        text: MPStrings.CardForm.button,
                        onClick: {
                            print("button action")
                        }
                    )
                )
                .disabled(true)

                // Footer without description
                MPFooter(
                    title: "Total",
                    amount: .init(currencySymbol: "R$", integerPart: "1.250", decimalPart: "00"),
                    buttonData: .init(
                        text: MPStrings.CardForm.button,
                        onClick: {
                            print("button action")
                        }
                    )
                )
            }
            .loadMPFonts()
        }
    }
#endif
