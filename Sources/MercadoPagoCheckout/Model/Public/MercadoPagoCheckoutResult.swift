//
//  MercadoPagoCheckoutResult.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 30/01/26.
//
import Foundation

/// The outcome of a checkout flow.
///
/// The associated payment data type `T` is propagated from the ``CheckoutType`` configured
/// on the builder, so `case success(T)` carries the concrete payment data variant directly —
/// no nested `switch`, no unreachable branches.
public enum MercadoPagoCheckoutResult<T: MPPaymentData.Kind>: Sendable {
    case success(T)
    case error(MercadoPagoCheckoutError)
    case userCancelled(UserCancelledContext)
}
