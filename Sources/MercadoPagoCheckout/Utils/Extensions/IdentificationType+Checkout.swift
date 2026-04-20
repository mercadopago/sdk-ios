//
//  IdentificationType+Checkout.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 25/02/26.
//

import CoreMethods
import SwiftUI

extension IdentificationType {
    func getPlaceholder() -> String? {
        return placeholder
    }

    func getFormat() -> String? {
        return mask
    }

    func getKeyboardType() -> UIKeyboardType {
        switch type.lowercased() {
        case "number": return .numberPad
        case "string": return .default
        default: return .default
        }
    }
}
