import Foundation
import MPCore

public enum CardNumberError {
    case invalidCharacters
    case invalidLuhn
    case invalidLength
    case valid
}

class CardNumberValidation: InputValidation {
    var error: CardNumberError = .valid

    func isValid(_ text: String) -> Bool {
        let cleanNumber = text.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)

        guard cleanNumber.count >= 13, cleanNumber.count <= 19 else {
            self.error = .invalidLength
            return false
        }

        let isValidLuhn = isValidLuhn(cleanNumber)

        if !isValidLuhn {
            self.error = .invalidLuhn
        }

        return isValidLuhn
    }

    private func isValidLuhn(_ number: String) -> Bool {
        guard !number.isEmpty else {
            self.error = .invalidLuhn
            return false
        }
        var sum = 0
        let digitStrings = number.reversed().map { String($0) }

        for tuple in digitStrings.enumerated() {
            if let digit = Int(tuple.element) {
                let odd = tuple.offset % 2 == 1

                switch (odd, digit) {
                case (true, 9):
                    sum += 9
                case (true, 0 ... 8):
                    sum += (digit * 2) % 9
                default:
                    sum += digit
                }
            } else {
                self.error = .invalidLuhn
                return false
            }
        }
        guard sum % 10 == 0 else {
            self.error = .invalidLuhn
            return false
        }

        self.error = .valid
        return true
    }
}

protocol CardNumberTextFieldInterface {}
