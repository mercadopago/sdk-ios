//
//  MPBadgeIcon.swift
//  MercadoPagoSDK
//
//  Created by SDK on 07/01/25.
//

import MPFoundation
import SwiftUI

/// Circular badge that displays feedback icons.
package struct MPBadgeIcon: View {
    private let kind: Logos.Feedback
    private let size: MPBadgeIconSize

    @Environment(\.badgeStyle) private var style: any MPBadgeIconStyle

    /// Creates a badge.
    /// - Parameters:
    ///   - kind: Semantic type that defines the asset and color palette.
    package init(
        _ kind: Logos.Feedback,
        _ size: MPBadgeIconSize = .small
    ) {
        self.kind = kind
        self.size = size
    }

    package var body: some View {
        let configuration = MPBadgeIconConfiguration(
            kind: kind,
            size: size
        )

        return AnyView(
            self.style.resolve(configuration: configuration)
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
        HStack(spacing: 16) {
            MPBadgeIcon(.positive, .large)
            MPBadgeIcon(.negative, .large)
            MPBadgeIcon(.informative, .large)
            MPBadgeIcon(.caution, .large)
        }
        .padding()
    }
}
