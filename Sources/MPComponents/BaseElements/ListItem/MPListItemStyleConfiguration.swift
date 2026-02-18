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
    
    package struct TextRight: View {
        package let body: AnyView
    }
    
    package struct SelectedButton: View {
        package let body: AnyView
    }
    
    package struct RightContent: View {
        package let body: AnyView
    }
    
    package let leftImage: LeftImage?
    package let title: Title?
    package let header: Header?
    package let description: DescriptionText?
    package let textRight: TextRight?
    package let rightContent: RightContent?
    package let selectedButton: SelectedButton?
    package let radioButtonConfig: MPRadioButtonConfiguration?
    
    @MainActor
    package init(
        leftImage: (some View)? = nil,
        title: (some View)? = nil,
        header: (some View)? = nil,
        description: (some View)? = nil,
        textRight: (some View)? = nil,
        rightContent: (some View)? = nil,
        selectedButton: (some View)? = nil,
        radioButtonConfig: MPRadioButtonConfiguration? = nil,
    ) {
        self.title = title.map { Title(body: AnyView($0)) }
        self.header = header.map { Header(body: AnyView($0)) }
        self.description = description.map { DescriptionText(body: AnyView($0)) }
        self.leftImage = leftImage.map { LeftImage(body: AnyView($0)) }
        self.textRight = textRight.map { TextRight(body: AnyView($0)) }
        self.selectedButton = selectedButton.map { SelectedButton(body: AnyView($0)) }
        self.rightContent = rightContent.map { RightContent(body: AnyView($0)) }
        self.radioButtonConfig = radioButtonConfig
    }
}

private struct ListItemStyleKey: @preconcurrency EnvironmentKey {
    @MainActor static var defaultValue: any MPListItemStyle = MPDefaultListItemStyle()
}

extension EnvironmentValues {
    var listItemStyle: any MPListItemStyle {
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
    ///
    /// - Parameter style: The `ListItemStyle` to apply.
    func listItemStyle<S: MPListItemStyle>(_ style: S) -> some View {
        environment(\.listItemStyle, style)
    }
}
