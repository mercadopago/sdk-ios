//
//  MPFeedbackStyle.swift
//  MercadoPagoSDK
//

import MPFoundation
import SwiftUI

package protocol MPFeedbackStyle: StyleProtocol where Configuration == MPFeedbackStyleConfiguration {}

package struct MPDefaultFeedbackStyle: MPFeedbackStyle {
    private static let iconSize: MPIconSize = .huge

    @Environment(\.checkoutTheme) private var theme: MPTheme

    package init() {}

    @MainActor
    package func makeBody(configuration: MPFeedbackStyleConfiguration) -> some View {
        VStack(alignment: .leading, spacing: self.theme.spacings.xtiny) {
            MPIcon(
                source: configuration.iconSource,
                size: Self.iconSize,
                color: configuration.iconColor,
                isDecorative: true
            )
            configuration.title
                .textStyle(.headingHuge())
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

package extension MPFeedbackStyle {
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedMPFeedbackStyle(style: self, configuration: configuration)
    }
}

private struct ResolvedMPFeedbackStyle<Style: MPFeedbackStyle>: View {
    let style: Style
    let configuration: Style.Configuration

    var body: some View {
        self.style.makeBody(configuration: self.configuration)
    }
}

private struct MPFeedbackStyleKey: @preconcurrency EnvironmentKey {
    @MainActor static var defaultValue: any MPFeedbackStyle = MPDefaultFeedbackStyle()
}

extension EnvironmentValues {
    var mpFeedbackStyle: any MPFeedbackStyle {
        get { self[MPFeedbackStyleKey.self] }
        set { self[MPFeedbackStyleKey.self] = newValue }
    }
}

package extension View {
    func mpFeedbackStyle(_ style: some MPFeedbackStyle) -> some View {
        environment(\.mpFeedbackStyle, style)
    }
}

#if DEBUG
    #Preview("MPFeedback — Default") {
        ThemeProvider(light: MPLightTheme(), dark: MPLightTheme()) {
            MPFeedback(
                title: "Pagamento aprovado",
                iconSource: .system(name: "checkmark.circle.fill")
            )
            .mpFeedbackStyle(MPDefaultFeedbackStyle())
            .padding()
        }
    }
#endif
