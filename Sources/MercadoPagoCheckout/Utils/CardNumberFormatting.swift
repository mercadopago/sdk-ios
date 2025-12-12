//
//  CardNumberFormatting.swift
//  MercadoPagoSDK
//
//  Created by SDK on 12/12/25.
//

import Foundation
import MPComponents

// MARK: - Card Number Formatter

/// A formatter that applies a mask pattern to card numbers.
///
package struct CardNumberFormatter: TextFormatting {
    private let maskFormat: String
    
    /// Creates a card number formatter with the specified mask.
    /// - Parameter mask: The mask pattern where '#' represents a digit. Default is "#### #### #### ####".
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

// MARK: - Card Number Error Type
package enum CardNumberErrorType: Equatable, Sendable {
    /// Field is empty
    case empty
    /// Card number is incomplete
    case incomplete
    /// Card number failed Luhn validation
    case invalid
    /// Card has insufficient credit limit
    case creditLimit
    /// Card has insufficient debit balance
    case debitBalance
    /// Only credit cards are accepted
    case creditOnly
    /// Only debit cards are accepted
    case debitOnly
    /// Custom error from API (use for seller exclusion and other dynamic errors)
    case custom(message: String)
    
    /// Returns the localized error message
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

// MARK: - Card Number Validator

/// A validator that checks if a card number is valid using the Luhn algorithm.
/// Supports additional error states that can be set from API responses.
///
package final class CardNumberValidator: TextValidating, @unchecked Sendable {
    private let minLength: Int
    private let maxLength: Int
    private var externalError: CardNumberErrorType?
    
    /// Creates a card number validator with the specified length constraints.
    /// - Parameters:
    ///   - minLength: Minimum number of digits required. Default is 13.
    ///   - maxLength: Maximum number of digits allowed. Default is 19.
    package init(
        minLength: Int = 13,
        maxLength: Int = 19
    ) {
        self.minLength = minLength
        self.maxLength = maxLength
    }
    
    /// Sets an external error from API response.
    /// - Parameter error: The error type to set, or nil to clear.
    package func setExternalError(_ error: CardNumberErrorType?) {
        self.externalError = error
    }
    
    /// Clears any external error.
    package func clearExternalError() {
        self.externalError = nil
    }
    
    package func validate(_ text: String) -> ValidationResult {
        // Check for external errors first (from API)
        if let externalError {
            return .invalid(message: externalError.message)
        }
        
        let digits = text.filter { $0.isNumber }
        
        // Empty check
        guard !digits.isEmpty else {
            return .invalid(message: CardNumberErrorType.empty.message)
        }
        
        // Length check
        guard digits.count >= minLength else {
            return .invalid(message: CardNumberErrorType.incomplete.message)
        }
        
        guard digits.count <= maxLength else {
            return .invalid(message: CardNumberErrorType.invalid.message)
        }
        
        // Luhn algorithm check
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
