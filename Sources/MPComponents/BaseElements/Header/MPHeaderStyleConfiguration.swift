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

    /// Header title.
    package let title: String

    /// Action invoked when the back button is pressed.
    package let onBack: () -> Void

    /// Optional trailing actions on the right side.
    package let trailingActions: TrailingActions?

    /// Current scroll offset (negative when scrolled down). Used for background styling.
    package let scrollOffset: CGFloat

    /// Opacity for the inline title next to the back button (0 = hidden, 1 = fully visible).
    /// Increases as the large title in scroll content disappears.
    package let inlineTitleOpacity: CGFloat

    // MARK: - Initialization

    @MainActor
    package init(
        title: String,
        onBack: @escaping () -> Void,
        trailingActions: TrailingActions? = nil,
        scrollOffset: CGFloat,
        inlineTitleOpacity: CGFloat = 0
    ) {
        self.title = title
        self.onBack = onBack
        self.trailingActions = trailingActions
        self.scrollOffset = scrollOffset
        self.inlineTitleOpacity = inlineTitleOpacity
    }
}
