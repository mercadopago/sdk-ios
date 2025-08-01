//
//  ListItemStyleConfiguration.swift
//  MPComponents
//
//  Created by [Your Name] on [Date].
//

import SwiftUI

public struct ListItemStyleConfiguration {
    public struct Toggle: View {
        public let body: AnyView
    }
    
    public struct PrimaryText: View {
        public let body: AnyView
    }
    
    public struct SecondaryText: View {
        public let body: AnyView
    }
    
    public struct Badge: View {
        public let body: AnyView
    }
    
    public let state: ListItemState

    public let toggle: Toggle
    public let primaryText: PrimaryText
    public let secondaryText: SecondaryText?
    public let badge: Badge?
    public let isSelected: Bool
    
    @MainActor
    public init(
        toggle: some View,
        primaryText: some View,
        secondaryText: (some View)? = nil,
        badge: (some View)? = nil,
        isSelected: Bool,
        state: ListItemState = .unselected
    ) {
        self.toggle = Toggle(body: AnyView(toggle))
        self.primaryText = PrimaryText(body: AnyView(primaryText))
        self.secondaryText = secondaryText.map { SecondaryText(body: AnyView($0)) }
        self.badge = badge.map { Badge(body: AnyView($0)) }
        self.isSelected = isSelected
        self.state = state
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

public extension View {
    /// Sets the style for `ListItem` views within this view.
    ///
    /// - Parameter style: The `ListItemStyle` to apply.
    func listItemStyle<S: ListItemStyle>(_ style: S) -> some View {
        environment(\.listItemStyle, style)
    }
}
