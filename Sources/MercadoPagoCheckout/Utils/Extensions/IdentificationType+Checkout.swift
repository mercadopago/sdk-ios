//
//  IdentificationType+Checkout.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 25/02/26.
//

import CoreMethods
import SwiftUI

extension IdentificationType {
    func getPlaceholder() -> String {
        if !placeholder.isEmpty { return placeholder }
        switch id {
        case "CPF": return "999.999.999-99"
        case "CNPJ": return "99.999.999/9999-99"
        default: return ""
        }
    }

    func getFormat() -> String {
        if !mask.isEmpty { return mask }
        switch id {
        case "CPF": return "###.###.###-##"
        case "CNPJ": return type == "string" ? "AA.AAA.AAA/AAAA-##" : "##.###.###/####-##"
        default: return ""
        }
    }

    func getKeyboardType() -> UIKeyboardType {
        switch type.lowercased() {
        case "number": return .numberPad
        case "string": return .default
        default: return .default
        }
    }
}
