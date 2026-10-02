//
//  MPListRowSimpleStyle.swift
//  MPComponents
//

import MPFoundation
import SwiftUI

/// Compact list row with a tinted leading icon and a body-sized title.
package struct MPListRowSimpleStyle: MPListItemStyle {
    package var id: UUID = .init()
    @Environment(\.checkoutTheme) var theme: MPTheme

    package init() {}

    @MainActor
    package func makeBody(configuration: MPListItemStyleConfiguration) -> some View {
        HStack(alignment: .center, spacing: self.theme.spacings.xmicro) {
            if let leading = configuration.leading {
                leading
                    .foregroundColor(self.theme.colors.icon.primary)
            }

            VStack(alignment: .leading, spacing: self.theme.spacings.xnano) {
                if let header = configuration.header { header }
                if let title = configuration.title {
                    title
                        .textStyle(.bodyMedium())
                }
                if let description = configuration.description { description }
            }

            Spacer(minLength: 0)

            if let trailing = configuration.trailing {
                trailing
            }
        }
        .padding(.horizontal, self.theme.spacings.micro)
        .padding(.vertical, self.theme.spacings.xtiny)
    }
}

extension MPListItemStyle where Self == MPListRowSimpleStyle {
    package static var simple: MPListRowSimpleStyle {
        MPListRowSimpleStyle()
    }
}
