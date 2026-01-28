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



