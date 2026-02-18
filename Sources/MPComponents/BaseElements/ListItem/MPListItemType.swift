//
//  MPListItemType.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 13/02/26.
//
import SwiftUI

/// Leading interactive element of an `MPListItem` (left side of the row).
///
/// Defines the type of selection control displayed at the start of the list item.
package enum MPListItemType {
    /// Display a radio button with a bindable selection state.
    case radioButton(selected: Bool)
    /// No leading interactive element.
    case none
}
