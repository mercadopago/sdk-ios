//
//  ApplePayToken.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 23/07/25.
//

/// Public representation of a token obtained from Apple Pay tokenization.
public struct MPApplePayToken: Codable, Sendable {
    /// Token identifier returned by backend.
    public let id: String
    /// BIN associated with the token, when available.
    public let bin: String

    /// Initializes a token structure.
    /// - Parameters:
    ///   - id: Token identifier.
    ///   - bin: Bank Identification Number when available.
    init(id: String, bin: String) {
        self.id = id
        self.bin = bin
    }
}
