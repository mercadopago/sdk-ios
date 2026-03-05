//
//  String+ApplyMask.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 08/01/25.
//

import Foundation

package extension String {
    func applyMask(_ pattern: String, separator: Character) -> String {
        let numbers = onlyNumbers()
        var result = ""
        var index = numbers.startIndex

        for char in pattern {
            guard index < numbers.endIndex else { break }

            if char == "#" {
                result.append(numbers[index])
                index = numbers.index(after: index)
            } else {
                result.append(separator)
            }
        }

        return result
    }
}
