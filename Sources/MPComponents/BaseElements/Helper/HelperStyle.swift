//
//  HelperStyle.swift
//  MercadoPagoSDK
//
//  Created by SDK on 06/01/25.
//

import SwiftUI
import MPFoundation

public enum HelperHierarchy: Sendable, Hashable {
    case loud
    case quiet
}

public enum HelperTone: Sendable, Hashable {
    case positive
    case negative
    case caution
    case informative
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
        HStack(spacing: theme.spacings.xnano) {
            if let icon = configuration.icon {
                Image(icon, bundle: .bundleMP)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 12, height: 12)
                    .padding(2) // Adicione padding se quiser que o fundo seja maior que o ícone
                    .background(iconColor(config: configuration))
                    .clipShape(Circle()) // O corte deve vir após o background
                    .foregroundColor(theme.colors.text.inverse)
            }
            
            Text(configuration.title)
                .textStyle(.smallMedium())
        }
    }
    
    
    func iconColor(config: HelperStyleConfiguration) -> Color {
        switch config.tone {
        case .positive:
            return theme.colors.feedback.textPositiveLoud
        case .negative:
            return theme.colors.feedback.textNegativeLoud
        case .caution:
            return theme.colors.feedback.textCautionLoud
        case .informative:
            return theme.colors.feedback.textInformativeLoud
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
        style.makeBody(configuration: configuration)
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
    func helperStyle<S: HelperStyle>(_ style: S) -> some View {
        environment(\.helperStyle, style)
    }

    /// Convenience overload to apply the default helper style with a given hierarchy.
    func helperStyle(_ hierarchy: HelperHierarchy) -> some View {
        helperStyle(HelperDefaultStyle(hierarchy: hierarchy))
    }
}

package extension HelperStyle where Self == HelperDefaultStyle {
    static func helper(_ hierarchy: HelperHierarchy = .loud) -> Self {
        HelperDefaultStyle(hierarchy: hierarchy)
    }

    static func loud() -> Self { HelperDefaultStyle(hierarchy: .loud) }
    static func quiet() -> Self { HelperDefaultStyle(hierarchy: .quiet) }
}


