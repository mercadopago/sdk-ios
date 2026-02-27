//
//  MPListRowRadioStyle.swift
//  MPComponents
//
//  Created by Guilherme Prata Costa on 24/02/26.
//

import SwiftUI
import MPFoundation

package struct MPListRowRadioStyle: MPListItemStyle {
    package var id: UUID = .init()
    @Environment(\.checkoutTheme) var theme: MPTheme

    package init() {}

    @MainActor
    package func makeBody(configuration: MPListItemStyleConfiguration) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: theme.spacings.xtiny) {
            if let isSelected = configuration.isSelected {
                Toggle(isOn: .constant(isSelected.wrappedValue)) { EmptyView() }
                    .toggleStyle(MPRadioButtonToggleStyle())
                    .labelsHidden()
                    .allowsHitTesting(false)
                    .alignmentGuide(.firstTextBaseline) { d in
                        d[VerticalAlignment.center]
                    }
            }

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
        .background(configuration.isPressed ? theme.colors.surface.active : Color.clear)
        .cornerRadius(theme.borderRadius.small)
    }
}
