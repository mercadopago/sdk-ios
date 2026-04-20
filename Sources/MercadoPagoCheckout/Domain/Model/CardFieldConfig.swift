//
//  CardFieldConfig.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 10/04/26.
//
import UIKit

struct CardFieldConfig {
    let type: String
    let length: LengthRange

    struct LengthRange {
        let min: Int
        let max: Int
    }

    func getKeyboardType() -> UIKeyboardType {
        switch self.type.lowercased() {
        case "number": return .numberPad
        case "string": return .default
        default: return .default
        }
    }
}
