//
//  MPListRowRadioStyle.swift
//  MPComponents
//
//  Created by Guilherme Prata Costa on 24/02/26.
//

import MPFoundation
import SwiftUI

package struct MPListRowRadioStyle: MPListItemStyle {
    package var id: UUID = .init()
    @Environment(\.checkoutTheme) var theme: MPTheme

    package init() {}

    @MainActor
    package func makeBody(configuration: MPListItemStyleConfiguration) -> some View {
        let hasDescription = configuration.description != nil

        HStack(alignment: hasDescription ? .top : .center, spacing: self.theme.spacings.gap.xtiny) {
            self.radioToggle(isSelected: configuration.isSelected)

            VStack(alignment: .leading, spacing: self.theme.spacings.gap.xnano) {
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
        .padding(.horizontal, self.theme.spacings.paddings.micro)
        .padding(.vertical, self.theme.spacings.paddings.xtiny)
        .background(configuration.isPressed ? self.theme.colors.surface.primaryActive : Color.clear)
        .cornerRadius(self.theme.borderRadius.small)
    }

    private func radioToggle(isSelected: Bool) -> some View {
        Toggle(isOn: .constant(isSelected)) { EmptyView() }
            .toggleStyle(MPRadioButtonToggleStyle())
            .labelsHidden()
            .fixedSize()
            .allowsHitTesting(false)
    }
}
