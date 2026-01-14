//
//  BadgeStyleConfiguration.swift
//  MercadoPagoSDK
//
//  Created by SDK on 07/01/25.
//

import SwiftUI
import MPFoundation

/// Configuration object consumed by `BadgeStyle`.
package struct BadgeStyleConfiguration: Sendable {
    package let kind: Logos.Feedback

    @MainActor
    package init(
        kind: Logos.Feedback
    ) {
        self.kind = kind
    }
}
