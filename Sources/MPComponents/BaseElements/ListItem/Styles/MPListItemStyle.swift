//
//  ListItemStyle.swift
//  MPComponents
//
//  Created by [Your Name] on [Date].
//

import SwiftUI
import MPFoundation

package protocol MPListItemStyle: StyleProtocol, Identifiable where Configuration == MPListItemStyleConfiguration {}

// MARK: - Convenience extensions

extension MPListItemStyle where Self == MPDefaultListItemStyle {
    /// Default plain style: `.listItemStyle(.default)`
    package static var `default`: MPDefaultListItemStyle { MPDefaultListItemStyle() }
}

extension MPListItemStyle where Self == MPListRowRadioStyle {
    /// Radio button style: `.listItemStyle(.radioButton)`
    package static var radioButton: MPListRowRadioStyle { MPListRowRadioStyle() }
}

extension MPListItemStyle where Self == MPListRowPickStyle {
    /// Pick/selection style: `.listItemStyle(.pick)`
    package static var pick: MPListRowPickStyle { MPListRowPickStyle() }
}

package struct MPDefaultListItemStyle: MPListItemStyle {
    public var id: UUID = .init()

    @Environment(\.checkoutTheme) var theme: MPTheme

    @MainActor
    public func makeBody(configuration: MPListItemStyleConfiguration) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: theme.spacings.xtiny) {
            if let leftImage = configuration.leftImage {
                leftImage
                    .alignmentGuide(.firstTextBaseline) { d in
                        d[VerticalAlignment.center]
                    }
            }

            VStack(alignment: .leading, spacing: theme.spacings.xnano) {
                if let header = configuration.header {
                    header
                }
                if let title = configuration.title {
                    title
                }
                if let description = configuration.description {
                    description
                }
            }

            Spacer()

            if let trailing = configuration.trailing {
                trailing
            }
        }
        .padding(.horizontal, theme.spacings.micro)
        .padding(.vertical, theme.spacings.xtiny)
        .cornerRadius(theme.borderRadius.small)
    }
}
