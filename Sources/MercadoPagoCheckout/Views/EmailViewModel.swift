//
//  EmailViewModel.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 02/06/26.
//

import SwiftUI

@MainActor
final class EmailViewModel: ObservableObject {
    struct Configuration {
        let initResult: EmailInitializationOutput
    }

    // MARK: - Published State

    @Published var email = ""

    // MARK: - Dependencies

    private let config: Configuration

    // MARK: - Computed

    /// Text data (title, button, field copy) rendered by the screen.
    var initResult: EmailInitializationOutput {
        self.config.initResult
    }

    /// Whether the typed e-mail is well formed. Drives the footer button state.
    var isEmailValid: Bool {
        Self.isValidEmail(self.email)
    }

    // MARK: - Init

    init(config: Configuration) {
        self.config = config
        self.email = config.initResult.email
    }

    // MARK: - Validation

    /// Errors for the e-mail field, resolved from the received text data.
    ///
    /// - Returns: `nil` while untouched, `[]` when valid, or a single localized
    ///   message describing the failure.
    func emailErrors() -> [String]? {
        if self.email.isEmpty {
            return [self.initResult.errorEmpty]
        }
        if !Self.isValidEmail(self.email) {
            return [self.initResult.errorInvalid]
        }
        return []
    }

    private static func isValidEmail(_ email: String) -> Bool {
        let pattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return email.range(of: pattern, options: .regularExpression) != nil
    }
}
