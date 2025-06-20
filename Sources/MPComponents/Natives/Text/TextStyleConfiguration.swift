//
//  TextStyleConfiguration.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 17/06/25.
//

import SwiftUI
import MPFoundation

/// A protocol that defines the requirements for a text style.
///
/// Conform to this protocol to create custom text styles. It inherits from `StyleProtocol`
/// and is specialized for a `TextStyleConfiguration`.
package protocol TextStyle: StyleProtocol, Identifiable where Configuration == TextStyleConfiguration {}

/// A configuration structure that holds the original `Text` view to be styled.
package struct TextStyleConfiguration {
    /// The `Text` view that the style will be applied to.
    package let content: Text

    /// Creates a text style configuration.
    /// - Parameter content: The `Text` view to be styled.
    package init(content: Text) {
        self.content = content
    }
}

/// An environment key for storing the default text style.
@MainActor
package struct TextStyleKey: @preconcurrency EnvironmentKey {
    /// The default text style, which is `bodyMediumRegular`.
    public static let defaultValue: any TextStyle = BaseTextStyle.bodyMediumRegular()
}

/// An extension to provide access to the current text style within the SwiftUI environment.
package extension EnvironmentValues {
    /// The text style currently present in the environment.
    ///
    /// You can get and set this value to change the default text style for a view hierarchy.
    var textStyle: any TextStyle {
        get { self[TextStyleKey.self] }
        set { self[TextStyleKey.self] = newValue }
    }
}

extension TextStyle {
    /// Resolves the current style by applying the given configuration.
    ///
    /// This method wraps the style and its configuration in a `ResolvedTextStyle`
    /// view, which is responsible for rendering the final styled text.
    /// - Parameter configuration: The configuration containing the content to be styled.
    /// - Returns: A `View` with the style applied.
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedTextStyle(style: self, configuration: configuration)
    }
}

/// A helper view used to apply and render a text style.
private struct ResolvedTextStyle<Style: TextStyle>: View {
    let style: Style
    let configuration: Style.Configuration

    var body: some View {
        style.makeBody(configuration: configuration)
    }
}
