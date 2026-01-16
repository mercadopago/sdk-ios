//
//  BadgeStyleConfiguration.swift
//  MercadoPagoSDK
//
//  Created by SDK on 07/01/25.
//

import SwiftUI
import MPFoundation

/// Configuration object consumed by `MPBadgeIconStyle`.
package struct MPBadgeIconConfiguration: Sendable {
    package let kind: Logos.Feedback

    @MainActor
    package init(
        kind: Logos.Feedback
    ) {
        self.kind = kind
    }
}
