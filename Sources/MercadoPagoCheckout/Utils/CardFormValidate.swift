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
    package private(set) var errors: [CardFormFieldError] = []
    package private(set) var liveErrorMessages: [String] = []

    package var errorMessages: [String] { self.errors.map(\.message) }

    package var wrappedValue: String {
        get { self.value }
        set { self.value = newValue
            self.validate()
        }
    }

    package var projectedValue: [String] { self.errorMessages }

    package init(wrappedValue: String = "", _ rules: CardFormRuleType...) {
        self.value = wrappedValue
        self.rules = rules
        self.validate()
    }

    package mutating func update(_ requirement: CardValidationRequirement) {
        for index in 0 ..< self.rules.count {
            self.rules[index].apply(requirement)
        }
        self.validate()
    }

    private mutating func validate() {
        self.errors = self.rules.compactMap { $0.validate(self.value) }
        self.liveErrorMessages = self.rules.compactMap { $0.validateLive(self.value) }
    }
}
