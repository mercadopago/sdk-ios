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
    case cardNumberExternalError(CardAcceptanceError?)
    case securityCodeLength(Int)
    case documentLength(min: Int, max: Int)
    case documentType(isNumeric: Bool)
}

// MARK: - Field Error

package enum CardFormErrorType {
    case empty
    case incomplete
    case invalid
}

package struct CardFormFieldError {
    package let type: CardFormErrorType
    package let message: String
}

// MARK: - Rule Protocol

package protocol CardFormRuleType {
    func validate(_ value: String) -> CardFormFieldError?
    func validateLive(_ value: String) -> String?
    mutating func apply(_ requirement: CardValidationRequirement)
}

extension CardFormRuleType {
    package mutating func apply(_: CardValidationRequirement) {}
    package func validateLive(_: String) -> String? {
        nil
    }
}

// MARK: Rules

package struct RequiredRule: CardFormRuleType {
    let msg: String

    init(_ msg: String) {
        self.msg = msg
    }

    package func validate(_ value: String) -> CardFormFieldError? {
        guard value.trimmingCharacters(in: .whitespaces).isEmpty else { return nil }
        return CardFormFieldError(type: .empty, message: self.msg)
    }
}

// MARK: Card Number Rule

package struct CardNumberRule: CardFormRuleType {
    private let validation: CardFormFields.CardNumberField.Validation
    private var min: Int
    private var max: Int
    private var externalError: CardAcceptanceError?

    init(validation: CardFormFields.CardNumberField.Validation, min: Int = 13, max: Int = 19) {
        self.validation = validation
        self.min = min
        self.max = max
    }

    package mutating func apply(_ requirement: CardValidationRequirement) {
        if case let .cardNumberRange(newMin, newMax) = requirement {
            self.min = newMin
            self.max = newMax
        } else if case let .cardNumberExternalError(binFetchError) = requirement {
            self.externalError = binFetchError
        }
    }

    package func validate(_ value: String) -> CardFormFieldError? {
        let digits = value.filter(\.isNumber)
        if digits.isEmpty { return CardFormFieldError(type: .empty, message: self.validation.errorEmpty) }
        if let externalError { return self.validateExternalError(externalError) }
        if digits.count < self.min { return CardFormFieldError(type: .incomplete, message: self.validation.errorIncomplete) }
        return nil
    }

    package func validateLive(_ value: String) -> String? {
        let digits = value.filter(\.isNumber)
        guard !digits.isEmpty else { return nil }
        if let externalError { return self.validateExternalError(externalError)?.message }
        guard digits.count == self.max else { return nil }
        if !self.luhnCheck(digits) { return self.validation.errorInvalid }
        return nil
    }

    private func validateExternalError(_ error: CardAcceptanceError) -> CardFormFieldError? {
        switch error {
        case let .paymentMethodNotAllowed(message):
            return CardFormFieldError(
                type: .invalid,
                message: message
            )
        case let .paymentTypeNotAllowed(message):
            guard let cardType else {
                return CardFormFieldError(type: .invalid, message: message)
            }
            return CardFormFieldError(
                type: .invalid,
                message: message
            )
        case .paymentMethodNotFound:
            return CardFormFieldError(type: .invalid, message: message)
        }
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

// MARK: - Card Holder Rule

package struct CardHolderRule: CardFormRuleType {
    private let validation: CardFormFields.CardHolderField.Validation
    private let maxLength: Int

    init(validation: CardFormFields.CardHolderField.Validation, maxLength: Int = .max) {
        self.validation = validation
        self.maxLength = maxLength
    }

    package func validate(_ value: String) -> CardFormFieldError? {
        let clearValue = value.trimmingCharacters(in: .whitespaces)
        guard !clearValue.isEmpty else {
            return CardFormFieldError(type: .empty, message: self.validation.errorEmpty)
        }

        let allowed = CharacterSet.letters.union(.whitespaces).union(.decimalDigits)
        if clearValue.unicodeScalars.contains(where: { !allowed.contains($0) }) {
            return CardFormFieldError(type: .invalid, message: self.validation.errorInvalid)
        }

        if clearValue.count < 3 {
            return CardFormFieldError(type: .incomplete, message: self.validation.errorIncomplete)
        }

        if clearValue.count > self.maxLength {
            return CardFormFieldError(type: .invalid, message: self.validation.errorInvalid)
        }

        return nil
    }
}

// MARK: - Expiration Date Rule

package struct ExpirationDateRule: CardFormRuleType {
    private let validation: CardFormFields.ExpirationField.Validation
    private let length: Int

    init(validation: CardFormFields.ExpirationField.Validation, length: Int = 4) {
        self.validation = validation
        self.length = length
    }

    package func validate(_ value: String) -> CardFormFieldError? {
        let digits = value.filter(\.isNumber)
        if digits.isEmpty { return CardFormFieldError(type: .empty, message: self.validation.errorEmpty) }
        guard digits.count == self.length else {
            return CardFormFieldError(type: .incomplete, message: self.validation.errorIncomplete)
        }

        let month = Int(digits.prefix(2)) ?? 0
        let year = (Int(digits.suffix(2)) ?? 0) + 2000

        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())

        let isInvalidMonth = !(1 ... 12).contains(month)
        let isExpired = year < currentYear || (year == currentYear && month < currentMonth)

        guard isInvalidMonth || isExpired else { return nil }
        return CardFormFieldError(type: .invalid, message: self.validation.errorInvalid)
    }
}

// MARK: - Security Code Rule

package struct SecurityCodeRule: CardFormRuleType {
    private let validation: CardFormFields.CVVField.Validation
    private var length: Int

    init(validation: CardFormFields.CVVField.Validation, length: Int = 3) {
        self.validation = validation
        self.length = length
    }

    package mutating func apply(_ requirement: CardValidationRequirement) {
        if case let .securityCodeLength(newLen) = requirement { self.length = newLen }
    }

    package func validate(_ value: String) -> CardFormFieldError? {
        let digits = value.filter(\.isNumber)
        if digits.isEmpty { return CardFormFieldError(type: .empty, message: self.validation.errorEmpty) }
        if digits.count < self.length {
            return CardFormFieldError(type: .incomplete, message: self.validation.errorIncomplete)
        }
        return nil
    }
}

// MARK: - Document Rule

package struct DocumentRule: CardFormRuleType {
    private let validation: CardFormFields.DocumentField.Validation
    private var maxLength = 20
    private var minLength = 1
    private var isNumericType = true

    init(validation: CardFormFields.DocumentField.Validation) {
        self.validation = validation
    }

    package mutating func apply(_ requirement: CardValidationRequirement) {
        switch requirement {
        case let .documentLength(minLen, maxLen):
            self.minLength = minLen
            self.maxLength = maxLen
        case let .documentType(isNumeric):
            self.isNumericType = isNumeric
        default:
            break
        }
    }

    package func validate(_ value: String) -> CardFormFieldError? {
        let chars = self.isNumericType
            ? value.filter(\.isNumber)
            : value.filter { $0.isLetter || $0.isNumber }
        if chars.isEmpty { return CardFormFieldError(type: .empty, message: self.validation.errorEmpty) }
        if !(self.minLength ... self.maxLength).contains(chars.count) {
            return CardFormFieldError(type: .incomplete, message: self.validation.errorIncomplete)
        }
        if self.isNumericType, chars.allSatisfy({ $0 == "0" }) {
            return CardFormFieldError(type: .invalid, message: self.validation.errorInvalid)
        }
        return nil
    }

    package func validateLive(_ value: String) -> String? {
        let chars = self.isNumericType
            ? value.filter(\.isNumber)
            : value.filter { $0.isLetter || $0.isNumber }
        guard chars.count >= self.maxLength else { return nil }
        if self.isNumericType, chars.allSatisfy({ $0 == "0" }) { return self.validation.errorInvalid }
        return nil
    }
}
