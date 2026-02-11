//
//  MPListItem.swift
//  MPComponents
//
//  Created by [Your Name] on [Date].
//

import SwiftUI
import MPFoundation

package struct MPListItem: View {
    
    package enum MPListItemType {
        case radioButton(selected: Bool)
        case none
    }
    
    @Environment(\.listItemStyle) private var style
    
    let type: MPListItemType?
    let leftImage: Image?
    let title: String
    let description: String?
    let trailing: MPListItemTrailing?
    let state: MPListItemState
    var onClick: (() -> Void)?
    
    package init(
        title: String,
        description: String? = nil,
        trailing: MPListItemTrailing? = nil,
        leftImage: Image? = nil,
        type: MPListItemType? = nil,
        state: MPListItemState = .idle,
        onClick: (() -> Void)? = nil
    ) {
        self.type = type
        self.leftImage = leftImage
        self.title = title
        self.description = description
        self.trailing = trailing
        self.state = state
        self.onClick = onClick
    }
    
    package var body: some View {        
        let configuration: MPListItemStyleConfiguration = .init(
            leftImage: leftImageView,
            title: titleView,
            description: descriptionView,
            textRight: textRightView,
            rightContent: rightContent,
            selectedButton: selectedButton,
            state: state
        )
        
        AnyView(
            style.resolve(configuration: configuration)
        )
    }
    
    @ViewBuilder
    private var titleView: some View {
        Text(title)
            .textStyle(.bodyMediumTitle())
    }
    
    @ViewBuilder
    private var descriptionView: some View {
        if let description {
            Text(description)
                .textStyle(.bodyMedium())
        }
    }
    
    @ViewBuilder
    private var textRightView: some View {
        if let text = trailing?.text {
            Text(text)
                .textStyle(.bodyMedium(colorType: trailing?.color ?? .primary))
        }
    }
    
    @ViewBuilder
    private var leftImageView: some View {
        leftImage
    }

    @ViewBuilder
    private var selectedButton: some View {
        if let onClick {
            Button {
                onClick()
            } label: {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
    
    @ViewBuilder
    private var rightContent: some View {
        if let content = trailing?.type {
            switch content {
            case .icon(let image):
                image
            case .none:
                EmptyView()
            }
        }
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 16) {
        // Idle state
        MPListItem(
            title: "Title",
            description: "Description",
            trailing: .init(
                text: "$ 1,000.00",
                type: .icon(Image(systemName: "chevron.right"))
            ),
            leftImage: Image(systemName: "creditcard"),
            state: .idle,
            onClick: {
                print("on click")
            }
        )
        
        MPListItem(
            title: "Title",
            description: "Description",
            trailing: .init(
                text: "$ 1,000.00",
                color: .feedbackPositive,
                type: .icon(Image(systemName: "chevron.right"))
            ),
            leftImage: Image(systemName: "creditcard"),
            state: .idle,
            onClick: {
                print("on click")
            }
        )
        
        // Active/Selected state
        MPListItem(
            title: "Title",
            description: "Description",
            trailing: .init(
                text: "$ 1,000.00",
                color: .secondary,
                type: .icon(Image(systemName: "chevron.right"))
            ),
            leftImage: Image(systemName: "creditcard"),
            state: .active
        )
        
        // Disabled state
        MPListItem(
            title: "Title",
            description: "Description",
            trailing: .init(
                text: "$ 1,000.00",
                color: .secondary,
                type: .icon(Image(systemName: "chevron.right"))
            ),
            leftImage: Image(systemName: "creditcard"),
            state: .disabled
        )
    }
    .padding()
    .loadMPFonts()
}
#endif
