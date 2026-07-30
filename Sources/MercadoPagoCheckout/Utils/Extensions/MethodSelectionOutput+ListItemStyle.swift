//
//  MethodSelectionOutput+ListItemStyle.swift
//  MercadoPagoSDK
//

import MPComponents

extension MethodSelectionOutput.LayoutType {
    var listItemStyle: any MPListItemStyle {
        switch self {
        case .chevron: .chevron
        case .radioButton: .radioButton
        }
    }
}
