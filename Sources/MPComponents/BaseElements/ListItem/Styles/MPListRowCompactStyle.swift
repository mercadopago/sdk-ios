//
//  MPListRowCompactStyle.swift
//  MPComponents
//

import MPFoundation
import SwiftUI

/// A compact label-over-value row with no leading icon, e.g. "Medio de pago" / "Efectivo en Rapipago"
/// plus an optional trailing action. Unlike `.default`/`.payment` (which style `title` as
/// `.largeSemibold()`), this keeps `title` at body-text weight so short caption+value pairs don't
/// dominate the row.
package struct MPListRowCompactStyle: MPListItemStyle {
    package var id: UUID = .init()
    @Environment(\.checkoutTheme) var theme: MPTheme

    package init() {}

    @MainActor
    package func makeBody(configuration: MPListItemStyleConfiguration) -> some View {
        HStack(alignment: .center, spacing: self.theme.spacings.xmicro) {
            VStack(alignment: .leading, spacing: self.theme.spacings.xnano) {
                if let header = configuration.header { header }
                if let title = configuration.title {
                    title
                        .textStyle(.bodyMediumEmphasis())
                }
                if let description = configuration.description { description }
            }

            Spacer(minLength: self.theme.spacings.xmicro)

            if let trailing = configuration.trailing {
                trailing
            }
        }
    }
}

extension MPListItemStyle where Self == MPListRowCompactStyle {
    /// Compact label/value trailing-action row: `.listItemStyle(.compact)`
    package static var compact: MPListRowCompactStyle {
        MPListRowCompactStyle()
    }
}
