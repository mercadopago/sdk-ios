//
//  MPListItemTrailing.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 11/02/26.
//

import SwiftUI

/// Trailing content of an `MPListItem` (right side of the row).
///
/// Provides the data (text + color + optional action) for the trailing area.
/// The layout is controlled by the trailing **style** (`MPListItemTrailingStyle`).
package struct MPListItemTrailing {
    /// Optional text shown on the trailing side (e.g. price, label, action label).
    var text: String?
    /// Semantic color for the trailing text. Uses theme tokens when applied via text style.
    var color: TextStyleColorType?
    /// When set, the trailing side renders as an independently tappable action (e.g. "Modificar")
    /// instead of a passive label — see `MPTrailingActionButtonStyle`. `nil` keeps the row's own
    /// tap gesture (row selection) as the only interactive element.
    var action: (() -> Void)?

    package init(text: String? = nil, color: TextStyleColorType? = nil, action: (() -> Void)? = nil) {
        self.text = text
        self.color = color
        self.action = action
    }
}
