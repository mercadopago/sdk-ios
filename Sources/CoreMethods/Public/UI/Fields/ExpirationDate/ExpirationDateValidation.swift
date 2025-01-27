//
//  ExpirationDateValidation.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 27/01/25.
//

import Foundation
import MPCore

public enum ExpirationDateError {
    case invalidFormat
    case invalidDate
    case invalidLength
    case expired
    case empty
    case none
}

class ExpirationDateValidation: InputValidation {
    var error: ExpirationDateError

    init(error: ExpirationDateError = .empty) {
        self.error = error
    }

    func isValid(_ text: String) -> Bool {
        let components = text.split(separator: "/")
        guard components.count == 2,
              let month = Int(components[0]),
              let yearStr = components.last,
              let year = Int(yearStr) else {
            self.error = .invalidDate
            return false
        }

        let fullYear: Int
        if yearStr.count == 2 {
            fullYear = 2000 + year
        } else {
            fullYear = year
        }

        let currentDate = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: currentDate)
        let currentMonth = calendar.component(.month, from: currentDate)

        if month < 1 || month > 12 {
            self.error = .invalidDate
            return false
        }

        if fullYear < currentYear || (fullYear == currentYear && month < currentMonth) {
            self.error = .expired
            return false
        }

        self.error = .none
        return true
    }
}
