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
        let isSelected = configuration.isSelected?.wrappedValue == true

        Button {
            configuration.isSelected?.wrappedValue.toggle()
        } label: {
            HStack(alignment: .center, spacing: theme.spacings.xtiny) {
                if let leftImage = configuration.leftImage { leftImage }

                VStack(alignment: .leading, spacing: theme.spacings.xnano) {
                    if let header = configuration.header { header }
                    if let title = configuration.title { title }
                    if let description = configuration.description { description }
                }

                Spacer()

                if let trailing = configuration.trailing {
                    trailing
                }
            }
            .padding(.horizontal, theme.spacings.micro)
            .padding(.vertical, theme.spacings.xtiny)
            .background(isSelected ? theme.colors.fill.accentQuiet : Color.clear)
            .cornerRadius(theme.borderRadius.small)
            .overlay(
                HStack {
                    RoundedRectangle(cornerRadius: theme.borderRadius.tiny)
                        .fill(isSelected ? theme.colors.fill.accentLoud : Color.clear)
                        .frame(width: theme.borderWidth.xlarge)
                    Spacer()
                }
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
