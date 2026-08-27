//
//  HelperStyle.swift
//  MercadoPagoSDK
//
//  Created by SDK on 06/01/25.
//

import MPFoundation
import SwiftUI

public enum HelperHierarchy: Sendable, Hashable {
    case loud
    case quiet
}

public enum HelperTone: Sendable, Hashable {
    case positive
    case negative
    case caution
    case informative
    case none
}

/// A style protocol for `Helper` enabling custom skins.
package protocol HelperStyle: StyleProtocol, Identifiable where Configuration == HelperStyleConfiguration {}

/// Default visual style for `Helper` using theme typography and colors.
package struct HelperDefaultStyle: HelperStyle {
    package var id: UUID = .init()
    private let hierarchy: HelperHierarchy

    @Environment(\.checkoutTheme) private var theme: MPTheme

    package init(hierarchy: HelperHierarchy = .loud) {
        self.hierarchy = hierarchy
    }

    @MainActor
    package func makeBody(configuration: HelperStyleConfiguration) -> some View {
        HStack(spacing: self.theme.spacings.xnano) {
            if let badge = configuration.badge {
                MPBadgeIcon(badge)
            }

            Text(configuration.title)
                .textStyle(self.textStyle(config: configuration))
        }
    }

    func textStyle(config: HelperStyleConfiguration) -> BaseTextStyle {
        switch self.hierarchy {
        case .quiet:
            return .smallMedium(colorType: .secondary)
        case .loud:
            switch config.tone {
            case .positive:
                return .smallMediumEmphasis(colorType: .feedbackPositive)
            case .negative:
                return .smallMediumEmphasis(colorType: .feedbackNegative)
            case .caution:
                return .smallMediumEmphasis(colorType: .feedbackCaution)
            case .informative:
                return .smallMediumEmphasis(colorType: .feedbackInformative)
            case .none:
                return .smallMedium(colorType: .secondary)
            }
        }
    }
}

// MARK: - Style Resolution

package extension HelperStyle {
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedHelperStyle(style: self, configuration: configuration)
    }
}

private struct ResolvedHelperStyle<Style: HelperStyle>: View {
    let style: Style
    let configuration: Style.Configuration

    var body: some View {
        self.style.makeBody(configuration: self.configuration)
    }
}

// MARK: - Environment

private struct HelperStyleKey: @preconcurrency EnvironmentKey {
    @MainActor
    static var defaultValue: any HelperStyle = HelperDefaultStyle()
}

extension EnvironmentValues {
    var helperStyle: any HelperStyle {
        get { self[HelperStyleKey.self] }
        set { self[HelperStyleKey.self] = newValue }
    }
}

package extension View {
    /// Sets the style for `Helper` within this view hierarchy.
    func helperStyle(_ style: some HelperStyle) -> some View {
        environment(\.helperStyle, style)
    }

    /// Convenience overload to apply the default helper style with a given hierarchy.
    func helperStyle(_ hierarchy: HelperHierarchy) -> some View {
        self.helperStyle(HelperDefaultStyle(hierarchy: hierarchy))
    }
}

package extension HelperStyle where Self == HelperDefaultStyle {
    static func helper(_ hierarchy: HelperHierarchy = .loud) -> Self {
        HelperDefaultStyle(hierarchy: hierarchy)
    }

    static func loud() -> Self { HelperDefaultStyle(hierarchy: .loud) }
    static func quiet() -> Self { HelperDefaultStyle(hierarchy: .quiet) }
}
