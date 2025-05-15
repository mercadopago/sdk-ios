//
//  SDKError.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 12/02/25.
//

public enum SDKError: String {
    case notInitialized = "MercadoPago SDK not initialized. Call MercadoPagoSDK.shared.initialize() first."
    case alreadyInitialized = "The Mercado pago SDK is already initialized. Please call `MercadoPagoSDK.shared.initialize()` only once."
    case invalidPublicKey = "Invalid Public Key"
    case countryInvalid = "Country should be same of public key created"
}
