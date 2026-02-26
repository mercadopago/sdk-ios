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
        switch id {
        case "CPF":  return "999.999.999-99"
        case "CNPJ": return "99.999.999/9999-99"
        default:     return ""
        }
    }

    func getFormat() -> String {
        switch id {
        case "CPF":  return "###.###.###-##"
        case "CNPJ": return "##.###.###/####-##"
        default:     return ""
        }
    }
    
    func getKeyboardType() -> UIKeyboardType {
        switch type {
        case "number":  return .numberPad
        case "numeric": return .default
        default:     return .default
        }
    }
}
