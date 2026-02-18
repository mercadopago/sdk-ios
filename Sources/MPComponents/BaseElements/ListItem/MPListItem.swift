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
    let contentInfo: MPListItemContentInfo
    let trailing: MPListItemTrailing?
    var onClick: (() -> Void)?
    
    package init(
        type: MPListItemType? = nil,
        leftImage: Image? = nil,
        contentInfo: MPListItemContentInfo,
        trailing: MPListItemTrailing? = nil,
        onClick: (() -> Void)? = nil
    ) {
        self.type = type
        self.leftImage = leftImage
        self.contentInfo = contentInfo
        self.trailing = trailing
        self.onClick = onClick
    }
    
    package var body: some View {        
        let configuration: MPListItemStyleConfiguration = .init(
            leftImage: leftImageView,
            title: titleView,
            header: headerView,
            description: descriptionView,
            textRight: textRightView,
            rightContent: rightContent,
            selectedButton: selectedButton,
            radioButton: radioButtonView
        )
        
        AnyView(
            style.resolve(configuration: configuration)
        )
    }
    
    @ViewBuilder
    private var headerView: some View {
        if let header = contentInfo.header {
            Text(header)
                .textStyle(.bodyMedium())
        }
    }
    
    @ViewBuilder
    private var titleView: some View {
        if let title = contentInfo.title {
            Text(title)
                .textStyle(.bodyMediumTitle())
        }
    }
    
    @ViewBuilder
    private var descriptionView: some View {
        if let description = contentInfo.description {
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
    private var radioButtonView: some View {
        switch type {
        case .radioButton(let selected):
            Toggle(isOn: .constant(selected)) { EmptyView() }
                .toggleStyle(MPRadioButtonToggleStyle())
                .labelsHidden()
        default:
            EmptyView()
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
                type: .radioButton(selected: bindingForIndex(0)),
                leftImage: Image(systemName: "creditcard"),
                contentInfo: .init(title: "Option 1", description: "Description"),
                trailing:.init(
                    text: "$ 1,000.00",
                    type: .icon(Image(systemName: "chevron.right"))
                ),
                onClick: {
                    selectedIndex = 0 }
            )
            MPListItem(
                type: .radioButton(selected: bindingForIndex(1)),
                contentInfo: .init(title: "Option 2", description: "Description"),
                trailing:.init(
                    text: MPStrings.Installments.interestFree,
                    color: .feedbackPositive,
                    type: .icon(Image(systemName: "chevron.right"))
                ),
                onClick: { selectedIndex = 1 }
            )
            
            MPListItem(
                type: .radioButton(selected: bindingForIndex(2)),
                contentInfo: .init(header: "Option 3"),
                trailing:.init(
                    text: "$ 1,000.00"
                ),
                onClick: {
                    selectedIndex = 2 }
            )
            
            MPListItem(
                type: .radioButton(selected: bindingForIndex(3)),
                contentInfo: .init(title: "Title", header: "Option 3", description: "description"),
                trailing:.init(
                    text: "$ 1,000.00"
                ),
                onClick: {
                    selectedIndex = 3 }
            )
            
            MPListItem(
                leftImage: Image(systemName: "creditcard"),
                contentInfo: .init(title: "Title", description: "Description")
            )
        }
        .padding()
        .loadMPFonts()
    }

    private func bindingForIndex(_ index: Int) -> Bool {
        if selectedIndex == index {
            return true
        } else {
            return false
        }
    }
}

#Preview {
    MPListItemView()
}
#endif
