//
//  MPListItem.swift
//  MPComponents
//
//  Created by [Your Name] on [Date].
//

import MPFoundation
import SwiftUI

package enum MPListItemLeading {
    case image(Image)
    case thumbnail(URL?)
}

package struct MPListItem: View {
    @Environment(\.listItemStyle) private var style
    @Environment(\.listItemTrailingStyle) private var trailingStyle
    @State private var isPressed = false

    let isSelected: Binding<Bool>
    let leading: MPListItemLeading?
    let contentInfo: MPListItemContentInfo
    let trailing: MPListItemTrailing?

    package init(
        isSelected: Binding<Bool> = .constant(false),
        leading: MPListItemLeading? = nil,
        contentInfo: MPListItemContentInfo,
        trailing: MPListItemTrailing? = nil
    ) {
        self.isSelected = isSelected
        self.leading = leading
        self.contentInfo = contentInfo
        self.trailing = trailing
    }

    package var body: some View {
        let configuration: MPListItemStyleConfiguration = .init(
            isPressed: isPressed,
            isSelected: isSelected.wrappedValue,
            leading: self.leadingView,
            title: self.titleView,
            header: self.headerView,
            description: self.descriptionView,
            trailing: self.trailingView
        )

        let resolvedStyle = self.style ?? MPDefaultListItemStyle()

        AnyView(
            resolvedStyle.resolve(configuration: configuration)
        )
        .contentShape(Rectangle())
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            withAnimation(.easeOut(duration: 0.15)) {
                self.isPressed = pressing
            }
        }, perform: {})
        .onTapGesture {
            self.isSelected.wrappedValue.toggle()
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
    private var leadingView: some View {
        switch self.leading {
        case let .image(image):
            image
        case let .thumbnail(url):
            MPIcon(source: .remote(url: url))
                .mpIconStyle(.thumbnailFlag)
        case .none:
            EmptyView()
        }
    }

    @ViewBuilder
    private var trailingView: some View {
        if let trailing {
            let config = MPListItemTrailingStyleConfiguration(
                text: trailing.text,
                textColor: trailing.color
            )
            let resolved = self.trailingStyle ?? MPTrailingTextStyle()
            AnyView(resolved.resolve(configuration: config))
        }
    }
}

#if DEBUG
    struct MPListItemView: View {
        @State private var selectedIndex: Int? = 0

        private let visaURL = URL(string: "https://http2.mlstatic.com/storage/mobile-on-demand-resources//image/cho_off-add-card_xxxhdpi")

        public init() {}

        public var body: some View {
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    MPListItem(
                        leading: .thumbnail(self.visaURL),
                        contentInfo: .init(title: "Default style 111", description: "Text-only trailing 11"),
                        trailing: .init(text: "$ 500.00")
                    )

                    MPListItem(
                        isSelected: self.bindingForIndex(0),
                        contentInfo: .init(title: "Title")
                    )

                    MPListItem(
                        isSelected: self.bindingForIndex(1),
                        contentInfo: .init(title: "Option 2", description: "Description"),
                        trailing: .init(
                            text: MPStrings.Installments.interestFree,
                            color: .feedbackPositive
                        )
                    )

                    MPListItem(
                        isSelected: self.bindingForIndex(3),
                        contentInfo: .init(title: "Option 3"),
                        trailing: .init(
                            text: MPStrings.Installments.interestFree,
                            color: .feedbackPositive
                        )
                    )

                    MPListItem(
                        isSelected: self.bindingForIndex(4),
                        contentInfo: .init(header: "Option 4"),
                        trailing: .init(text: "$ 1,000.00")
                    )
                }
            }
            .padding()
        }

        private func bindingForIndex(_ index: Int) -> Binding<Bool> {
            Binding(
                get: { self.selectedIndex == index },
                set: { if $0 { self.selectedIndex = index } }
            )
        }
    }

    #Preview {
        MPListItemView()
    }
#endif
