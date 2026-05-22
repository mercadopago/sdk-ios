//
//  MPListRowPickStyle.swift
//  MPComponents
//
//  Created by Guilherme Prata Costa on 24/02/26.
//

import MPFoundation
import SwiftUI

package struct MPListRowPickStyle: MPListItemStyle {
    package var id: UUID = .init()
    @Environment(\.checkoutTheme) var theme: MPTheme

    package init() {}

    @MainActor
    package func makeBody(configuration: MPListItemStyleConfiguration) -> some View {
        let isSelected = configuration.isSelected == true
        let hasDescription = configuration.description != nil

        HStack(alignment: hasDescription ? .top : .center, spacing: self.theme.spacings.xtiny) {
            if let leading = configuration.leading {
                leading
            }

            VStack(alignment: .leading, spacing: self.theme.spacings.xnano) {
                if let header = configuration.header { header }
                if let title = configuration.title {
                    title
                        .textStyle(.large())
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
        .background(
            configuration.isPressed
                ? self.theme.colors.surface.active
                : (isSelected ? self.theme.colors.fill.accentQuiet : Color.clear)
        )
        .cornerRadius(self.theme.borderRadius.small)
        .overlay(
            HStack {
                RoundedRectangle(cornerRadius: self.theme.borderWidth.large / 2)
                    .fill(isSelected ? self.theme.colors.fill.accentLoud : Color.clear)
                    .frame(width: self.theme.borderWidth.medium)
                    .padding(.vertical, self.theme.spacings.xmicro)
                Spacer()
            }
            .padding(.leading, self.theme.spacings.nano)
        )
    }
}
