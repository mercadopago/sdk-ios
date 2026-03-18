//
//  UserCancelledContext.swift
//  MercadoPagoSDK
//

/// Represents the context provided when a user cancels a checkout flow.
///
/// Conform to this protocol to provide flow-specific cancellation data.
/// For card form cancellations, see ``CardFormUserCancelledContext``.
public protocol UserCancelledContext: Sendable {}
