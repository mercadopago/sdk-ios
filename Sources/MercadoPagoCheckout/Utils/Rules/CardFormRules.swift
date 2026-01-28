//
//  CardFormRules.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 27/01/26.
//

import Foundation
import MPComponents

package struct CardFormRule: @unchecked Sendable {
    private var rule: any CardFormRuleType

    private init(_ rule: any CardFormRuleType) {
        self.rule = rule
    }

    package static func required(_ message: String) -> CardFormRule {
        CardFormRule(RequiredRule(message: message))
    }

    package static var cardNumber: CardFormRule {
        CardFormRule(CardNumberRule())
    }

    package static var expirationDate: CardFormRule {
        CardFormRule(ExpirationDateRule())
    }

    package static var securityCode: CardFormRule {
        CardFormRule(SecurityCodeRule())
    }

    package static var cardHolder: CardFormRule {
        CardFormRule(CardHolderRule())
    }

    package static var document: CardFormRule {
        CardFormRule(DocumentRule())
    }

    mutating func validate(_ value: String) -> String? {
        rule.validate(value)
    }

    mutating func setCardNumberRange(minLength: Int, maxLength: Int) -> Bool {
        rule.setCardNumberRange(minLength: minLength, maxLength: maxLength)
    }

    mutating func setSecurityCodeLength(_ length: Int) -> Bool {
        rule.setSecurityCodeLength(length)
    }

    mutating func setDocumentLength(_ length: Int) -> Bool {
        rule.setDocumentLength(length)
    }
}

package protocol CardFormRuleType: Sendable {
    mutating func validate(_ value: String) -> String?
    mutating func setCardNumberRange(minLength: Int, maxLength: Int) -> Bool
    mutating func setSecurityCodeLength(_ length: Int) -> Bool
    mutating func setDocumentLength(_ length: Int) -> Bool
}

extension CardFormRuleType {
    mutating func setCardNumberRange(minLength: Int, maxLength: Int) -> Bool { false }
    mutating func setSecurityCodeLength(_ length: Int) -> Bool { false }
    mutating func setDocumentLength(_ length: Int) -> Bool { false }
}

// MARK: - Rule Implementations

private struct RequiredRule: CardFormRuleType {
    let message: String

    func validate(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? message : nil
    }
}

private struct CardNumberRule: CardFormRuleType {
    private var minLength: Int
    private var maxLength: Int

    init(minLength: Int = 13, maxLength: Int = 19) {
        self.minLength = minLength
        self.maxLength = maxLength
    }

    mutating func validate(_ value: String) -> String? {
        let digits = value.filter { $0.isNumber }

        guard !digits.isEmpty else {
            return MPStrings.CardForm.CardNumber.errorEmpty
        }

        guard digits.count >= minLength else {
            return MPStrings.CardForm.CardNumber.errorIncomplete
        }

        guard digits.count <= maxLength else {
            return MPStrings.CardForm.CardNumber.errorInvalid
        }

        guard Self.isValidLuhn(digits) else {
            return MPStrings.CardForm.CardNumber.errorInvalid
        }

        return nil
    }

    mutating func setCardNumberRange(minLength: Int, maxLength: Int) -> Bool {
        self.minLength = minLength
        self.maxLength = maxLength
        return true
    }

    private static func isValidLuhn(_ number: String) -> Bool {
        guard !number.isEmpty else { return false }

        var sum = 0
        let digitStrings = number.reversed().map { String($0) }

        for tuple in digitStrings.enumerated() {
            guard let digit = Int(tuple.element) else { return false }

            let isOdd = tuple.offset % 2 == 1

            switch (isOdd, digit) {
            case (true, 9):
                sum += 9
            case (true, 0...8):
                sum += (digit * 2) % 9
            default:
                sum += digit
            }
        }

        return sum % 10 == 0
    }
}

private struct ExpirationDateRule: CardFormRuleType {
    mutating func validate(_ value: String) -> String? {
        let digits = value.filter { $0.isNumber }

        guard !digits.isEmpty else {
            return MPStrings.CardForm.Expiration.errorEmpty
        }

        guard digits.count == 4 else {
            return MPStrings.CardForm.Expiration.errorIncomplete
        }

        let monthString = String(digits.prefix(2))
        let yearString = String(digits.suffix(2))

        guard let month = Int(monthString), let year = Int(yearString) else {
            return MPStrings.CardForm.Expiration.errorInvalid
        }

        guard month >= 1 && month <= 12 else {
            return MPStrings.CardForm.Expiration.errorInvalid
        }

        let calendar = Calendar.current
        let currentDate = Date()
        let currentYear = calendar.component(.year, from: currentDate) % 100
        let currentMonth = calendar.component(.month, from: currentDate)

        guard year > currentYear || (year == currentYear && month >= currentMonth) else {
            return MPStrings.CardForm.Expiration.errorInvalid
        }

        return nil
    }
}

private struct SecurityCodeRule: CardFormRuleType {
    private var requiredLength: Int

    init(requiredLength: Int = 3) {
        self.requiredLength = requiredLength
    }

    mutating func validate(_ value: String) -> String? {
        let digits = value.filter { $0.isNumber }

        guard !digits.isEmpty else {
            return MPStrings.CardForm.CVV.errorEmpty
        }

        guard digits.count >= requiredLength else {
            return MPStrings.CardForm.CVV.errorIncomplete
        }

        return nil
    }

    mutating func setSecurityCodeLength(_ length: Int) -> Bool {
        requiredLength = length
        return true
    }
}

private struct CardHolderRule: CardFormRuleType {
    mutating func validate(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return MPStrings.CardForm.CardHolder.errorEmpty
        }
        return nil
    }
}

private struct DocumentRule: CardFormRuleType {
    private var requiredLength: Int

    init(requiredLength: Int = 19) {
        self.requiredLength = requiredLength
    }

    mutating func validate(_ value: String) -> String? {
        let digits = value.filter { $0.isNumber }

        guard !digits.isEmpty else {
            return MPStrings.CardForm.Document.errorEmpty
        }

        guard digits.count >= requiredLength else {
            return MPStrings.CardForm.Document.errorIncomplete
        }

        return nil
    }

    mutating func setDocumentLength(_ length: Int) -> Bool {
        requiredLength = length
        return true
    }
}
