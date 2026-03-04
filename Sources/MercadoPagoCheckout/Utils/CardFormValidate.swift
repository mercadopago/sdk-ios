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
    private var rules: [any CardFormRuleType]
    package private(set) var errorMessages: [String] = []
    package private(set) var liveErrorMessages: [String] = []

    package var wrappedValue: String {
        get { value }
        set { value = newValue; validate() }
    }

    package var projectedValue: [String] { errorMessages }

    package init(wrappedValue: String = "", _ rules: CardFormRuleType...) {
        self.value = wrappedValue
        self.rules = rules
        validate()
    }

    package mutating func update(_ requirement: CardValidationRequirement) {
        for index in 0..<rules.count {
            rules[index].apply(requirement)
        }
        validate()
    }

    private mutating func validate() {
        errorMessages = rules.compactMap { $0.validate(value) }
        liveErrorMessages = rules.compactMap { $0.validateLive(value) }
    }
}
