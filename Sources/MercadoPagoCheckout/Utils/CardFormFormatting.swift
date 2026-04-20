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
package struct CardNumberFormatter: TextFormatting, Equatable {
    private static let defaultMask = "#### #### #### ####"

    private let maskFormat: String
    private let maxLength: Int

    /// Creates a card number formatter for the specified max digit count.
    /// The mask is automatically selected based on `maxLength`.
    /// - Parameter maxLength: Maximum number of digits accepted. Default is 19.
    package init(maxLength: Int = 19, mask: String? = Self.defaultMask) {
        self.maxLength = maxLength
        self.maskFormat = mask ?? Self.defaultMask
    }

    /// Creates a card number formatter using an explicit mask pattern from the BIN response.
    /// - Parameter mask: Mask string where `#` represents a digit and any other character is a separator (e.g. `"#### ###### #####"`).
    package init(mask: String) {
        self.maskFormat = mask
        self.maxLength = mask.filter { $0 == "#" }.count
    }

    package func formatOnChange(_ text: String) -> String {
        let cleanNumber = String(
            text.components(separatedBy: CharacterSet.decimalDigits.inverted).joined().prefix(self.maxLength)
        )
        var result = ""
        var index = cleanNumber.startIndex

        for char in self.maskFormat where index < cleanNumber.endIndex {
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
        self.formatOnChange(text)
    }
}

// MARK: - Expiration Date Formatter

/// A formatter that applies MM/YY mask to expiration dates.
package struct ExpirationDateFormatter: TextFormatting {
    private let maxLength: Int

    package init(maxLength: Int = 4) {
        self.maxLength = maxLength
    }

    package func formatOnChange(_ text: String) -> String {
        let digits = text.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()

        guard !digits.isEmpty else { return "" }

        let limited = String(digits.prefix(self.maxLength))

        if limited.count <= 2 {
            return limited
        }

        let month = String(limited.prefix(2))
        let year = String(limited.dropFirst(2))

        return "\(month)/\(year)"
    }

    package func formatOnCommit(_ text: String) -> String {
        self.formatOnChange(text)
    }
}

// MARK: - Document Formatter

/// A formatter that applies a mask pattern to document numbers.
/// Mask placeholders:
///   - `#` — digit-only position
///   - `A` — alphanumeric position (letters and digits)
///   - Any other character — literal separator
/// When the format is empty, the input is returned unchanged (filtered by type).
package struct DocumentFormatter: TextFormatting {
    private let maskFormat: String
    private let maxLength: Int
    private let isNumericType: Bool

    package init(mask: String = "", maxLength: Int = 20, isNumericType: Bool = true) {
        self.maskFormat = mask
        self.maxLength = maxLength
        self.isNumericType = isNumericType
    }

    package func formatOnChange(_ text: String) -> String {
        let cleaned: String
        if self.isNumericType {
            cleaned = String(text.filter(\.isNumber).prefix(self.maxLength))
        } else {
            cleaned = String(text.filter { $0.isLetter || $0.isNumber }.prefix(self.maxLength))
        }

        guard !self.maskFormat.isEmpty else {
            return cleaned
        }

        var result = ""
        var index = cleaned.startIndex

        for maskChar in self.maskFormat where index < cleaned.endIndex {
            switch maskChar {
            case "#":
                // Digit-only position: skip any non-digit chars in the cleaned input
                while index < cleaned.endIndex, !cleaned[index].isNumber {
                    index = cleaned.index(after: index)
                }
                if index < cleaned.endIndex {
                    result.append(cleaned[index])
                    index = cleaned.index(after: index)
                }
            case "A":
                // Alphanumeric position: accept any letter or digit
                result.append(cleaned[index])
                index = cleaned.index(after: index)
            default:
                result.append(maskChar)
            }
        }

        return result
    }

    package func formatOnCommit(_ text: String) -> String {
        self.formatOnChange(text)
    }
}

// MARK: - Security Code Formatter

/// A formatter that limits CVV input to digits only.
package struct SecurityCodeFormatter: TextFormatting {
    private let maxLength: Int

    /// Creates a security code formatter.
    /// - Parameter maxLength: Maximum digits allowed. Default is 3.
    package init(maxLength: Int = 3) {
        self.maxLength = maxLength
    }

    package func formatOnChange(_ text: String) -> String {
        let digits = text.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return String(digits.prefix(self.maxLength))
    }

    package func formatOnCommit(_ text: String) -> String {
        self.formatOnChange(text)
    }
}
