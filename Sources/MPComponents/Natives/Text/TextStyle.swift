//
//  TextStyle.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 17/06/25.
//

import SwiftUI
import MPFoundation

package extension Text {
    
    /// Applies a custom text style to the current `Text` instance.
    ///
    /// This modifier resolves the given style and sets it in the view's environment,
    /// allowing child views to inherit the style.
    /// - Parameter style: The text style to be applied.
    /// - Returns: A `View` with the style applied and injected into the environment.
    @MainActor
    func textStyle(_ style: some TextStyle) -> some View {
        style.resolve(
            configuration: TextStyleConfiguration(
                content: self
            )
        )
        .environment(\.textStyle, style)
    }
}

/// The base text style used as the concrete implementation for `TextStyle`.
///
/// This struct defines a style by combining a semantic font style (`TextStyleCase`)
/// and a semantic color (`TextStyleColorType`). The actual `Font` and `Color` are
/// resolved dynamically using the `MPTheme` from the SwiftUI environment.
package struct BaseTextStyle: TextStyle {
    package typealias Configuration = TextStyleConfiguration

    @Environment(\.checkoutTheme) var theme: MPTheme

    package let id: String
    
    /// The semantic style case, which determines the font.
    ///
    /// Storing the case instead of the `Font` itself decouples the style definition
    /// from the theme at creation time, allowing it to adapt to theme changes.
    private let styleCase: TextStyleCase
    
    /// The semantic color type for the text.
    public let colorType: TextStyleColorType

    /// Initializes a base text style.
    /// - Parameters:
    ///   - styleCase: The semantic style case (e.g., title, body).
    ///   - colorType: The type of color based on theme tokens. Defaults to `.primary`.
    public init(
        styleCase: TextStyleCase,
        colorType: TextStyleColorType = .primary
    ) {
        self.styleCase = styleCase
        self.colorType = colorType
        self.id = String(describing: Self.self) + ".\(styleCase.id).\(colorType.id)"
    }

    /// Applies the font and color to the text based on the current theme.
    ///
    /// The font is resolved dynamically using the `styleCase` and the theme from the
    /// environment.
    /// - Parameter configuration: The configuration containing the original `Text`.
    public func makeBody(configuration: Configuration) -> some View {
        configuration
            .content
            .font(styleCase.font(from: theme))
            .foregroundColor(colorType.color(from: theme.colors))
    }
}

/// Represents the semantic color options for a `TextStyle`.
public enum TextStyleColorType: CaseIterable, Identifiable, Sendable {
    case primary
    case secondary
    case accent
    case disabled
    case negative
    case inverted

    public var id: Self { self }

    /// Returns the corresponding `Color` from the theme's color tokens.
    /// - Parameter colorTokens: The set of color tokens from the current theme.
    /// - Returns: The corresponding SwiftUI `Color`.
    public func color(from colorTokens: MPColors) -> Color {
        switch self {
        case .primary:
            return colorTokens.textPrimary
        case .secondary:
            return colorTokens.textSecondary
        case .accent:
            return colorTokens.textAccent
        case .disabled:
            return colorTokens.textDisabled
        case .negative:
            return colorTokens.textNegative
        case .inverted:
            return colorTokens.textInverted
        }
    }
}

/// Predefined semantic text style cases.
///
/// These cases map to specific fonts within the `MPTheme`'s typography.
package enum TextStyleCase: String, CaseIterable, Identifiable {
    case titleSmallSemibold
    case bodyMediumRegular
    case bodyMediumSemibold
    case bodySmallRegular
    case bodySmallSemibold
    case bodyExtraSmallSemibold

    package var id: Self { self }

    /// A helper method to retrieve the appropriate font from the theme.
    ///
    /// This centralizes the logic for mapping a semantic style to a concrete `Font`.
    /// - Parameter theme: The current theme from which to extract the font.
    /// - Returns: A `Font` corresponding to the style case.
    public func font(from theme: MPTheme) -> Font {
        switch self {
        case .titleSmallSemibold:
            return theme.typography.title.smallSemibold
        case .bodyMediumRegular:
            return theme.typography.body.medium.regular
        case .bodyMediumSemibold:
            return theme.typography.body.medium.semibold
        case .bodySmallRegular:
            return theme.typography.body.small.regular
        case .bodySmallSemibold:
            return theme.typography.body.small.semibold
        case .bodyExtraSmallSemibold:
            return theme.typography.body.extraSmallSemibold
        }
    }
}

