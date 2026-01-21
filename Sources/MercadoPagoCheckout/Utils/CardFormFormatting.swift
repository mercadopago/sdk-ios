//
//  CardFormFormatting.swift
//  MercadoPagoSDK
//
//  Created by SDK on 12/12/25.
//

import Foundation
import MPComponents

// MARK: - Card Number Formatter

/// A formatter that applies a mask pattern to card numbers.
package struct CardNumberFormatter: TextFormatting {
    private let maskFormat: String
    
    /// Creates a card number formatter with the specified mask.
    /// - Parameter mask: The mask pattern where '#' represents a digit.
    package init(mask: String = "#### #### #### ####") {
        self.maskFormat = mask
    }
    
    package func formatOnChange(_ text: String) -> String {
        let cleanNumber = text.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        var result = ""
        var index = cleanNumber.startIndex
        
        for char in maskFormat where index < cleanNumber.endIndex {
            if char == "#" {
                result.append(cleanNumber[index])
                index = cleanNumber.index(after: index)
            } else {
                result.append(char)
            }
        }
        
        return result
    }
    
    package func formatOnCommit(_ text: String) -> String {
        formatOnChange(text)
    }
}

// MARK: - Expiration Date Formatter

/// A formatter that applies MM/YY mask to expiration dates.
package struct ExpirationDateFormatter: TextFormatting {
    
    package init() {}
    
    package func formatOnChange(_ text: String) -> String {
        let digits = text.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        guard !digits.isEmpty else { return "" }
        
        let limited = String(digits.prefix(4))
        
        if limited.count <= 2 {
            return limited
        }
        
        let month = String(limited.prefix(2))
        let year = String(limited.dropFirst(2))
        
        return "\(month)/\(year)"
    }
    
    package func formatOnCommit(_ text: String) -> String {
        formatOnChange(text)
    }
}

// MARK: - Security Code Formatter

/// A formatter that limits CVV input to digits only.
package struct SecurityCodeFormatter: TextFormatting {
    private let maxLength: Int
    
    /// Creates a security code formatter.
    /// - Parameter maxLength: Maximum digits allowed. Default is 4 (for Amex).
    package init(maxLength: Int = 4) {
        self.maxLength = maxLength
    }
    
    package func formatOnChange(_ text: String) -> String {
        let digits = text.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return String(digits.prefix(maxLength))
    }
    
    package func formatOnCommit(_ text: String) -> String {
        formatOnChange(text)
    }
}

// MARK: - Card Number Error Type

/// Represents card number validation errors.
package enum CardNumberErrorType: Equatable, Sendable {
    case empty
    case incomplete
    case invalid
    case creditLimit
    case debitBalance
    case creditOnly
    case debitOnly
    case custom(message: String)
    
    package var message: String {
        switch self {
        case .empty:
            return MPStrings.CardForm.CardNumber.errorEmpty
        case .incomplete:
            return MPStrings.CardForm.CardNumber.errorIncomplete
        case .invalid:
            return MPStrings.CardForm.CardNumber.errorInvalid
        case .creditLimit:
            return MPStrings.CardForm.CardNumber.errorCreditLimit
        case .debitBalance:
            return MPStrings.CardForm.CardNumber.errorDebitBalance
        case .creditOnly:
            return MPStrings.CardForm.CardNumber.errorCreditOnly
        case .debitOnly:
            return MPStrings.CardForm.CardNumber.errorDebitOnly
        case .custom(let message):
            return message
        }
    }
}

// MARK: - Expiration Date Error Type

/// Represents expiration date validation errors.
package enum ExpirationDateErrorType: Equatable, Sendable {
    case empty
    case incomplete
    case invalid
    case expired
    case custom(message: String)
    
    package var message: String {
        switch self {
        case .empty:
            return MPStrings.CardForm.Expiration.errorEmpty
        case .incomplete:
            return MPStrings.CardForm.Expiration.errorIncomplete
        case .invalid, .expired:
            return MPStrings.CardForm.Expiration.errorInvalid
        case .custom(let message):
            return message
        }
    }
}

// MARK: - Security Code Error Type

/// Represents CVV validation errors.
package enum SecurityCodeErrorType: Equatable, Sendable {
    case empty
    case incomplete
    case custom(message: String)
    
    package var message: String {
        switch self {
        case .empty:
            return MPStrings.CardForm.CVV.errorEmpty
        case .incomplete:
            return MPStrings.CardForm.CVV.errorIncomplete
        case .custom(let message):
            return message
        }
    }
}

// MARK: - Card Number Validator

