//
//  BadgeStyle.swift
//  MercadoPagoSDK
//
//  Created by SDK on 07/01/25.
//

import SwiftUI
import MPFoundation

package protocol MPBadgeIconStyle: StyleProtocol, Identifiable where Configuration == MPBadgeIconConfiguration {}

package struct BadgeMicroStyle: MPBadgeIconStyle {
    package var id: UUID = .init()

    @Environment(\.checkoutTheme) private var theme: MPTheme

    package func makeBody(configuration: MPBadgeIconConfiguration) -> some View {
        Image(decorative: configuration.kind.assetName, bundle: .bundleMP)
            .renderingMode(.template)
            .resizable()
            .frame(width: 12, height: 12)
            .background(backgroundColor(for: configuration.kind))
            .clipShape(Circle())
            .foregroundColor(theme.colors.text.inverse)
            .accessibility(hidden:true)
    }

    private func backgroundColor(for kind: Logos.Feedback) -> Color {
        switch kind {
        case .positive:
            return theme.colors.feedback.fillPositiveLoud
        case .negative:
            return theme.colors.feedback.fillNegativeLoud
        case .caution:
            return theme.colors.feedback.fillCautionLoud
        case .informative:
            return theme.colors.feedback.fillInformativeLoud
        }
    }
}

// MARK: - Style Resolution
package extension MPBadgeIconStyle {
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedBadgeStyle(style: self, configuration: configuration)
    }
}

private struct ResolvedBadgeStyle<Style: MPBadgeIconStyle>: View {
    let style: Style
    let configuration: Style.Configuration

    var body: some View {
        style.makeBody(configuration: configuration)
    }
}

// MARK: - Environment
private struct BadgeStyleKey: @preconcurrency EnvironmentKey {
    @MainActor
    static var defaultValue: any MPBadgeIconStyle = BadgeMicroStyle()
}

extension EnvironmentValues {
    var badgeStyle: any MPBadgeIconStyle {
        get { self[BadgeStyleKey.self] }
        set { self[BadgeStyleKey.self] = newValue }
    }
}

package extension View {
    /// Sets the style for `Badge` within this view hierarchy.
    func badgeStyle<S: MPBadgeIconStyle>(_ style: S) -> some View {
        environment(\.badgeStyle, style)
    }
}

package extension MPBadgeIconStyle where Self == BadgeMicroStyle {
    static func badge() -> Self {
        BadgeMicroStyle()
    }
}
