//
//  Helper.swift
//  MercadoPagoSDK
//
//  Created by SDK on 06/01/25.
//

import SwiftUI
import MPFoundation

/// Inline helper message paired with an optional icon from the SDK bundle.
package struct Helper: View {
    private let text: String
    private let tone: HelperTone
    
    private var iconName: String? {
        switch tone {
        case .informative:
            return "Feedback-info"
        case .caution:
            return "Feedback-Caution"
        case .negative:
            return "Feedback-Minus"
        case .positive:
            return "Feedback-Check"
        case .none:
            return nil
        }
    }

    @Environment(\.helperStyle) private var style: any HelperStyle

    /// Creates a helper label.
    /// - Parameters:
    ///   - text: Display text.
    ///   - tone: Semantic tone driving icon/color rules.
    ///   - icon: Optional bundle asset name to show next to the text.
    package init(
        _ text: String,
        _ tone: HelperTone = .none,
    ) {
        self.text = text
        self.tone = tone
    }

    package var body: some View {
        let configuration = HelperStyleConfiguration(
            title: text,
            icon: iconName,
            tone: tone
        )

        return AnyView(
            style.resolve(configuration: configuration)
        )
    }
}


#Preview {
    ThemeProvider(light: MPLightTheme(), dark: MPLightTheme()) {
        VStack(spacing: 16) {
            Helper("Helper text", .positive).helperStyle(.quiet)
        }
        .padding()
    }
}

