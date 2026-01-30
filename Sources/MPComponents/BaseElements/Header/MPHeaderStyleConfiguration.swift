//
//  MPHeaderStyleConfiguration.swift
//  MPComponents
//
//  Configuration for MPHeaderStyle.
//

import SwiftUI

/// Configuration passed to `MPHeaderStyle` for rendering.
package struct MPHeaderStyleConfiguration {
    
    // MARK: - Subviews
    
    package struct TrailingActions: View {
        package let body: AnyView
    }
    
    // MARK: - Properties
    
    /// Header title displayed in both main and sub-header contexts.
    package let title: String
    
    /// Action invoked when the back button is pressed.
    package let onBack: () -> Void
    
    /// Optional trailing actions supplied by the parent view.
    package let trailingActions: TrailingActions?
    
    /// Progress of collapse animation (0 = expanded, 1 = collapsed)
    package let collapseProgress: CGFloat
    
    /// Full height of sub-header (for measuring)
    package let subHeaderHeight: CGFloat
    
    /// Visible height of sub-header (after collapse calculation)
    package let subHeaderVisibleHeight: CGFloat
    
    /// Current scroll offset (negative when scrolled down)
    package let scrollOffset: CGFloat
    
    // MARK: - Initialization
    
    @MainActor
    package init(
        title: String,
        onBack: @escaping () -> Void,
        trailingActions: TrailingActions? = nil,
        collapseProgress: CGFloat,
        subHeaderHeight: CGFloat,
        subHeaderVisibleHeight: CGFloat,
        scrollOffset: CGFloat
    ) {
        self.title = title
        self.onBack = onBack
        self.trailingActions = trailingActions
        self.collapseProgress = collapseProgress
        self.subHeaderHeight = subHeaderHeight
        self.subHeaderVisibleHeight = subHeaderVisibleHeight
        self.scrollOffset = scrollOffset
    }
}
