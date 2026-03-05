//
//  String+OnlyNumbers.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 08/01/25.
//
import Foundation

package extension String {
    func onlyNumbers() -> String {
        components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
}
