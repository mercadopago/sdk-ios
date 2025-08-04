//
//  ListItem.swift
//  MPComponents
//
//  Created by [Your Name] on [Date].
//

import SwiftUI
import MPFoundation

/// Defines the content to be displayed on the trailing side of a ListItem.
package enum ListItemTrailingContent: Equatable {
    /// No content is displayed.
    case none
    
    /// A simple text label.
    case text(String)
    
    /// A pill-style badge, using the existing Pill component.
    /// The associated type defaults to `.success`.
    case pill(text: String, type: PillType = .success)
}


package struct ListItem: View {
    @Environment(\.listItemStyle) private var style
    @Environment(\.isEnabled) private var isEnabled: Bool
    @Environment(\.hasError) private var hasError: Bool
    
    let title: String
    let trailingContent: ListItemTrailingContent
    let isSelected: Bool
    let onSelectionChanged: (Bool) -> Void

    package init(
        title: String,
        trailingContent: ListItemTrailingContent = .none,
        isSelected: Bool,
        onSelectionChanged: @escaping (Bool) -> Void
    ) {
        self.title = title
        self.trailingContent = trailingContent
        self.isSelected = isSelected
        self.onSelectionChanged = onSelectionChanged
    }
    
    package var body: some View {        
        let configuration: ListItemStyleConfiguration = .init(
            toggle: toggleView,
            primaryText: titleView,
            secondaryText: secondaryTextView,
            badge: badgeView,
            isSelected: isSelected
        )
        
        AnyView(
            style.makeBody(configuration: configuration)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if isEnabled { self.onSelectionChanged(true) }
        }
    }
    
    
    @ViewBuilder
    private var titleView: some View {
        Text(title)
            .textStyle(.bodyMediumRegular())

    }
    
    @ViewBuilder
    private var secondaryTextView: some View {
        if case .text(let text) = trailingContent {
            Text(text)
                .textStyle(.bodyMediumRegular(colorType: .secondary))
        }
    }
    
    @ViewBuilder
    private var badgeView: some View {
        if case .pill(let text, let type) = trailingContent {
            Text(text)
                .textStyle(.badge(type))
        }
    }
    
    @ViewBuilder
    private var toggleView: some View {
        Toggle(
            "",
            isOn: Binding(
                get: { self.isSelected },
                set: { _ in
                    if isEnabled {
                        self.onSelectionChanged(true)
                    }
                }
            )
        )
        .toggleStyle(.radio)
        .labelsHidden()
    }
}


#Preview {
    VStack(spacing: 16) {
        // Basic list item without trailing content
        ListItem(title: "Text", isSelected: true) { _ in
            print("tap basic")
        }
        
        // Selected item with text trailing content
        ListItem(title: "Text", trailingContent: .text("Text"), isSelected: false) {_ in 
            print("tap")
        }
        
        // Item with pill badge
        ListItem(
            title: "Text",
            trailingContent: .pill(text: "Label"),
            isSelected: false
        ) {_ in 
            print("tap")
        }
    }
    .padding()
    .loadMPFonts()
}


