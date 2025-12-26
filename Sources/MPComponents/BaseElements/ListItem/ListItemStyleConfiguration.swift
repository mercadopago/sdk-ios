//
//  ListItemStyleConfiguration.swift
//  MPComponents
//
//  Created by [Your Name] on [Date].
//

import SwiftUI

package struct ListItemStyleConfiguration {
    package struct LeftImage: View {
        package let body: AnyView
    }
    
    package struct Title: View {
        package let body: AnyView
    }
    
    package struct DescriptionText: View {
        package let body: AnyView
    }
    
    package struct TextRight: View {
        package let body: AnyView
    }
    
    package let leftImage: LeftImage?
    package let title: Title
    package let description: DescriptionText?
    package let textRight: TextRight?
    package let hasChevron: Bool
    package let isSelected: Bool
    
    @MainActor
    package init(
        leftImage: (some View)? = nil,
        title: some View,
        description: (some View)? = nil,
        textRight: (some View)? = nil,
        hasChevron: Bool,
        isSelected: Bool = false
    ) {
        self.title = Title(body: AnyView(title))
        self.description = description.map { DescriptionText(body: AnyView($0)) }
        self.leftImage = leftImage.map { LeftImage(body: AnyView($0)) }
        self.textRight = textRight.map { TextRight(body: AnyView($0)) }
        self.hasChevron = hasChevron
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


package extension ListItemStyle {
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedListItemStyle(style: self, configuration: configuration)
    }
}

private struct ResolvedListItemStyle<Style: ListItemStyle>: View {
    let style: Style
    let configuration: Style.Configuration

    var body: some View {
        style
            .makeBody(configuration: configuration)
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
