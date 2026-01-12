//
//  HelperStyleConfiguration.swift
//  MercadoPagoSDK
//
//  Created by SDK on 06/01/25.
//

import SwiftUI

/// Configuration object consumed by `HelperStyle`.
package struct HelperStyleConfiguration: Sendable {
    package let title: String
    package let icon: String?
    package let tone: HelperTone

    @MainActor
    package init(
        title: String,
        icon: String?,
        tone: HelperTone
    ) {
        self.title = title
        self.tone = tone
        self.icon = icon
    }
}
