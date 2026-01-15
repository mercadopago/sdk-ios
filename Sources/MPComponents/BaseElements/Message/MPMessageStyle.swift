//
//  MPMessageStyle.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 15/01/26.
//
import SwiftUI
import MPFoundation

package protocol MPMessageStyle: StyleProtocol where Configuration == MPMessageConfiguration {}

package struct MPDefaultMessageStyle: MPMessageStyle {
    package typealias Configuration = MPMessageConfiguration
    
    @Environment(\.checkoutTheme) var theme: MPTheme
    
    @MainActor
    package func makeBody(configuration: MPMessageConfiguration) -> some View {
        Spacer()
        HStack {
            HStack(alignment: .top) {
                //use badge icon
                switch configuration.state {
                case .informative:
                    Circle()
                        .fill(theme.colors.feedback.fillInformativeLoud)
                        .frame(width: 20, height: 20)
                case .posetive:
                    Circle()
                        .fill(theme.colors.feedback.fillPositiveLoud)
                        .frame(width: 20, height: 20)
                case .negative:
                    Circle()
                        .fill(theme.colors.feedback.fillNegativeLoud)
                        .frame(width: 20, height: 20)
                case .caution:
                    Circle()
                        .fill(theme.colors.feedback.fillCautionLoud)
                        .frame(width: 20, height: 20)
                }
                Text(configuration.message)
                    .textStyle(.bodyMedium())
                Spacer()
                Button {
                    configuration.dismiss()
                } label: {
                    Image(Logos.close, bundle: .bundleMP)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 20, height: 20)
                        .foregroundColor(theme.colors.icon.secondary)
                }
            }
            .padding(theme.spacings.xtiny)
            
        }
        .background(
            RoundedRectangle(cornerRadius: theme.borderRadius.xlarge)
                .fill(backgroundColor(for: configuration.state))
        )
        .padding(theme.spacings.xtiny)
    }
    
    private func backgroundColor(for state: MPMessageState) -> Color {
        switch state {
        case .informative:
            return theme.colors.feedback.fillInformativeQuiet
        case .posetive:
            return theme.colors.feedback.fillPositiveQuiet
        case .negative:
            return theme.colors.feedback.fillNegativeQuiet
        case .caution:
            return theme.colors.feedback.fillCautionQuiet
        }
    }
}
