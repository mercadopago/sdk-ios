//
//  Validation.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 27/01/26.
//

import Foundation
import MPComponents

/// Available rules that can be composed inside the `@CardFormValidate` property wrapper.
@frozen
package enum CardFormRule: Equatable {
    case required(String)
    case cardNumber
    case expirationDate
    case securityCode
    case cardHolder
    case document
}

extension CardFormRule {
    fileprivate enum Kind {
        case required
        case cardNumber
        case expirationDate
        case securityCode
        case cardHolder
        case document
    }

    fileprivate var kind: Kind {
        switch self {
        case .required:
            return .required
        case .cardNumber:
            return .cardNumber
        case .expirationDate:
            return .expirationDate
        case .securityCode:
            return .securityCode
        case .cardHolder:
            return .cardHolder
        case .document:
            return .document
        }
    }
}

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
        guard containsRule(ofKind: .cardNumber) else { return }
        validate()
    }

    package mutating func setSecurityCodeLength(_ length: Int) {
        securityCodeLength = max(1, length)
        guard containsRule(ofKind: .securityCode) else { return }
        validate()
    }

    package mutating func setDocumentLength(_ length: Int) {
        documentLength = max(1, length)
        guard containsRule(ofKind: .document) else { return }
        validate()
    }

    // MARK: - Validation

    private mutating func validate() {
        errorMessages.removeAll()

        for rule in rules {
            if let message = validate(rule) {
                errorMessages.append(message)
            }
        }
    }

    private func validate(_ rule: CardFormRule) -> String? {
        switch rule {
        case .required(let message):
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            print(trimmed)
            return trimmed.isEmpty ? message : nil

        case .cardNumber:
            let validator = CardNumberValidator(minLength: cardNumberRange.min, maxLength: cardNumberRange.max)
            return message(from: validator.validate(value))

        case .expirationDate:
            let validator = ExpirationDateValidator()
            return message(from: validator.validate(value))

        case .securityCode:
            let validator = SecurityCodeValidator(requiredLength: securityCodeLength)
            return message(from: validator.validate(value))

        case .cardHolder:
            let validator = CardHolderValidator()
            return message(from: validator.validate(value))

        case .document:
            let validator = DocumentValidator(requiredLength: documentLength)
            return message(from: validator.validate(value))
        }
    }

    private func message(from result: ValidationResult) -> String? {
        guard case .invalid(let message) = result else { return nil }
        return message
    }

    private func containsRule(ofKind kind: CardFormRule.Kind) -> Bool {
        rules.contains { $0.kind == kind }
    }
}
