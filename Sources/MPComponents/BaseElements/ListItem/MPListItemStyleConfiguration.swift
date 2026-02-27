//
//  ListItemStyleConfiguration.swift
//  MPComponents
//
//  Created by [Your Name] on [Date].
//

import SwiftUI

package struct MPListItemStyleConfiguration {
    package struct LeftImage: View {
        package let body: AnyView
    }

    package struct Title: View {
        package let body: AnyView
    }

    package struct Header: View {
        package let body: AnyView
    }

    package struct DescriptionText: View {
        package let body: AnyView
    }

    package struct Trailing: View {
        package let body: AnyView
    }

    package let isPressed: Bool
    package let isSelected: Binding<Bool>?
    package let leftImage: LeftImage?
    package let title: Title?
    package let header: Header?
    package let description: DescriptionText?
    package let trailing: Trailing?

    @MainActor
    package init(
        isPressed: Bool = false,
        isSelected: Binding<Bool>? = nil,
        leftImage: (some View)? = nil,
        title: (some View)? = nil,
        header: (some View)? = nil,
        description: (some View)? = nil,
        trailing: (some View)? = nil
    ) {
        self.isPressed = isPressed
        self.isSelected = isSelected
        self.title = title.map { Title(body: AnyView($0)) }
        self.header = header.map { Header(body: AnyView($0)) }
        self.description = description.map { DescriptionText(body: AnyView($0)) }
        self.leftImage = leftImage.map { LeftImage(body: AnyView($0)) }
        self.trailing = trailing.map { Trailing(body: AnyView($0)) }
    }
}

private struct ListItemStyleKey: @preconcurrency EnvironmentKey {
    @MainActor static var defaultValue: (any MPListItemStyle)? = nil
}

extension EnvironmentValues {
    var listItemStyle: (any MPListItemStyle)? {
        get { self[ListItemStyleKey.self] }
        set { self[ListItemStyleKey.self] = newValue }
    }
}


package extension MPListItemStyle {
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedListItemStyle(style: self, configuration: configuration)
    }
}

private struct ResolvedListItemStyle<Style: MPListItemStyle>: View {
    let style: Style
    let configuration: Style.Configuration

    var body: some View {
        style
            .makeBody(configuration: configuration)
    }
}

package extension View {
    /// Sets the style for `ListItem` views within this view.
    /// Outermost caller wins — inner modifiers are ignored if an ancestor already set a style.
    func listItemStyle<S: MPListItemStyle>(_ style: S) -> some View {
        transformEnvironment(\.listItemStyle) { current in
            if current == nil {
                current = style
            }
        }
    }
}
