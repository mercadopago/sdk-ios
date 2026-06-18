//
//  MPRadioButtonStyle.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 13/02/26.
//

import SwiftUI

package struct MPRadioButtonToggleStyle: ToggleStyle {
    @Environment(\.checkoutTheme) var theme: MPTheme

    /// borderWidth has no exact token (between borderWidth.small=1 and borderWidth.medium=2)
    private let borderWidth: CGFloat = 1.5

    package func makeBody(configuration: Configuration) -> some View {
        HStack {
            self.radioCircle(isOn: configuration.isOn)
                .onTapGesture {
                    configuration.isOn.toggle()
                }
            configuration.label
        }
    }

    @ViewBuilder
    private func radioCircle(isOn: Bool) -> some View {
        let buttonSize = self.theme.spacings.tiny
        let outerSize = buttonSize + self.theme.spacings.xnano

        if isOn {
            ZStack {
                Circle()
                    .fill(self.theme.colors.selected.fillIdle)
                Circle()
                    .fill(self.theme.colors.fill.primary)
                    .padding(self.theme.spacings.nano)
            }
            .frame(width: buttonSize, height: buttonSize)
            .background(
                Circle()
                    .fill(self.theme.colors.fill.accentQuiet)
                    .frame(width: outerSize, height: outerSize)
            )
        } else {
            Circle()
                .strokeBorder(self.theme.colors.interactive.borderIdle, lineWidth: self.borderWidth)
                .frame(width: buttonSize, height: buttonSize)
        }
    }
}
