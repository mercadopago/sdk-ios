//
//  MPFooter.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 24/11/25.
//

import SwiftUI
import MPFoundation

/// A footer component that displays payment summary information such as total amount and payment method details.
///
/// The footer consists of two main areas:
/// - **Summary Line**: Displays a label (e.g., "Total") and an amount value
/// - **Description Line**:  Description label
///
/// ## Usage
///
/// ```swift
/// MPFooter(
///     label: "Total",
///     amount: "R$ 500",
///     description: "Santander Crédito **** 4561"
/// )
/// ```
///
package struct MPFooter: View {
    
    // MARK: - Properties
    
    private let label: String
    private let amount: String
    private let description: String?
    
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
        description: String? = nil
    ) {
        self.label = label
        self.amount = amount
        self.description = description
    }
    
    // MARK: - Body
    
    package var body: some View {
        let configuration = MPFooterStyleConfiguration(
            summaryLine: summaryLineView,
            descriptionLine: descriptionLineView,
            hasDescription: description != nil
        )
        
        return AnyView(
            style.makeBody(configuration: configuration)
        )
    }
    
    // MARK: - Summary Line View
    
    @ViewBuilder
    private var summaryLineView: some View {
        HStack(alignment: .center, spacing: theme.spacings.m) {
            // Label
            Text(label)
                .textStyle(.bodyMediumSemibold())
                .lineLimit(1)
            
            Spacer()
            
            // Amount
            Text(amount)
                .textStyle(.titleSmallSemibold())
                .foregroundColor(theme.colors.textPrimary)
                .lineLimit(1)
        }
    }
    
    // MARK: - Description Line View
    
    @ViewBuilder
    private var descriptionLineView: some View {
        if let descriptionText = description {
            HStack {
                Spacer()
                
                Text(descriptionText)
                    .textStyle(.bodySmallRegular())
                    .lineLimit(1)
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
                label: "Total",
                amount: "R$ 500",
                description: "Santander Crédito **** 4561"
            )
            
            // Footer without description
            MPFooter(
                label: "Total",
                amount: "R$ 1.250,00"
            )
        }
        .loadMPFonts()
    }
}
#endif

