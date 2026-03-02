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
        let hasDescription = configuration.description != nil
        
        HStack(alignment: .center, spacing: theme.spacings.xtiny) {
            radioToggle(isSelected: configuration.isSelected, hasDescription: hasDescription)

            VStack(alignment: .leading, spacing: theme.spacings.xnano) {
                if let header = configuration.header { header }
                if let title = configuration.title {
                    title
                        .textStyle(.bodyMediumTitle())
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
        .background(configuration.isPressed ? theme.colors.surface.active : Color.clear)
        .cornerRadius(theme.borderRadius.small)
    }
    
    @ViewBuilder
    private func radioToggle(isSelected: Bool, hasDescription: Bool) -> some View {
        let toggle = Toggle(isOn: .constant(isSelected)) { EmptyView() }
            .toggleStyle(MPRadioButtonToggleStyle())
            .labelsHidden()
            .fixedSize()
            .allowsHitTesting(false)

        if hasDescription {
            toggle.alignmentGuide(.firstTextBaseline) { aligment in
                aligment[VerticalAlignment.center]
            }
        } else {
            toggle
        }
    }
    
}
