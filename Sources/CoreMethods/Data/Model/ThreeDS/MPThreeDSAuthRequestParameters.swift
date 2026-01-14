//
//  ThreeDSAuthRequestParameters.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 26/08/25.
//

import Foundation

// MARK: - MPThreeDSAuthRequestParametersBody

/// Authentication request parameters required for 3D Secure server communication.
struct MPThreeDSAuthRequestParametersBody: Sendable, Codable, Equatable {
    /// Unique identifier of the 3DS SDK application.
    let appId: String
    /// Integrator SDK version (e.g., Mastercard SDK).
    let integratorSDKVersion: String
    /// Mercado Pago 3DS SDK version.
    let threeDSSDKVersion: String
    /// Unique card token identifier.
    let cardTokenId: String
    /// Device rendering configuration options.
    let deviceRenderOptions: DeviceRenderOptions
    /// Encrypted device data collected by the SDK.
    let encData: String
    /// Ephemeral public key for encryption.
    let ephemPubKey: EphemPubKey
    /// Maximum timeout in minutes for the operation.
    let maxTimeout: Int
    /// 3DS protocol version (e.g., "2.1.0", "2.2.0").
    let protocolVersion: String
    /// SDK reference number for tracking.
    let referenceNumber: String
    /// Transaction identifier for the 3DS flow.
    let transId: String

    enum CodingKeys: String, CodingKey {
        case appId = "app_id"
        case integratorSDKVersion = "integrator_sdk_version"
        case threeDSSDKVersion = "threeds_sdk_version"
        case cardTokenId = "card_token_id"
        case deviceRenderOptions = "device_render_options"
        case encData = "enc_data"
        case ephemPubKey = "ephem_pub_key"
        case maxTimeout = "max_timeout"
        case protocolVersion = "protocol_version"
        case referenceNumber = "reference_number"
        case transId = "trans_id"
    }
}

// MARK: - DeviceRenderOptions

/// Device rendering configuration options for 3DS challenge display.
struct DeviceRenderOptions: Sendable, Codable, Equatable {
    /// SDK interface type (e.g., "Native", "HTML").
    let interface: Int
    /// List of supported UI types for challenge display.
    let uiTypes: [String]

    enum CodingKeys: String, CodingKey {
        case interface
        case uiTypes = "ui_types"
    }
}

// MARK: - EphemPubKey

/// Ephemeral public key for encryption in 3DS flow.
struct EphemPubKey: Sendable, Codable, Equatable {
    /// Elliptic curve algorithm (e.g., "P-256").
    let curve: String
    /// Key type (e.g., "EC" for Elliptic Curve).
    let keyType: String
    /// X coordinate of the elliptic curve point.
    let xEphem: String
    /// Y coordinate of the elliptic curve point.
    let yEphem: String

    enum CodingKeys: String, CodingKey {
        case curve
        case keyType = "key_type"
        case xEphem = "x"
        case yEphem = "y"
    }
}
