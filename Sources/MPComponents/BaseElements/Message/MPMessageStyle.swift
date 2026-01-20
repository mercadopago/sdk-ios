//
//  MPMessageStyle.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 15/01/26.
//
import SwiftUI
import MPFoundation

package protocol MPMessageStyle: StyleProtocol, Identifiable where Configuration == MPMessageConfiguration {}

package struct MPDefaultMessageStyle: MPMessageStyle {
    package typealias Configuration = MPMessageConfiguration
    
    package var id: UUID = .init()
    
    @Environment(\.checkoutTheme) var theme: MPTheme
    
    @MainActor
    package func makeBody(configuration: MPMessageConfiguration) -> some View {
        Spacer()
        HStack {
            HStack(alignment: .top) {
                switch configuration.state {
                case .informative:
                    MPBadgeIcon(.informative, .large)
                case .positive:
                    MPBadgeIcon(.positive, .large)
                case .negative:
                    MPBadgeIcon(.negative, .large)
                case .caution:
                    MPBadgeIcon(.caution, .large)
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
        case .positive:
            return theme.colors.feedback.fillPositiveQuiet
        case .negative:
            return theme.colors.feedback.fillNegativeQuiet
        case .caution:
            return theme.colors.feedback.fillCautionQuiet
        }
    }
}


// MARK: - Environment
struct MPMessageStyleKey: EnvironmentKey {
    static let defaultValue: any MPMessageStyle = MPDefaultMessageStyle()
}

extension EnvironmentValues {
    var mpMessageStyle: any MPMessageStyle {
        get { self[MPMessageStyleKey.self] }
        set { self[MPMessageStyleKey.self] = newValue }
    }
}

extension View {
    func messageStyle<S: MPMessageStyle>(_ style: S) -> some View {
        environment(\.mpMessageStyle, style)
    }
}

// MARK: - Style Resolution
package extension MPMessageStyle {
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedMPMessageStyle(style: self, configuration: configuration)
    }
}

private struct ResolvedMPMessageStyle<Style: MPMessageStyle>: View {
    let style: Style
    let configuration: Style.Configuration
    
    var body: some View {
        style.makeBody(configuration: configuration)
    }
}
