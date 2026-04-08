//
//  MPRadioButtonStyle.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 13/02/26.
//

import SwiftUI

package struct MPRadioButtonToggleStyle: ToggleStyle {
    @Environment(\.checkoutTheme) var theme: MPTheme

    private let buttonSize: CGFloat = 20
    private let innerPadding: CGFloat = 6
    private let borderWidth: CGFloat = 1.5
    private let outerBorderGap: CGFloat = 4

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
        if isOn {
            ZStack {
                Circle()
                    .fill(self.theme.colors.selected.fillIdle)
                Circle()
                    .fill(self.theme.colors.fill.primary)
                    .padding(self.innerPadding)
            }
            .frame(width: self.buttonSize, height: self.buttonSize)
            .background(
                Circle()
                    .fill(self.theme.colors.fill.accentQuiet)
                    .frame(width: self.buttonSize + self.outerBorderGap, height: self.buttonSize + self.outerBorderGap)
            )
        } else {
            Circle()
                .strokeBorder(self.theme.colors.interactive.borderIdle, lineWidth: self.borderWidth)
                .frame(width: self.buttonSize, height: self.buttonSize)
        }
    }
}
