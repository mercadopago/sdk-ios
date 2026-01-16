//
//  Badge.swift
//  MercadoPagoSDK
//
//  Created by SDK on 07/01/25.
//

import SwiftUI
import MPFoundation

/// Circular badge that displays feedback icons.
package struct MPBadgeIcon: View {
    private let kind: Logos.Feedback

    @Environment(\.badgeStyle) private var style: any MPBadgeIconStyle

    /// Creates a badge.
    /// - Parameters:
    ///   - kind: Semantic type that defines the asset and color palette.
    package init(
        _ kind: Logos.Feedback,
    ) {
        self.kind = kind
    }

    package var body: some View {
        let configuration = MPBadgeIconConfiguration(
            kind: kind
        )

        return AnyView(
            style.resolve(configuration: configuration)
        )
    }
}

#Preview {
    ThemeProvider(light: MPLightTheme(), dark: MPLightTheme()) {
        HStack(spacing: 16) {
            MPBadgeIcon(.positive)
            MPBadgeIcon(.negative)
            MPBadgeIcon(.informative)
            MPBadgeIcon(.caution)
        }
        .padding()
    }
}
