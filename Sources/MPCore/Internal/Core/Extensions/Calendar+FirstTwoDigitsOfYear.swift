//
//  Calendar+FirstTwoDigitsOfYear.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 18/02/25.
//
import Foundation

package extension Calendar {
    func firstTwoDigitsOfYear() -> String {
        let date = Date()
        let year = self.component(.year, from: date)
        return String(year / 100)
    }

    internal func dateFromExpiration(_ value: String?) -> Date? {
        guard let value, value.count == 5 else { return nil }

        var fixedValue = value
        let firstTwoDigits = Calendar.current.firstTwoDigitsOfYear()
        fixedValue.insert(contentsOf: firstTwoDigits, at: fixedValue.index(fixedValue.startIndex, offsetBy: 3))

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yyyy"
        return dateFormatter.date(from: fixedValue)
    }
}
