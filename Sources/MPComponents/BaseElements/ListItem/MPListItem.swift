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
            isSelected: isSelected,
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
                    leftImage: Image(systemName: "creditcard"),
                    contentInfo: .init(title: "Option 1", description: "Description 1111"),
                    trailing: .init(text: "$ 1,000.00")
                )
                .listItemTrailingStyle(.textIcon(Image(systemName: "chevron.right")))


                
                MPListItem(
                    isSelected: bindingForIndex(1),
                    contentInfo: .init(title: "Option 2", description: "Description"),
                    trailing: .init(
                        text: MPStrings.Installments.interestFree,
                        color: .feedbackPositive
                    )
                )
                .listItemTrailingStyle(.textIcon(Image(systemName: "chevron.left")))

                
                
                MPListItem(
                    isSelected: bindingForIndex(2),
                    contentInfo: .init(header: "Option 3"),
                    trailing: .init(text: "$ 1,000.00")
                )
                
                .listItemTrailingStyle(.textIcon(Image(systemName: "chevron.left")))
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
        .listItemStyle(.radioButton)

}
#endif