/// Validates card numbers using the Luhn algorithm.
package final class CardNumberValidator: TextValidating, @unchecked Sendable {
    private let minLength: Int
    private let maxLength: Int
    private var externalError: CardNumberErrorType?
    
    package init(minLength: Int = 13, maxLength: Int = 19) {
        self.minLength = minLength
        self.maxLength = maxLength
    }
    
    package func setExternalError(_ error: CardNumberErrorType?) {
        self.externalError = error
    }
    
    package func clearExternalError() {
        self.externalError = nil
    }
    
    package func validate(_ text: String) -> ValidationResult {
        if let externalError {
            return .invalid(message: externalError.message)
        }
        
        let digits = text.filter { $0.isNumber }
        
        guard !digits.isEmpty else {
            return .invalid(message: CardNumberErrorType.empty.message)
        }
        
        guard digits.count >= minLength else {
            return .invalid(message: CardNumberErrorType.incomplete.message)
        }
        
        guard digits.count <= maxLength else {
            return .invalid(message: CardNumberErrorType.invalid.message)
        }
        
        guard isValidLuhn(digits) else {
            return .invalid(message: CardNumberErrorType.invalid.message)
        }
        
        return .valid
    }
    
    private func isValidLuhn(_ number: String) -> Bool {
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

// MARK: - Expiration Date Validator

/// Validates expiration dates (MM/YY format).
package final class ExpirationDateValidator: TextValidating, @unchecked Sendable {
    private var externalError: ExpirationDateErrorType?
    
    package init() {}
    
    package func setExternalError(_ error: ExpirationDateErrorType?) {
        self.externalError = error
    }
    
    package func clearExternalError() {
        self.externalError = nil
    }
    
    package func validate(_ text: String) -> ValidationResult {
        if let externalError {
            return .invalid(message: externalError.message)
        }
        
        let digits = text.filter { $0.isNumber }
        
        guard !digits.isEmpty else {
            return .invalid(message: ExpirationDateErrorType.empty.message)
        }
        
        guard digits.count == 4 else {
            return .invalid(message: ExpirationDateErrorType.incomplete.message)
        }
        
        let monthString = String(digits.prefix(2))
        let yearString = String(digits.suffix(2))
        
        guard let month = Int(monthString), let year = Int(yearString) else {
            return .invalid(message: ExpirationDateErrorType.invalid.message)
        }
        
        // Validate month (1-12)
        guard month >= 1 && month <= 12 else {
            return .invalid(message: ExpirationDateErrorType.invalid.message)
        }
        
        // Validate not expired
        let calendar = Calendar.current
        let currentDate = Date()
        let currentYear = calendar.component(.year, from: currentDate) % 100
        let currentMonth = calendar.component(.month, from: currentDate)
        
        if year < currentYear || (year == currentYear && month < currentMonth) {
            return .invalid(message: ExpirationDateErrorType.invalid.message)
        }
        
        return .valid
    }
}

// MARK: - Security Code Validator

/// Validates CVV/CVC codes.
package final class SecurityCodeValidator: TextValidating, @unchecked Sendable {
    private var requiredLength: Int
    private var externalError: SecurityCodeErrorType?
    
    /// Creates a security code validator.
    /// - Parameter requiredLength: Required number of digits. Default is 3 (use 4 for Amex).
    package init(requiredLength: Int = 3) {
        self.requiredLength = requiredLength
    }
    
    /// Updates the required length (useful when card type changes).
    package func setRequiredLength(_ length: Int) {
        self.requiredLength = length
    }
    
    package func setExternalError(_ error: SecurityCodeErrorType?) {
        self.externalError = error
    }
    
    package func clearExternalError() {
        self.externalError = nil
    }
    
    package func validate(_ text: String) -> ValidationResult {
        if let externalError {
            return .invalid(message: externalError.message)
        }
        
        let digits = text.filter { $0.isNumber }
        
        guard !digits.isEmpty else {
            return .invalid(message: SecurityCodeErrorType.empty.message)
        }
        
        guard digits.count >= requiredLength else {
            return .invalid(message: SecurityCodeErrorType.incomplete.message)
        }
        
        return .valid
    }
}

// MARK: - Card Hollder Validator

package enum CardHolderErrorType: Equatable, Sendable {
    case empty
    case incomplete
    case invalid
    
    package var message: String {
        switch self {
        case .empty:
            return MPStrings.CardForm.CardHolder.errorEmpty
        case .incomplete:
            return MPStrings.CardForm.CardHolder.errorIncomplete
        case .invalid:
            return MPStrings.CardForm.CardHolder.errorInvalidFormat
        }
    }
}

/// Validates Card Holder
package final class CardHolderValidator: TextValidating, @unchecked Sendable {
    
    package init() {
    }
    
    package func validate(_ text: String) -> ValidationResult {
        let digits = text
        
        guard !digits.isEmpty else {
            return .invalid(message: CardHolderErrorType.empty.message)
        }
        
        return .valid
    }
}
