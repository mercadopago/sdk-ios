//
//  ListItemStyleConfiguration.swift
//  MPComponents
//
//  Created by [Your Name] on [Date].
//

import SwiftUI

package struct ListItemStyleConfiguration {
    package struct Toggle: View {
        public let body: AnyView
    }
    
    package struct PrimaryText: View {
        public let body: AnyView
    }
    
    package struct SecondaryText: View {
        public let body: AnyView
    }
    
    package struct Badge: View {
        public let body: AnyView
    }
    
    package let toggle: Toggle
    package let primaryText: PrimaryText
    package let secondaryText: SecondaryText?
    package let badge: Badge?
    package let isSelected: Bool
    
    @MainActor
    package init(
        toggle: some View,
        primaryText: some View,
        secondaryText: (some View)? = nil,
        badge: (some View)? = nil,
        isSelected: Bool
    ) {
        self.toggle = Toggle(body: AnyView(toggle))
        self.primaryText = PrimaryText(body: AnyView(primaryText))
        self.secondaryText = secondaryText.map { SecondaryText(body: AnyView($0)) }
        self.badge = badge.map { Badge(body: AnyView($0)) }
        self.isSelected = isSelected
    }
}



private struct ListItemStyleKey: @preconcurrency EnvironmentKey {
    @MainActor static var defaultValue: any ListItemStyle = DefaultListItemStyle()
}

extension EnvironmentValues {
    var listItemStyle: any ListItemStyle {
        get { self[ListItemStyleKey.self] }
        set { self[ListItemStyleKey.self] = newValue }
    }
}

package extension View {
    /// Sets the style for `ListItem` views within this view.
    ///
    /// - Parameter style: The `ListItemStyle` to apply.
    func listItemStyle<S: ListItemStyle>(_ style: S) -> some View {
        environment(\.listItemStyle, style)
    }
}
