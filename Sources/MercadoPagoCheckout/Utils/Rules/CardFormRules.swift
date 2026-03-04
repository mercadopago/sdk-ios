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
    case cardNumberExternalError(BinFetchError?)
    case securityCodeLength(Int)
    case documentLength(min: Int, max: Int)
}

package protocol CardFormRuleType {
    func validate(_ value: String) -> String?
    func validateLive(_ value: String) -> String?
    mutating func apply(_ requirement: CardValidationRequirement)
}

extension CardFormRuleType {
    mutating package func apply(_ requirement: CardValidationRequirement) {}
    package func validateLive(_ value: String) -> String? { nil }
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
    private var min = 13, max = 16
    private var externalError: BinFetchError?
    
    mutating package func apply(_ requirement: CardValidationRequirement) {
        if case let .cardNumberRange(newMin, newMax) = requirement {
            self.min = newMin; self.max = newMax
        } else if case let .cardNumberExternalError(binFetchError) = requirement {
            self.externalError = binFetchError
        }
    }

    package func validate(_ value: String) -> String? {
        let digits = value.filter(\.isNumber)
        if digits.isEmpty { return MPStrings.CardForm.CardNumber.errorEmpty }
        if let externalError { return validateExternalError(externalError) }
        if digits.count < min { return MPStrings.CardForm.CardNumber.errorIncomplete }
        if isAllRepeatedDigits(digits) { return MPStrings.CardForm.CardNumber.errorInvalid }
        if !luhnCheck(digits) { return MPStrings.CardForm.CardNumber.errorInvalid }
        return nil
    }

    package func validateLive(_ value: String) -> String? {
        let digits = value.filter(\.isNumber)
        guard !digits.isEmpty else { return nil }
        if let externalError { return validateExternalError(externalError) }
        guard digits.count >= min else { return nil }
        if isAllRepeatedDigits(digits) { return MPStrings.CardForm.CardNumber.errorInvalid }
        return nil
    }

    private func isAllRepeatedDigits(_ digits: String) -> Bool {
        guard let first = digits.first else { return false }
        return digits.dropFirst().allSatisfy { $0 == first }
    }

    private func validateExternalError(_ error: BinFetchError) -> String? {
        switch error {
        case .paymentMethodNotAllowed(let method):
            return MPStrings.CardForm.CardNumber.errorSellerExclusion(brand: method)
        case .paymentTypeNotAllowed(let cardType):
            guard let cardType else {
                return MPStrings.CardForm.CardNumber.errorInvalid
            }
            return MPStrings.CardForm.CardNumber.errorTypeNotAllowed(cardType: cardTypeDisplayName(cardType))
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
    private var maxLength = 20
    private var minLength = 1
    
    mutating package func apply(_ requirement: CardValidationRequirement) {
        if case let .documentLength(minLen, maxLen) = requirement {
            self.minLength = minLen; self.maxLength = maxLen
        }
    }
    
    package func validate(_ value: String) -> String? {
        let digits = value.filter(\.isNumber)
        if digits.isEmpty { return MPStrings.CardForm.Document.errorEmpty }
        if !(minLength...maxLength).contains(digits.count) { return MPStrings.CardForm.Document.errorIncomplete }
        if digits.allSatisfy({ $0 == "0" }) { return MPStrings.CardForm.Document.errorInvalid }
        return nil
    }
}

// MARK: - Card Holder Rule
package struct CardHolderRule: CardFormRuleType {
    package func validate(_ value: String) -> String? {
        let clearValue = value.trimmingCharacters(in: .whitespaces)
        guard !clearValue.isEmpty else { return MPStrings.CardForm.CardHolder.errorEmpty }
        
        let allowed = CharacterSet.letters.union(.whitespaces).union(.decimalDigits)
        if clearValue.unicodeScalars.contains(where: { !allowed.contains($0) }) {
            return MPStrings.CardForm.CardHolder.errorInvalidFormat
        }
        
        if clearValue.count < 2 {
            return MPStrings.CardForm.CardHolder.errorIncomplete
        }

        return nil
    }
}
