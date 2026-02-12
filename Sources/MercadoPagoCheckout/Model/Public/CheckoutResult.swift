//
//  CheckoutResult.swift
//  MercadoPagoSDK
//

import Foundation

/// Resultado unificado do checkout, retornado pelo callback `onResult`.
@frozen
public enum CheckoutResult: Equatable, Sendable {
    case success(MPPaymentData)
    case error(CheckoutError)
    case userCancelled
}
