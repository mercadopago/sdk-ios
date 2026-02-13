//
//  MPRadioButtonStyle.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 13/02/26.
//

import SwiftUI

package protocol MPRadioButtonStyle: StyleProtocol, Identifiable where Configuration == MPRadioButtonConfiguration {}

package struct MPRadioButtonDefaultStyle: MPRadioButtonStyle {
    package var id: UUID = .init()
    
    @Environment(\.checkoutTheme) var theme: MPTheme
    
    private let buttonSize: CGFloat = 20
    private let innerPadding: CGFloat = 6
    private let borderWidth: CGFloat = 1.5
    private let labelGap: CGFloat = 8
    private let outerBorderGap: CGFloat = 4
    
    package func makeBody(configuration: MPRadioButtonConfiguration) -> some View {
        if configuration.isOn {
            ZStack {
                Circle()
                    .fill(theme.colors.fill.accentLoud)
                Circle()
                    .fill(Color.white)
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
                .strokeBorder(Color.gray, lineWidth: borderWidth)
                .frame(width: buttonSize, height: buttonSize)
        }
    }
}
