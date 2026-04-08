//
//  TextStyle.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 17/06/25.
//

import MPFoundation
import SwiftUI

package extension View {
    /// Applies a custom text style to the current view.
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
            .font(self.styleCase.font(from: self.theme))
            .foregroundColor(self.colorType.color(from: self.theme.colors))
    }
}

/// Represents the semantic color options for a `TextStyle`.
public enum TextStyleColorType: CaseIterable, Identifiable, Sendable {
    case primary
    case secondary
    case accent
    case disabled
    case inverted

    case feedbackPositive
    case feedbackNegative
    case feedbackCaution
    case feedbackInformative

    public var id: Self {
        self
    }

    /// Returns the corresponding `Color` from the theme's color tokens.
    /// - Parameter colorTokens: The set of color tokens from the current theme.
    /// - Returns: The corresponding SwiftUI `Color`.
    public func color(from colorTokens: MPColors) -> Color {
        switch self {
        case .primary:
            return colorTokens.text.primary
        case .secondary:
            return colorTokens.text.secondary
        case .accent:
            return colorTokens.text.accent
        case .disabled:
            return colorTokens.text.disabled
        case .inverted:
            return colorTokens.text.inverse
        case .feedbackPositive:
            return colorTokens.feedback.textPositiveLoud
        case .feedbackNegative:
            return colorTokens.feedback.textNegativeLoud
        case .feedbackCaution:
            return colorTokens.feedback.textCautionLoud
        case .feedbackInformative:
            return colorTokens.feedback.textInformativeLoud
        }
    }
}

/// Predefined semantic text style cases.
///
/// These cases map to specific fonts within the `MPTheme`'s typography.
package enum TextStyleCase: String, CaseIterable, Identifiable {
    case headingHuge
    case headingLarge
    case headingMedium
    case headingSmall

    case large
    case largeEmphasis

    case bodyMediumTitle
    case bodyMedium
    case bodyMediumEmphasis

    case smallMedium
    case smallMediumEmphasis

    package var id: Self {
        self
    }

    /// A helper method to retrieve the appropriate font from the theme.
    ///
    /// This centralizes the logic for mapping a semantic style to a concrete `Font`.
    /// - Parameter theme: The current theme from which to extract the font.
    /// - Returns: A `Font` corresponding to the style case.
    public func font(from theme: MPTheme) -> Font {
        switch self {
        case .headingHuge:
            theme.typography.heading.huge.toFont()
        case .headingLarge:
            theme.typography.heading.large.toFont()
        case .headingMedium:
            theme.typography.heading.medium.toFont()
        case .headingSmall:
            theme.typography.heading.small.toFont()
        case .large:
            theme.typography.body.large.default.toFont()
        case .largeEmphasis:
            theme.typography.body.large.emphasis.toFont()
        case .bodyMediumTitle:
            theme.typography.body.medium.title.toFont()
        case .bodyMedium:
            theme.typography.body.medium.default.toFont()
        case .bodyMediumEmphasis:
            theme.typography.body.medium.emphasis.toFont()
        case .smallMedium:
            theme.typography.body.small.default.toFont()
        case .smallMediumEmphasis:
            theme.typography.body.small.emphasis.toFont()
        }
    }
}

/// Provides static factory methods for creating `BaseTextStyle` instances.
///
/// These static methods act as convenient shorthands for creating styles
/// without needing to reference the theme directly.
package extension TextStyle where Self == BaseTextStyle {
    // MARK: - Heading

    static func headingHuge(colorType: TextStyleColorType = .primary) -> Self {
        Self(styleCase: .headingHuge, colorType: colorType)
    }

    static func headingLarge(colorType: TextStyleColorType = .primary) -> Self {
        Self(styleCase: .headingLarge, colorType: colorType)
    }

    static func headingMedium(colorType: TextStyleColorType = .primary) -> Self {
        Self(styleCase: .headingMedium, colorType: colorType)
    }

    static func headingSmall(colorType: TextStyleColorType = .primary) -> Self {
        Self(styleCase: .headingSmall, colorType: colorType)
    }

    // MARK: - Body Text

    /// A medium-sized, regular body text style.
    ///
    static func large(colorType: TextStyleColorType = .primary) -> Self {
        Self(styleCase: .large, colorType: colorType)
    }

    static func largeEmphasis(colorType: TextStyleColorType = .primary) -> Self {
        Self(styleCase: .largeEmphasis, colorType: colorType)
    }

    /// A medium-sized, semibold body text style.
    static func bodyMedium(colorType: TextStyleColorType = .primary) -> Self {
        Self(styleCase: .bodyMedium, colorType: colorType)
    }

    /// A small-sized, regular body text style.
    static func bodyMediumEmphasis(colorType: TextStyleColorType = .primary) -> Self {
        Self(styleCase: .bodyMediumEmphasis, colorType: colorType)
    }

    /// A small-sized, semibold body text style.
    static func bodyMediumTitle(colorType: TextStyleColorType = .primary) -> Self {
        Self(styleCase: .bodyMediumTitle, colorType: colorType)
    }

    /// An extra-small, semibold body text style.
    static func smallMedium(colorType: TextStyleColorType = .primary) -> Self {
        Self(styleCase: .smallMedium, colorType: colorType)
    }

    static func smallMediumEmphasis(colorType: TextStyleColorType = .primary) -> Self {
        Self(styleCase: .smallMediumEmphasis, colorType: colorType)
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
                        .textStyle(.headingHuge())
                        .padding(.bottom)

                    // Titles
                    Group {
                        Text("Title Small Semibold (Primary)")
                            .textStyle(.headingHuge())
                        Text("Title Small Semibold (Accent)")
                            .textStyle(.headingSmall(colorType: .accent))
                    }

                    Divider()

                    // Body Medium
                    Group {
                        Text("Body Medium Regular")
                            .textStyle(.bodyMedium())
                        Text("Body Medium Semibold")
                            .textStyle(.bodyMediumEmphasis())
                        Text("Body Medium Regular (Secondary)")
                            .textStyle(.bodyMediumTitle(colorType: .secondary))
                    }

                    Divider()

                    // Small Body
                    Group {
                        Text("Body Small Regular")
                            .textStyle(.smallMedium())
                        Text("Body Small Semibold")
                            .textStyle(.smallMediumEmphasis())
                    }

                    Divider()
                }
                .padding()
            }
        }
    }

    private struct ThemedPreviewWrapper: View {
        var body: some View {
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
