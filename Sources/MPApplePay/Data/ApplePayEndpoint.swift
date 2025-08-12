//
//  ApplePayEndpoint.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 23/07/25.
//


import Foundation
#if SWIFT_PACKAGE
    import MPCore
#endif

private enum ConstantsApplePay {
    // Base aligns with cURL host and path prefix; APIVersion appends "/v1/"
    static let baseURL = "https://api.mercadopago.com/platforms/pci/applepay"
}

/// Endpoints
/// Apple Pay tokenization endpoints.
enum ApplePayEndpoint {
    case postToken(body: ApplePayRequestBody)
}

/// Extension to conform to `RequestEndpoint`.
extension ApplePayEndpoint: RequestEndpoint {
    /// API version used by endpoints.
    var apiVersion: APIVersion {
        .v1
    }

    /// Endpoint base URL.
    var baseURL: String {
        return ConstantsApplePay.baseURL
    }

    /// Endpoint HTTP method.
    var method: HTTPMethod {
        switch self {
        case .postToken:
            return .post
        }
    }

    /// Endpoint path.
    var path: String {
        switch self {
        case .postToken:
            return "tokenize"
        }
    }

    /// Request headers.
    var headers: [String: String] {
        return [
            "Content-Type": "application/json",
            "X-Product-id": MPSDKProduct.id,
            "Authorization": "Bearer \(MercadoPagoSDK.shared.getPublicKey())"
        ]
    }

    /// Request URL parameters.
    var urlParams: [String: any CustomStringConvertible] {
        return [:]
    }

    /// Request body data.
    var body: Data? {
        switch self {
        case let .postToken(body):
            let httpBody = try? JSONEncoder().encode(body)
            return httpBody
        }
    }
} 
