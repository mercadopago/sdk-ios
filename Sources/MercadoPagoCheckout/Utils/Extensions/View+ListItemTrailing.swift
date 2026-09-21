//
//  View+ListItemTrailing.swift
//  MercadoPagoSDK
//

import MPComponents
import SwiftUI

extension View {
    /// Applies a trailing style to `MPListItem`s below only when `style` is non-nil.
    func listItemTrailingStyleIfPresent(_ style: MPListItemTrailingStyle?) -> AnyView {
        if let style {
            return AnyView(self.listItemTrailingStyle(style))
        } else {
            return AnyView(self)
        }
    }
}
