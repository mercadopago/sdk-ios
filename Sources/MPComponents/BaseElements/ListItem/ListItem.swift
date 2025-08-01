//
//  ListItem.swift
//  MPComponents
//
//  Created by [Your Name] on [Date].
//

import SwiftUI
import MPFoundation

public struct ListItem: View {
    @Environment(\.listItemStyle) private var style
    
    let title: String
    let state: ListItemState
    let trailingContent: ListItemTrailingContent
    let onTap: () -> Void

    public init(
        title: String,
        state: ListItemState,
        trailingContent: ListItemTrailingContent = .none,
        onTap: @escaping () -> Void
    ) {
        self.title = title
        self.state = state
        self.trailingContent = trailingContent
        self.onTap = onTap
    }
    
    public var body: some View {        
        let configuration: ListItemStyleConfiguration = .init(
            toggle: toggleView,
            primaryText: titleView,
            secondaryText: secondaryTextView,
            badge: badgeView,
            isSelected: state.isOn,
            state: state
        )
        
        AnyView(
            style.makeBody(configuration: configuration)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if self.state != .disabled { self.onTap() }
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
                get: { self.state.isOn },
                set: { _ in
                    if self.state != .disabled { self.onTap() }
                }
            )
        )
        .toggleStyle(.radio(state: self.state.radioState))
        .labelsHidden()
    }
}


#Preview {
    VStack(spacing: 16) {
        // Basic list item without trailing content
        ListItem(title: "Text", state: .unselected) {
            print("tap basic")
        }
        
        // Selected item with text trailing content
        ListItem(title: "Text", state: .selected, trailingContent: .text("Text")) {
            print("tap")
        }
        
        // Item with pill badge
        ListItem(
            title: "Text",
            state: .unselected,
            trailingContent: .pill(text: "Label")
        ) {
            print("tap")
        }
    }
    .padding()
    .loadMPFonts()
}


