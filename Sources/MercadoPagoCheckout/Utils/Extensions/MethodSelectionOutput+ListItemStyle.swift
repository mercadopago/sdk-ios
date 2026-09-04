//
//  MethodSelectionOutput+ListItemStyle.swift
//  MercadoPagoSDK
//

import MPComponents
import MPFoundation
import SwiftUI

extension MethodSelectionOutput.LayoutType {
    /// Row style for the whole list (radio toggle vs. plain navigation row).
    var listItemStyle: any MPListItemStyle {
        switch self {
        case .chevron: .chevron
        case .radioButton: .radioButton
        }
    }

    /// Trailing accessory style: a chevron icon for navigation rows, none for radio rows.
    var trailingStyle: (any MPListItemTrailingStyle)? {
        switch self {
        case .chevron: .textIcon(Image(systemName: Logos.chevronRight))
        case .radioButton: nil
        }
    }

    /// Trailing data. Chevron rows need a (text-less) trailing container so the icon renders;
    /// radio rows have no trailing at all.
    var rowTrailing: MPListItemTrailing? {
        switch self {
        case .chevron: .init()
        case .radioButton: nil
        }
    }
}
