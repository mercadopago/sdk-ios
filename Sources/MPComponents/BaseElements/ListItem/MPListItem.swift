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
    @Environment(\.listItemTrailingStyle) private var trailingStyle
    @State private var isPressed = false

    let isSelected: Binding<Bool>
    let leftImage: Image?
    let contentInfo: MPListItemContentInfo
    let trailing: MPListItemTrailing?
    var onClick: (() -> Void)?

    package init(
        isSelected: Binding<Bool> = .constant(false),
        leftImage: Image? = nil,
        contentInfo: MPListItemContentInfo,
        trailing: MPListItemTrailing? = nil,
        onClick: (() -> Void)? = nil
    ) {
        self.isSelected = isSelected
        self.leftImage = leftImage
        self.contentInfo = contentInfo
        self.trailing = trailing
        self.onClick = onClick
    }

    package var body: some View {
        let configuration: MPListItemStyleConfiguration = .init(
            isPressed: isPressed,
            isSelected: isSelected.wrappedValue,
            leftImage: leftImageView,
            title: titleView,
            header: headerView,
            description: descriptionView,
            trailing: trailingView
        )

        let resolvedStyle = style ?? MPDefaultListItemStyle()
        
        AnyView(
            resolvedStyle.resolve(configuration: configuration)
        )
        .contentShape(Rectangle())
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            withAnimation(.easeOut(duration: 0.15)) {
                isPressed = pressing
            }
        }, perform: {})
        .onTapGesture {
            isSelected.wrappedValue.toggle()
        }
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
    private var leftImageView: some View {
        leftImage
    }

    @ViewBuilder
    private var trailingView: some View {
        if let trailing {
            let config = MPListItemTrailingStyleConfiguration(
                text: trailing.text,
                textColor: trailing.color
            )
            let resolved = trailingStyle ?? MPTrailingTextStyle()
            AnyView(resolved.resolve(configuration: config))
        }
    }

}

#if DEBUG
struct MPListItemView: View {
    @State private var selectedIndex: Int? = 0

    public init() {}

    public var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                MPListItem(
                    isSelected: bindingForIndex(0),
                    contentInfo: .init(title: "Title"),
                )
                
                MPListItem(
                    isSelected: bindingForIndex(1),
                    contentInfo: .init(title: "Option 2", description: "Description"),
                    trailing: .init(
                        text: MPStrings.Installments.interestFree,
                        color: .feedbackPositive
                    )
                )
                
                
                MPListItem(
                    isSelected: bindingForIndex(3),
                    contentInfo: .init(title: "Option 3"),
                    trailing: .init(
                        text: MPStrings.Installments.interestFree,
                        color: .feedbackPositive
                    )
                )
                
                MPListItem(
                    isSelected: bindingForIndex(4),
                    contentInfo: .init(header: "Option 4"),
                    trailing: .init(text: "$ 1,000.00")
                )
            }

            MPListItem(
                leftImage: Image(systemName: "creditcard"),
                contentInfo: .init(title: "Default style", description: "Text-only trailing 11"),
                trailing: .init(text: "$ 500.00")
            )
        }
        .listItemStyle(.radioButton)
        .padding()
    }

    private func bindingForIndex(_ index: Int) -> Binding<Bool> {
        Binding(
            get: { selectedIndex == index },
            set: { if $0 { selectedIndex = index } }
        )
    }
}

#Preview {
    MPListItemView()

}
#endif
