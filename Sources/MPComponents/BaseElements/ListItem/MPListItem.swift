//
//  MPListItem.swift
//  MPComponents
//
//  Created by [Your Name] on [Date].
//

import SwiftUI
import MPFoundation

package struct MPListItem: View {
    
    @Environment(\.listItemStyle) private var style
    
    let type: MPListItemType?
    let leftImage: Image?
    let title: String
    let description: String?
    let trailing: MPListItemTrailing?
    var onClick: (() -> Void)?
    
    package init(
        title: String,
        description: String? = nil,
        trailing: MPListItemTrailing? = nil,
        leftImage: Image? = nil,
        type: MPListItemType? = nil,
        onClick: (() -> Void)? = nil
    ) {
        self.type = type
        self.leftImage = leftImage
        self.title = title
        self.description = description
        self.trailing = trailing
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
            type: type ?? .none
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
struct MPListItemView: View {
    @State private var selectedIndex: Int? = 0

    var body: some View {
        VStack(spacing: 16) {
            MPListItem(
                title: "Option 1",
                description: "Description",
                trailing: .init(
                    text: "$ 1,000.00",
                    color: .feedbackPositive,
                    type: .icon(Image(systemName: "chevron.right"))
                ),
                leftImage: Image(systemName: "creditcard"),
                type: .radioButton(selected: bindingForIndex(0)),
                onClick: { selectedIndex = 0 }
            )

            MPListItem(
                title: "Option 2",
                description: "Description",
                trailing: .init(
                    text: "$ 1,000.00"
                ),
                type: .radioButton(selected: bindingForIndex(1)),
                onClick: { selectedIndex = 1 }
            )

            // Sem radio button
            MPListItem(
                title: "Title",
                description: "Description",
                trailing: .init(
                    text: "$ 1,000.00",
                    type: .icon(Image(systemName: "chevron.right"))
                ),
                leftImage: Image(systemName: "creditcard")
            )
        }
        .padding()
        .loadMPFonts()
    }

    private func bindingForIndex(_ index: Int) -> Binding<Bool> {
        Binding(
            get: { selectedIndex == index },
            set: { newValue in
                selectedIndex = newValue ? index : nil
            }
        )
    }
}

#Preview {
    MPListItemView()
}
#endif
