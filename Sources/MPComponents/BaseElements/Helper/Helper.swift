//
//  Helper.swift
//  MercadoPagoSDK
//
//  Created by SDK on 06/01/25.
//

import MPFoundation
import SwiftUI

/// Inline helper message optionally paired with a semantic badge.
package struct Helper: View {
    private let text: String
    private let tone: HelperTone

    private var badgeKind: Logos.Feedback? {
        switch self.tone {
        case .informative:
            return .informative
        case .caution:
            return .caution
        case .negative:
            return .negative
        case .positive:
            return .positive
        case .none:
            return nil
        }
    }

    @Environment(\.helperStyle) private var style: any HelperStyle

    /// Creates a helper label.
    /// - Parameters:
    ///   - text: Display text.
    ///   - tone: Semantic tone driving icon/color rules.
    package init(
        _ text: String,
        _ tone: HelperTone = .none
    ) {
        self.text = text
        self.tone = tone
    }

    package var body: some View {
        let configuration = HelperStyleConfiguration(
            title: text,
            badge: badgeKind,
            tone: tone
        )

        return AnyView(
            self.style.resolve(configuration: configuration)
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
