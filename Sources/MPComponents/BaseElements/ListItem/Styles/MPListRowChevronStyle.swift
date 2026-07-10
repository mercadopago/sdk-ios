//
//  MPListRowChevronStyle.swift
//  MPComponents
//

import MPFoundation
import SwiftUI

package struct MPListRowChevronStyle: MPListItemStyle {
    package var id: UUID = .init()
    @Environment(\.checkoutTheme) var theme: MPTheme

    package init() {}

    @MainActor
    package func makeBody(configuration: MPListItemStyleConfiguration) -> some View {
        let hasDescription = configuration.description != nil

        HStack(alignment: hasDescription ? .top : .center, spacing: self.theme.spacings.xmicro) {
            if let leftImage = configuration.leading {
                leftImage
            }

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
        .padding(.horizontal, self.theme.spacings.micro)
        .padding(.vertical, self.theme.spacings.xtiny)
        .background(configuration.isPressed ? self.theme.colors.surface.active : Color.clear)
        .cornerRadius(self.theme.borderRadius.small)
    }
}
