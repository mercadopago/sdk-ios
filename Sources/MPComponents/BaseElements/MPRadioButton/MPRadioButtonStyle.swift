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
            radioCircle(isOn: configuration.isOn)
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
                    .fill(theme.colors.fill.accentLoud)
                Circle()
                    .fill(theme.colors.fill.primary)
                    .padding(innerPadding)
            }
            .frame(width: buttonSize, height: buttonSize)
            .background(
                Circle()
                    .fill(theme.colors.fill.accentQuiet)
                    .frame(width: buttonSize + outerBorderGap, height: buttonSize + outerBorderGap)
            )
        } else {
            Circle()
                .strokeBorder(theme.colors.interactive.borderIdle, lineWidth: borderWidth)
                .frame(width: buttonSize, height: buttonSize)
        }
    }
}