/// Provides static factory methods for creating `BaseTextStyle` instances.
///
/// These static methods act as convenient shorthands for creating styles
/// without needing to reference the theme directly.
package extension TextStyle where Self == BaseTextStyle {
    // MARK: - Titles
    
    /// A small, semibold title style.
    static func titleSmallSemibold(colorType: TextStyleColorType = .primary) -> Self {
        Self(styleCase: .titleSmallSemibold, colorType: colorType)
    }
    
    // MARK: - Body Text

    /// A medium-sized, regular body text style.
    static func bodyMediumRegular(colorType: TextStyleColorType = .primary) -> Self {
        Self(styleCase: .bodyMediumRegular, colorType: colorType)
    }

    /// A medium-sized, semibold body text style.
    static func bodyMediumSemibold(colorType: TextStyleColorType = .primary) -> Self {
        Self(styleCase: .bodyMediumSemibold, colorType: colorType)
    }

    /// A small-sized, regular body text style.
    static func bodySmallRegular(colorType: TextStyleColorType = .primary) -> Self {
        Self(styleCase: .bodySmallRegular, colorType: colorType)
    }

    /// A small-sized, semibold body text style.
    static func bodySmallSemibold(colorType: TextStyleColorType = .primary) -> Self {
        Self(styleCase: .bodySmallSemibold, colorType: colorType)
    }
    
    /// An extra-small, semibold body text style.
    static func bodyExtraSmallSemibold(colorType: TextStyleColorType = .primary) -> Self {
        Self(styleCase: .bodyExtraSmallSemibold, colorType: colorType)
    }
}


// MARK: - Previews
#if DEBUG
private struct TextStyleList: View {
    @Environment(\.checkoutTheme) var theme: MPTheme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Preview of Text Styles")
                    .textStyle(.titleSmallSemibold())
                    .padding(.bottom)

                // Titles
                Group {
                    Text("Title Small Semibold (Primary)")
                        .textStyle(.titleSmallSemibold())
                    Text("Title Small Semibold (Accent)")
                        .textStyle(.titleSmallSemibold(colorType: .accent))
                }
                
                Divider()
                
                // Body Medium
                Group {
                    Text("Body Medium Regular")
                        .textStyle(.bodyMediumRegular())
                    Text("Body Medium Semibold")
                        .textStyle(.bodyMediumSemibold())
                    Text("Body Medium Regular (Secondary)")
                        .textStyle(.bodyMediumRegular(colorType: .secondary))
                }
                
                Divider()

                // Small Body
                Group {
                    Text("Body Small Regular")
                        .textStyle(.bodySmallRegular())
                    Text("Body Small Semibold")
                        .textStyle(.bodySmallSemibold())
                }
                
                Divider()
                
                // Extra Small Body
                Group {
                    Text("Body Extra Small Semibold (Disabled)")
                        .textStyle(.bodyExtraSmallSemibold(colorType: .disabled))
                    Text("Body Extra Small Semibold (Negative)")
                        .textStyle(.bodyExtraSmallSemibold(colorType: .negative))
                }
            }
            .padding()
        }
    }
}

private struct ThemedPreviewWrapper: View {
    
    public var body: some View {
        ThemeProvider(
            light: MPLightTheme(),
            dark: MPLightTheme()
        ) {
            TextStyleList()
        }
    }
}

#Preview("Light Theme") {
    ThemedPreviewWrapper()
        .preferredColorScheme(.light)
}

#Preview("Dark Theme") {
    ThemedPreviewWrapper()
        .preferredColorScheme(.dark)
}
#endif
