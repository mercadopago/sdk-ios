//
//  CardFieldConfig.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 10/04/26.
//
import UIKit

struct CardFieldConfig: Equatable {
    let type: String
    let length: LengthRange
    let mask: String?

    init(type: String, length: LengthRange, mask: String? = nil) {
        self.type = type
        self.length = length
        self.mask = mask
    }

    struct LengthRange: Equatable {
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
