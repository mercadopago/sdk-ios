//
//  MPListRowPickStyle.swift
//  MPComponents
//
//  Created by Guilherme Prata Costa on 24/02/26.
//

import SwiftUI
import MPFoundation

package struct MPListRowPickStyle: MPListItemStyle {
    package var id: UUID = .init()
    @Environment(\.checkoutTheme) var theme: MPTheme

    package init() {}

    @MainActor
    package func makeBody(configuration: MPListItemStyleConfiguration) -> some View {
        let isSelected = configuration.isSelected == true

        HStack(alignment: .firstTextBaseline, spacing: theme.spacings.xtiny) {
            if let leftImage = configuration.leftImage {
                leftImage
                    .alignmentGuide(.firstTextBaseline) { d in
                        d[VerticalAlignment.center]
                    }
            }

            VStack(alignment: .leading, spacing: theme.spacings.xnano) {
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
        .padding(.horizontal, theme.spacings.micro)
        .padding(.vertical, theme.spacings.xtiny)
        .background(
            configuration.isPressed
                ? theme.colors.surface.active
                : (isSelected ? theme.colors.fill.accentQuiet : Color.clear)
        )
        .cornerRadius(theme.borderRadius.small)
        .overlay(
            HStack {
                RoundedRectangle(cornerRadius: theme.borderWidth.large / 2)
                    .fill(isSelected ? theme.colors.fill.accentLoud : Color.clear)
                    .frame(width: theme.borderWidth.medium)
                    .padding(.vertical, theme.spacings.xmicro)
                Spacer()
            }
            .padding(.leading, theme.spacings.nano)
        )
    }
}
