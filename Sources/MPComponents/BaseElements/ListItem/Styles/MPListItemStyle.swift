//
//  ListItemStyle.swift
//  MPComponents
//
//  Created by [Your Name] on [Date].
//

import SwiftUI
import MPFoundation

package protocol MPListItemStyle: StyleProtocol, Identifiable where Configuration == MPListItemStyleConfiguration {}

package struct MPDefaultListItemStyle: MPListItemStyle {
    public var id: UUID = .init()

    @Environment(\.checkoutTheme) var theme: MPTheme

    @MainActor
    public func makeBody(configuration: MPListItemStyleConfiguration) -> some View {
        HStack(alignment: .center, spacing: theme.spacings.xtiny) {
            if let leftImage = configuration.leftImage {
                leftImage
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
