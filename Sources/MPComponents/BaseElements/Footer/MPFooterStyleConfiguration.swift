//
//  MPFooterStyleConfiguration.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 24/11/25.
//
import SwiftUI

/// Configuration passed to `MPFooterStyle` for rendering.
package struct MPFooterStyleConfiguration {
    
    // MARK: - Subviews
    
    package struct SummaryLine: View {
        package let body: AnyView
    }
    
    package struct DescriptionLine: View {
        package let body: AnyView
    }
    
    // MARK: - Properties
    
    /// Summary line view (with label and amount)
    package let summaryLine: SummaryLine
    
    /// Description line view (optional card/payment info)
    package let descriptionLine: DescriptionLine
    
    /// Whether the footer has description information
    package let hasDescription: Bool
    
    // MARK: - Initialization
    
    @MainActor
    package init(
        summaryLine: some View,
        descriptionLine: some View,
        hasDescription: Bool
    ) {
        self.summaryLine = SummaryLine(body: AnyView(summaryLine))
        self.descriptionLine = DescriptionLine(body: AnyView(descriptionLine))
        self.hasDescription = hasDescription
    }
}

