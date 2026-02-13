//
//  MPListItemTrailing.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 11/02/26.
//

import SwiftUI

/// Trailing content of an `MPListItem` (right side of the row).
///
/// Can display optional text with a semantic color and an optional trailing type (e.g. icon or none).
package struct MPListItemTrailing {
    /// Kind of trailing element: an icon or nothing.
    package enum MPTrailingType {
        /// Show a trailing icon.
        case icon(Image)
        /// No trailing visual element.
        case none
    }

    /// Optional text shown on the trailing side (e.g. price, label).
    var text: String?
    /// Semantic color for the trailing text. Uses theme tokens when applied via text style.
    var color: TextStyleColorType?
    /// Optional trailing type (icon or none). When set, determines the rightmost element.
    var type: MPTrailingType?
    
    package init(text: String? = nil, color: TextStyleColorType? = nil, type: MPTrailingType? = nil) {
        self.text = text
        self.color = color
        self.type = type
    }
}
