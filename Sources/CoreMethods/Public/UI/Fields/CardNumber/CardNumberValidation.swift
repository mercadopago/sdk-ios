import Foundation
import MPCore

public enum CardNumberError {
    case invalidCharacters
    case invalidLuhn
    case invalidLength
    case empty
    case none
}

class CardNumberValidation: InputValidation {
    var error: CardNumberError

    var maxLength: Int

    enum Constant {
        static let minLength = 8
    }

    init(error: CardNumberError = .empty, maxLength: Int) {
        self.error = error
        self.maxLength = maxLength
    }

    func isValid(_ text: String) -> Bool {
        let cleanNumber = text.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)

        guard cleanNumber.count >= Constant.minLength, cleanNumber.count <= self.maxLength else {
            self.error = .invalidLength
            return false
        }

        if self.isValidLuhn(cleanNumber) {
            self.error = .none
            return true
        } else {
            self.error = .invalidLuhn
            return false
        }
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

        return sum % 10 == 0
    }
}
