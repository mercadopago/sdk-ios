//
//  MPListItemTrailing.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 11/02/26.
//

import SwiftUI

/// Trailing content of an `MPListItem` (right side of the row).
///
/// Provides the data (text + color) for the trailing area.
/// The layout is controlled by the trailing **style** (`MPListItemTrailingStyle`).
package struct MPListItemTrailing {
    /// Optional text shown on the trailing side (e.g. price, label).
    var text: String?
    /// Semantic color for the trailing text. Uses theme tokens when applied via text style.
    var color: TextStyleColorType?

    package init(text: String? = nil, color: TextStyleColorType? = nil) {
        self.text = text
        self.color = color
    }
}
