//
//  defines.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 02/09/25.
//

/// Errors that can occur during the 3D Secure authentication process.
///
/// This enum defines all possible errors that can be returned during the 3DS authentication flow.
public enum MPThreeDSError: Error {
    /// No directory server is available for the specified payment method.
    case noDirectoryServerAvailable
    
    /// Failed to create a 3DS transaction.
    case transaction
    
    /// Failed to obtain authentication request parameters.
    case authenticationRequestParameters
}
