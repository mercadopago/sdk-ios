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
    
    private let label: String
    private let amount: String
    private let description: String?
    private let buttonLabel: String
    private let action: () -> Void
    
    // MARK: - Environment
    
    @Environment(\.mpFooterStyle) private var style: any MPFooterStyle
    @Environment(\.checkoutTheme) var theme: MPTheme
    
    // MARK: - Initialization
    
    /// Creates a new footer with the specified configuration.
    ///
    /// - Parameters:
    ///   - label: The label to display on the left (e.g., "Total")
    ///   - amount: The amount value to display on the right
    ///   - description: Optional description to display on the right below
    package init(
        label: String,
        amount: String,
        description: String? = nil,
        buttonLabel: String,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.amount = amount
        self.description = description
        self.buttonLabel = buttonLabel
        self.action = action
    }
    
    // MARK: - Body
    
    package var body: some View {
        let configuration = MPFooterStyleConfiguration(
            summaryLine: summaryLineView,
            descriptionLine: descriptionLineView,
            button: button,
            hasDescription: description != nil
        )
        
        return AnyView(
            style.resolve(configuration: configuration)
        )
    }
    
    // MARK: - Summary Line View
    
    @ViewBuilder
    private var summaryLineView: some View {
        HStack(alignment: .center, spacing: theme.spacings.xtiny) {
            // Label
            Text(label)
                .textStyle(.largeEmphasis())
                .lineLimit(1)
            
            Spacer()
            
            // Amount
            Text(amount)
                .textStyle(.largeEmphasis())
                .foregroundColor(theme.colors.text.primary)
                .lineLimit(1)
        }
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text("\(label) \(amount)"))
    }
    
    // MARK: - Description Line View
    
    @ViewBuilder
    private var descriptionLineView: some View {
        if let descriptionText = description {
            HStack {
                Spacer()
                
                Text(descriptionText)
                    .textStyle(.bodyMedium())
                    .lineLimit(1)
            }
        }
    }
    
    private var button: some View {
        Button {
            action()
        } label: {
            Text(buttonLabel)
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
                label: "Total",
                amount: "R$ 500",
                description: "Santander Crédito **** 4561",
                buttonLabel: MPStrings.CardForm.button,
                action: {
                    print("button action")
                }
            )
            .disabled(true)
            
            // Footer without description
            MPFooter(
                label: "Total",
                amount: "R$ 1.250,00",
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
