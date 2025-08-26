//
//  MPThreeDSDirectoryServer.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 21/07/25.
//
import Foundation

/// Directory server identifiers for supported payment methods in 3D Secure authentication.
///
/// Each payment network has its own Directory Server (DS) that coordinates
/// 3D Secure authentication requests. This enum maps payment method identifiers
/// to their corresponding directory server IDs as defined by EMVCo 3DS specifications.
///
/// ## Supported Networks
///
/// - **Visa**: Both credit and debit cards
/// - **Mastercard**: Both credit and debit cards  
/// - **American Express**: Credit cards
///
/// ## Usage
/// ```swift
/// // Automatic mapping from payment method ID
/// let directoryServer = MPThreeDSDirectoryServer(rawValue: "visa")
/// print(directoryServer?.id) // "A000000003"
/// 
/// // Check if payment method supports 3DS
/// if MPThreeDSDirectoryServer(rawValue: paymentMethodId) != nil {
///     // 3DS is supported for this payment method
/// }
/// ```
public enum MPThreeDSDirectoryServer: String {
    /// Visa credit cards.
    case visa
    
    /// Visa debit cards.
    case debvisa
    
    /// Mastercard credit cards.
    case master
    
    /// Mastercard debit cards.
    case debmaster
    
    /// American Express cards.
    case amex

    /// EMVCo-defined Directory Server identifier.
    ///
    /// Returns the official Directory Server ID as specified by EMVCo 3DS standards.
    /// These IDs are used by the 3DS SDK to route authentication requests
    /// to the correct payment network's Directory Server.
    ///
    /// ## Directory Server IDs
    /// - Visa (credit/debit): `A000000003`
    /// - Mastercard (credit/debit): `A000000004` 
    /// - American Express: `A000000025`
    var id: String {
        switch self {
        case .visa, .debvisa: return "A000000003"
        case .master, .debmaster: return "A000000004"
        case .amex: return "A000000025"
        }
    }
}
