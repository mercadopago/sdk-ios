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
    package let size: MPBadgeIconSize
    
    @MainActor
    package init(
        kind: Logos.Feedback,
        size: MPBadgeIconSize = .small
    ) {
        self.kind = kind
        self.size = size
    }
}

package enum MPBadgeIconSize: CGFloat {
    case small = 12
    case large = 20
}
