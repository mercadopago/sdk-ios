//
//  TextValidating.swift
//  Public
//
//  Created by SDK on 20/08/25.
//

import Foundation

/// Result of validating input text.
public enum ValidationResult: Equatable, Sendable {
    case valid
    case invalid(message: String)
}

/// Defines an interface to validate text input.
public protocol TextValidating: Sendable {
    /// Validates the provided text and returns a `ValidationResult`.
    /// - Parameter text: Current text value.
    /// - Returns: A validation result indicating whether the input is valid.
    func validate(_ text: String) -> ValidationResult
}


