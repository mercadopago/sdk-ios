//
//  HelperStyleConfiguration.swift
//  MercadoPagoSDK
//
//  Created by SDK on 06/01/25.
//

import MPFoundation
import SwiftUI

/// Configuration object consumed by `HelperStyle`.
package struct HelperStyleConfiguration: Sendable {
    package let title: String
    package let badge: Logos.Feedback?
    package let tone: HelperTone

    @MainActor
    package init(
        title: String,
        badge: Logos.Feedback?,
        tone: HelperTone
    ) {
        self.title = title
        self.tone = tone
        self.badge = badge
    }
}
