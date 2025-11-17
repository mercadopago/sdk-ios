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
    
    package struct MainHeader: View {
        package let body: AnyView
    }
    
    package struct SubHeader: View {
        package let body: AnyView
    }
    
    // MARK: - Properties
    
    /// Main header view (with back button, title, and trailing actions)
    package let mainHeader: MainHeader
    
    /// Sub-header view (large collapsible title)
    package let subHeader: SubHeader
    
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
        mainHeader: some View,
        subHeader: some View,
        collapseProgress: CGFloat,
        subHeaderHeight: CGFloat,
        subHeaderVisibleHeight: CGFloat,
        scrollOffset: CGFloat
    ) {
        self.mainHeader = MainHeader(body: AnyView(mainHeader))
        self.subHeader = SubHeader(body: AnyView(subHeader))
        self.collapseProgress = collapseProgress
        self.subHeaderHeight = subHeaderHeight
        self.subHeaderVisibleHeight = subHeaderVisibleHeight
        self.scrollOffset = scrollOffset
    }
}

