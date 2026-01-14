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
    /// Faile do send device data for mercado pago
    case failedToSendDeviceData
    
    /// Failed to get ACS parameters
    case failedToGetChallengeParameters
    
}
