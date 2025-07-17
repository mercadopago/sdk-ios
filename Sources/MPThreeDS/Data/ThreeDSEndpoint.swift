//
//  ThreeDSEndpoint.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 05/06/24.
//

import Foundation
#if SWIFT_PACKAGE
    import MPCore
#endif

private enum ConstantsThreeDS {
    static let baseURL = "https://api.mercadopago.com"
}

/// Endpoints
enum ThreeDSEndpoint {
    case authenticate(body: Data)
}

/// Extension to conform to `RequestEndpoint`.
extension ThreeDSEndpoint: RequestEndpoint {
    /// API version used by endpoints.
    var apiVersion: APIVersion {
        .v1
    }

    /// Endpoint base URL.
    var baseURL: String {
        return ConstantsThreeDS.baseURL
    }

    /// Endpoint HTTP method.
    var method: HTTPMethod {
        switch self {
        case .authenticate:
            return .post
        }
    }

    /// Endpoint path.
    var path: String {
        switch self {
        case .authenticate:
            return "authenticate"
        }
    }

    /// Request headers.
    var headers: [String: String] {
        return [
            "Content-Type": "application/json",
            "X-Product-id": MPSDKProduct.id
        ]
    }

    /// Request URL parameters.
    var urlParams: [String: any CustomStringConvertible] {
        return [:]
    }

    /// Request body data.
    var body: Data? {
        switch self {
        case let .authenticate(body):
            return body
        }
    }
} 
