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
    
    let leftImage: Image?
    let title: String
    let description: String
    let rightText: String
    let hasChevron: Bool
    let isSelected: Bool

    package init(
        leftImage: Image? = nil,
        title: String,
        description: String = "",
        rightText: String = "",
        hasChevron: Bool = false,
        isSelected: Bool = false
    ) {
        self.leftImage = leftImage
        self.title = title
        self.description = description
        self.rightText = rightText
        self.hasChevron = hasChevron
        self.isSelected = isSelected
    }
    
    package var body: some View {        
        let configuration: MPListItemStyleConfiguration = .init(
            leftImage: leftImageView,
            title: titleView,
            description: descriptionView,
            textRight: textRightView,
            hasChevron: hasChevron,
            isSelected: isSelected
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
        Text(description)
            .textStyle(.bodyMedium(colorType: .secondary))
    }
    
    @ViewBuilder
    private var textRightView: some View {
        Text(rightText)
            .textStyle(.bodyMedium(colorType: .secondary))
    }
    
    @ViewBuilder
    private var leftImageView: some View {
        leftImage
    }

}

#Preview {
    VStack(spacing: 16) {
        // Idle state
        MPListItem(
            leftImage: Image(systemName: "creditcard"),
            title: "Title",
            description: "Description",
            rightText: "$ 1,000.00",
            hasChevron: true
        )
        
        // Active/Selected state
        MPListItem(
            leftImage: Image(systemName: "creditcard"),
            title: "Title",
            description: "Description",
            rightText: "$ 1,000.00",
            hasChevron: true,
            isSelected: true
        )
        
        // Disabled state
        MPListItem(
            leftImage: Image(systemName: "creditcard"),
            title: "Title",
            description: "Description",
            rightText: "$ 1,000.00",
            hasChevron: true
        )
        .disabled(true)
    }
    .padding()
    .loadMPFonts()
}
