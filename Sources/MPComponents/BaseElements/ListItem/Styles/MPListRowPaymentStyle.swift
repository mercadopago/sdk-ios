//
//  MPListRowPaymentStyle.swift
//  MPComponents
//

import MPFoundation
import SwiftUI

package struct MPListRowPaymentStyle: MPListItemStyle {
    package var id: UUID = .init()
    @Environment(\.checkoutTheme) var theme: MPTheme

    package init() {}

    @MainActor
    package func makeBody(configuration: MPListItemStyleConfiguration) -> some View {
        let hasDescription = configuration.description != nil
        let contentAlignment: VerticalAlignment = hasDescription ? .top : .center

        HStack(alignment: .center, spacing: self.theme.spacings.xtiny) {
            if let leading = configuration.leading {
                leading
            }

            HStack(alignment: contentAlignment, spacing: 0) {
                VStack(alignment: .leading, spacing: self.theme.spacings.xnano) {
                    if let header = configuration.header { header }
                    if let title = configuration.title {
                        title
                            .textStyle(.largeSemibold())
                    }
                    if let description = configuration.description { description }
                }

                Spacer()

                if let trailing = configuration.trailing {
                    trailing
                }
            }
        }
        .padding(.horizontal, self.theme.spacings.micro)
        .padding(.vertical, self.theme.spacings.xtiny)
        .cornerRadius(self.theme.borderRadius.small)
    }
}

extension MPListItemStyle where Self == MPListRowPaymentStyle {
    package static var payment: MPListRowPaymentStyle {
        MPListRowPaymentStyle()
    }
}
