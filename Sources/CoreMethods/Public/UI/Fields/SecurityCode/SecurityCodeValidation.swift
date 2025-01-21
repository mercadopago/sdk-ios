import Foundation
import MPCore

public enum SecurityCodeError {
    case invalidLength
    case empty
    case none
}

class SecurityCodeValidation: InputValidation {
    var error: SecurityCodeError

    var maxLength: Int

    init(error: SecurityCodeError = .empty, maxLength: Int) {
        self.error = error
        self.maxLength = maxLength
    }

    func isValid(_ text: String) -> Bool {
        let cleanNumber = text.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)

        guard cleanNumber.count >= self.maxLength else {
            self.error = .invalidLength
            return false
        }

        return true
    }
}
