//
//  CheckoutError.swift
//  MercadoPagoSDK
//

import Foundation

/// Erro unificado do checkout, retornado via `CheckoutResult.error`.
@frozen
public enum CheckoutError: Error, Equatable, Sendable {
    case serviceError(String)
    case message(String)
}
