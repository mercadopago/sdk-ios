//
//  PillTextStyle.swift
//  DS
//
//  Created by Guilherme Prata Costa on 27/05/25.
//
import SwiftUI
import MPFoundation

/// A text style that displays text inside a pill-shaped badge.
///
/// Use this style to highlight short, important pieces of information, such as a status indicator.
///
/// ```swift
/// Text("Success")
///     .textStyle(.badge(.success))
/// ```
package struct PillTextStyle: TextStyle {
    package typealias Configuration = TextStyleConfiguration
    
    @Environment(\.checkoutTheme) var theme: MPTheme
    
    public let id = String(describing: Self.self)
    
    /// The type of pill, which defines its colors.
    public let pillType: PillType
    
    /// Initializes a pill style.
    ///
    /// - Parameters:
    ///   - pillType: The type of pill, which defines its colors and style. Defaults to ``PillType/success``.
    public init(
        pillType: PillType = .success
    ) {
        self.pillType = pillType
    }
    
    /// Applies the pill style to the text.
    ///
    /// - Parameter configuration: The configuration containing the original `Text` view.
    /// - Returns: A view with the pill style applied.
    public func makeBody(configuration: Configuration) -> some View {
        configuration
            .content
            .font(theme.typography.body.extraSmallSemibold)
            .foregroundColor(pillType.textColor(from: theme.colors))
            .padding(.horizontal, theme.spacings.xs)
            .background(
                RoundedRectangle(cornerRadius: theme.borderRadius.s)
                    .fill(
                        pillType.backgroundColor(from: theme.colors)
                    )
            )
    }
}

/// The available types of pills, defining their visual appearance.
public enum PillType: CaseIterable, Identifiable, Sendable {
    /// A style for success messages.
    case success
    
    public var id: Self { self }
    
    /// Returns the background color for the pill.
    ///
    /// - Parameter color: The theme's color tokens.
    /// - Returns: The corresponding background color.
    public func backgroundColor(from color: MPColors) -> Color {
        switch self {
        case .success:
            return color.feedbackPositiveSecondary
        }
    }
    
    /// Returns the text color for the pill.
    ///
    /// - Parameter color: The theme's color tokens.
    /// - Returns: The corresponding text color.
    public func textColor(from color: MPColors) -> Color {
        switch self {
        case .success:
            return color.feedbackPositive
        }
    }
}

extension TextStyle where Self == PillTextStyle {
    /// A text style that displays text inside a pill-shaped badge.
    ///
    /// - Parameter type: The type of pill to use. Defaults to ``PillType/success``.
    /// - Returns: A configured pill text style.
    @MainActor
    static func badge(_ type: PillType = .success) -> Self {
        Self(pillType: type)
    }
}
