//
//  CardFormRules.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 27/01/26.
//

import Foundation
import MPComponents

package enum CardValidationRequirement {
    case cardNumberRange(min: Int, max: Int)
    case securityCodeLength(Int)
    case documentLength(Int)
}

package protocol CardFormRuleType {
    func validate(_ value: String) -> String?
    mutating func apply(_ requirement: CardValidationRequirement)
}

extension CardFormRuleType {
    mutating package func apply(_ requirement: CardValidationRequirement) {}

}

// MARK: Rules
package struct RequiredRule: CardFormRuleType {
    let msg: String
    
    init(_ msg: String) {
        self.msg = msg
    }
    
    package func validate(_ value: String) -> String? {
        value.trimmingCharacters(in: .whitespaces).isEmpty ? msg : nil
    }
}

// MARK: Card Number Rule

package struct CardNumberRule: CardFormRuleType {
    private var min = 13, max = 19

    mutating package func apply(_ requirement: CardValidationRequirement) {
        if case let .cardNumberRange(newMin, newMax) = requirement {
            self.min = newMin; self.max = newMax
        }
    }

    package func validate(_ value: String) -> String? {
        let digits = value.filter(\.isNumber)
        if digits.isEmpty { return MPStrings.CardForm.CardNumber.errorEmpty }
        if digits.count < min { return MPStrings.CardForm.CardNumber.errorIncomplete }
        if digits.count > max || !luhnCheck(digits) { return MPStrings.CardForm.CardNumber.errorInvalid }
        return nil
    }

    private func luhnCheck(_ text: String) -> Bool {
        var sum = 0
        for (index, count) in text.reversed().enumerated() {
            guard let dex = Int(String(count)) else { return false }
            sum += index.isMultiple(of: 2) ? dex : ((dex * 2 > 9) ? (dex * 2 - 9) : dex * 2)
        }
        return sum % 10 == 0
    }
}

package struct ExpirationDateRule: CardFormRuleType {
    package func validate(_ value: String) -> String? {
        let digits = value.filter(\.isNumber)
        if digits.isEmpty { return MPStrings.CardForm.Expiration.errorEmpty }
        guard digits.count == 4 else { return MPStrings.CardForm.Expiration.errorIncomplete }

        let month = Int(digits.prefix(2)) ?? 0
        let year = (Int(digits.suffix(2)) ?? 0) + 2000
        
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())

        let isInvalidMonth = !(1...12).contains(month)
        let isExpired = year < currentYear || (year == currentYear && month < currentMonth)

        return (isInvalidMonth || isExpired) ? MPStrings.CardForm.Expiration.errorInvalid : nil
    }
}

// MARK: - Security Code Rule
package struct SecurityCodeRule: CardFormRuleType {
    private var length = 3
    mutating package func apply(_ requirement: CardValidationRequirement) {
        if case let .securityCodeLength(newLen) = requirement { self.length = newLen }
    }
    package func validate(_ value: String) -> String? {
        let digits = value.filter(\.isNumber)
        if digits.isEmpty { return MPStrings.CardForm.CVV.errorEmpty }
        return digits.count < length ? MPStrings.CardForm.CVV.errorIncomplete : nil
    }
}

// MARK: - Document Rule
package struct DocumentRule: CardFormRuleType {
    private var length = 19
    
    mutating package func apply(_ requirement: CardValidationRequirement) {
        if case let .documentLength(newLen) = requirement { self.length = newLen }
    }
    
    package func validate(_ value: String) -> String? {
        let digits = value.filter(\.isNumber)
        if digits.isEmpty { return MPStrings.CardForm.Document.errorEmpty }
        return digits.count < length ? MPStrings.CardForm.Document.errorIncomplete : nil
    }
}

// MARK: - Card Holder Rule
package struct CardHolderRule: CardFormRuleType {
    package func validate(_ value: String) -> String? {
        let clearValue = value.trimmingCharacters(in: .whitespaces)
        guard !clearValue.isEmpty else { return MPStrings.CardForm.CardHolder.errorEmpty }
        return clearValue.count > 1 ? MPStrings.CardForm.CardHolder.errorIncomplete : nil
    }
}
