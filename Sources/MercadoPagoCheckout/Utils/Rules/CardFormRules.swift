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
}

package protocol CardFormRuleType {
    func validate(_ value: String) -> String?
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

    package func validate(_ value: String) -> String? {
        value.trimmingCharacters(in: .whitespaces).isEmpty ? self.msg : nil
    }
}

// MARK: Card Number Rule

package struct CardNumberRule: CardFormRuleType {
    private let validation: CardFormTexts.CardNumberField.Validation
    private var min = 13, max = 19
    private var externalError: CardAcceptanceError?

    init(validation: CardFormTexts.CardNumberField.Validation) {
        self.validation = validation
    }

    package mutating func apply(_ requirement: CardValidationRequirement) {
        if case let .cardNumberRange(newMin, newMax) = requirement {
            self.min = newMin
            self.max = newMax
        } else if case let .cardNumberExternalError(binFetchError) = requirement {
            self.externalError = binFetchError
        }
    }

    package func validate(_ value: String) -> String? {
        let digits = value.filter(\.isNumber)
        if digits.isEmpty { return self.validation.errorEmpty }
        if let externalError { return self.validateExternalError(externalError) }
        if digits.count < self.min { return self.validation.errorIncomplete }
        if !self.luhnCheck(digits) { return self.validation.errorInvalid }
        return nil
    }

    package func validateLive(_ value: String) -> String? {
        let digits = value.filter(\.isNumber)
        guard !digits.isEmpty else { return nil }
        if let externalError { return self.validateExternalError(externalError) }
        guard digits.count >= self.min else { return nil }
        if self.isAllRepeatedDigits(digits) { return self.validation.errorInvalid }
        return nil
    }

    private func isAllRepeatedDigits(_ digits: String) -> Bool {
        guard let first = digits.first else { return false }
        return digits.dropFirst().allSatisfy { $0 == first }
    }

    private func validateExternalError(_ error: CardAcceptanceError) -> String? {
        switch error {
        case let .paymentMethodNotAllowed(method):
            return String(format: self.validation.errorMethodNotAllowed, method)
        case let .paymentTypeNotAllowed(cardType):
            guard let cardType else {
                return self.validation.errorInvalid
            }
            return String(format: self.validation.errorTypeNotAllowed, self.cardTypeDisplayName(cardType))
        }
    }

    private func cardTypeDisplayName(_ cardType: MercadoPagoCheckout.CardType) -> String {
        switch cardType {
        case .credit: return MPStrings.Common.creditCard
        case .debit: return MPStrings.Common.debitCard
        case .prepaid: return MPStrings.Common.prepaidCard
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
    private let validation: CardFormTexts.CardHolderField.Validation

    init(validation: CardFormTexts.CardHolderField.Validation) {
        self.validation = validation
    }

    package func validate(_ value: String) -> String? {
        let clearValue = value.trimmingCharacters(in: .whitespaces)
        guard !clearValue.isEmpty else { return self.validation.errorEmpty }

        let allowed = CharacterSet.letters.union(.whitespaces).union(.decimalDigits)
        if clearValue.unicodeScalars.contains(where: { !allowed.contains($0) }) {
            return self.validation.errorInvalid
        }

        if clearValue.count < 3 {
            return self.validation.errorIncomplete
        }

        return nil
    }
}

// MARK: - Expiration Date Rule

package struct ExpirationDateRule: CardFormRuleType {
    private let validation: CardFormTexts.ExpirationField.Validation

    init(validation: CardFormTexts.ExpirationField.Validation) {
        self.validation = validation
    }

    package func validate(_ value: String) -> String? {
        let digits = value.filter(\.isNumber)
        if digits.isEmpty { return self.validation.errorEmpty }
        guard digits.count == 4 else { return self.validation.errorIncomplete }

        let month = Int(digits.prefix(2)) ?? 0
        let year = (Int(digits.suffix(2)) ?? 0) + 2000

        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())

        let isInvalidMonth = !(1 ... 12).contains(month)
        let isExpired = year < currentYear || (year == currentYear && month < currentMonth)

        return (isInvalidMonth || isExpired) ? self.validation.errorInvalid : nil
    }
}

// MARK: - Security Code Rule

package struct SecurityCodeRule: CardFormRuleType {
    private let validation: CardFormTexts.CVVField.Validation
    private var length = 3

    init(validation: CardFormTexts.CVVField.Validation) {
        self.validation = validation
    }

    package mutating func apply(_ requirement: CardValidationRequirement) {
        if case let .securityCodeLength(newLen) = requirement { self.length = newLen }
    }

    package func validate(_ value: String) -> String? {
        let digits = value.filter(\.isNumber)
        if digits.isEmpty { return self.validation.errorEmpty }
        return digits.count < self.length ? self.validation.errorIncomplete : nil
    }
}

// MARK: - Document Rule

package struct DocumentRule: CardFormRuleType {
    private let validation: CardFormTexts.DocumentField.Validation
    private var maxLength = 20
    private var minLength = 1

    init(validation: CardFormTexts.DocumentField.Validation) {
        self.validation = validation
    }

    package mutating func apply(_ requirement: CardValidationRequirement) {
        if case let .documentLength(minLen, maxLen) = requirement {
            self.minLength = minLen
            self.maxLength = maxLen
        }
    }

    package func validate(_ value: String) -> String? {
        let digits = value.filter(\.isNumber)
        if digits.isEmpty { return self.validation.errorEmpty }
        if !(self.minLength ... self.maxLength).contains(digits.count) { return self.validation.errorIncomplete }
        if digits.allSatisfy({ $0 == "0" }) { return self.validation.errorInvalid }
        return nil
    }
}
