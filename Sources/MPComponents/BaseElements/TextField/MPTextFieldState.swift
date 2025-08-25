//
//  MPTextFieldState.swift
//  Public
//
//  Created by SDK on 20/08/25.
//

import Foundation

/// Represents the visual and interaction state for `MPTextField`.
public enum MPTextFieldState: Equatable, Sendable {
    case idle
    case focused
    case error(String)
    case focusError(String)
    case readOnly
    case disabled
    
    /// Extracts an error message if the state represents an error.
    public var errorMessage: String? {
        switch self {
        case let .error(message), let .focusError(message):
            return message
        default:
            return nil
        }
    }
    
    /// Returns whether the field should be treated as read-only.
    public var isReadOnly: Bool {
        if case .readOnly = self { return true }
        return false
    }
    
    /// Returns whether the field should be treated as disabled.
    public var isDisabled: Bool {
        if case .disabled = self { return true }
        return false
    }
    
    /// Returns whether field has Error
    public var hasError: Bool {
        switch self {
        case .error, .focusError:
            return true
        default:
            return false
        }
    }
}


