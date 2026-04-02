//
//  MPMessageStyle.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 15/01/26.
//
import MPFoundation
import SwiftUI

package protocol MPMessageStyle: StyleProtocol, Identifiable where Configuration == MPMessageConfiguration {}

package struct MPDefaultMessageStyle: MPMessageStyle {
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

                configuration.message

                Spacer()
                configuration.closeButton
                    .foregroundColor(self.theme.colors.icon.secondary)
            }
            .padding(self.theme.spacings.paddings.xtiny)
        }
        .background(
            RoundedRectangle(cornerRadius: self.theme.borderRadius.xlarge)
                .fill(self.backgroundColor(for: configuration.state))
        )
        .padding(self.theme.spacings.paddings.xtiny)
    }

    private func backgroundColor(for state: MPMessageState) -> Color {
        switch state {
        case .informative:
            return self.theme.colors.feedback.informative.fillQuiet
        case .positive:
            return self.theme.colors.feedback.positive.fillQuiet
        case .negative:
            return self.theme.colors.feedback.negative.fillQuiet
        case .caution:
            return self.theme.colors.feedback.caution.fillQuiet
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
    func messageStyle(_ style: some MPMessageStyle) -> some View {
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
        self.style.makeBody(configuration: self.configuration)
    }
}
