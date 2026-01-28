//
//  CardFormValidate.swift.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 28/01/26.
//
import Foundation

/// Property wrapper that validates a value each time it changes using the provided rules.
@propertyWrapper
package struct CardFormValidate {
    private var value: String
    private var rules: [CardFormRule]
    private var errorMessages: [String] = []

    private var cardNumberRange: (min: Int, max: Int) = (13, 19)
    private var securityCodeLength: Int = 3
    private var documentLength: Int = 19

    package var wrappedValue: String {
        get { value }
        set {
            value = newValue
            validate()
        }
    }

    package var projectedValue: [String] {
        errorMessages
    }

    package init(wrappedValue: String = "", _ rules: CardFormRule...) {
        self.value = wrappedValue
        self.rules = rules
        validate()
    }

    // MARK: - Dynamic configuration helpers

    package mutating func setCardNumberRange(minLength: Int, maxLength: Int) {
        cardNumberRange = (max(1, minLength), max(maxLength, minLength))
        var updated = false
        for index in rules.indices {
            if rules[index].setCardNumberRange(minLength: cardNumberRange.min, maxLength: cardNumberRange.max) {
                updated = true
            }
        }
        guard updated else { return }
        validate()
    }

    package mutating func setSecurityCodeLength(_ length: Int) {
        securityCodeLength = max(1, length)
        var updated = false
        for index in rules.indices {
            if rules[index].setSecurityCodeLength(securityCodeLength) {
                updated = true
            }
        }
        guard updated else { return }
        validate()
    }

    package mutating func setDocumentLength(_ length: Int) {
        documentLength = max(1, length)
        var updated = false
        for index in rules.indices {
            if rules[index].setDocumentLength(documentLength) {
                updated = true
            }
        }
        guard updated else { return }
        validate()
    }

    // MARK: - Validation

    private mutating func validate() {
        errorMessages.removeAll(keepingCapacity: true)

        for index in rules.indices {
            if let message = validateRule(at: index) {
                errorMessages.append(message)
            }
        }
    }

    private mutating func validateRule(at index: Int) -> String? {
        rules[index].validate(value)
    }
}
