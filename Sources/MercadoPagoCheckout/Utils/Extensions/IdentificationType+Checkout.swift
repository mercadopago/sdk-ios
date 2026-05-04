//
//  IdentificationType+Checkout.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 25/02/26.
//

import CoreMethods
import MPComponents
import SwiftUI

extension IdentificationType: MPPickerOption {
    package var displayName: String { name }
}

extension IdentificationType {
    func getPlaceholder() -> String {
        switch id {
        case "CPF": return "999.999.999-99"
        case "CNPJ": return "99.999.999/9999-99"
        default: return ""
        }
    }

    func getFormat() -> String {
        switch id {
        case "CPF": return "###.###.###-##"
        case "CNPJ": return type == "string" ? "AA.AAA.AAA/AAAA-##" : "##.###.###/####-##"
        default: return ""
        }
    }

    func getKeyboardType() -> UIKeyboardType {
        switch type {
        case "number": return .numberPad
        case "string": return .default
        default: return .default
        }
    }
}
