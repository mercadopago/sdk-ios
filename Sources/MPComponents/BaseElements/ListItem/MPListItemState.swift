//
//  MPListItemState.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 11/02/26.
//

/// Visual and interaction state of `MPListItem`.
///
/// Defines the item’s appearance (background, text, and icon colors) and behavior within the list.
package enum MPListItemState {
    /// Default state: interactive, no highlight.
    case idle

    /// Selected or focused state: highlighted (e.g. active background).
    case active

    /// Disabled state: not interactive, with disabled text and icon colors.
    case disabled
}
