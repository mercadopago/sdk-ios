//
//  MPFooter.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 24/11/25.
//

import SwiftUI
import MPFoundation

/// A footer component that displays payment summary information such as total amount and payment method details.
/// ## Usage
///
/// ```swift
/// MPFooter(
///     label: "Total",
///     amount: "R$ 500",
///     description: "Santander Crédito **** 4561"
///     buttonLabel: "Pay",
///     action: {
///       print("action")
///     }
/// )
/// ```
///
package struct MPFooter: View {
    
    // MARK: - Properties
    
    private let title: String
    private let amount: MPAmountData?
    private let subtitle: String?
    private let buttonLabel: String?
    private let action: (() -> Void)?
    
    // MARK: - Environment
    
    @Environment(\.mpFooterStyle) private var style: any MPFooterStyle
    @Environment(\.checkoutTheme) var theme: MPTheme
    
    // MARK: - Initialization
    
    /// Creates a new footer with the specified configuration.
    ///
    /// - Parameters:
    ///   - title: The label to display on the left (e.g., "Total")
    ///   - amount: The amount value to display on the right
    ///   - subtitle: Optional description to display on the right below
    package init(
        title: String = String(),
        amount: MPAmountData? = nil,
        subtitle: String? = nil,
        buttonLabel: String,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.amount = amount
        self.subtitle = subtitle
        self.buttonLabel = buttonLabel
        self.action = action
    }
    
    package init(
        title: String,
        amount: MPAmountData? = nil,
        description: String? = nil
    ) {
        self.title = title
        self.amount = amount
        self.subtitle = description
        self.buttonLabel = nil
        self.action = nil
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
            style.resolve(configuration: configuration)
        )
    }
    
    // MARK: - Summary Line View
    
    @ViewBuilder
    private var summaryLineView: some View {
        if let amount {
            HStack(alignment: .center, spacing: theme.spacings.xtiny) {
                // Label
                Text(title)
                    .textStyle(.largeEmphasis())
                    .lineLimit(1)
                
                Spacer()
                
                // Amount
                amountView
            }
            .accessibilityElement(children: .ignore)
            .accessibility(label: Text("\(title) \(amount)"))
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
        if let action, let buttonLabel {
            Button {
                action()
            } label: {
                Text(buttonLabel)
            }
        }
    }
    
    @ViewBuilder
    private var amountView: some View {
        if let amount {
            HStack(alignment: .top, spacing: theme.spacings.xnano) {
                Text(amount.currencySymbol)
                    .textStyle(.largeEmphasis())
                    .foregroundColor(theme.colors.text.primary)
                    .lineLimit(1)
                Text(amount.integerPart)
                    .textStyle(.largeEmphasis())
                    .foregroundColor(theme.colors.text.primary)
                    .lineLimit(1)
                VStack(alignment: .leading) {
                    Text(amount.decimalPart)
                        .textStyle(.smallMediumEmphasis())
                        .foregroundColor(theme.colors.text.primary)
                        .lineLimit(1)
                    Spacer()
                }
                .fixedSize()
            }
        }
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
                buttonLabel: MPStrings.CardForm.button,
                action: {
                    print("button action")
                }
            )
            .disabled(true)
            
            // Footer without description
            MPFooter(
                title: "Total",
                amount: .init(currencySymbol: "R$", integerPart: "1.250", decimalPart: "00"),
                buttonLabel: MPStrings.CardForm.button,
                action: {
                    print("button action")
                }
            )
        }
        .loadMPFonts()
    }
}
#endif


package struct MPAmountData {
    var currencySymbol: String
    var integerPart: String
    var decimalPart: String
}
