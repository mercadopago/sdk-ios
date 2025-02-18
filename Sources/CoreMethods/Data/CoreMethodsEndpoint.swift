//
//  CoreMethodsEndpoint.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 18/02/25.
//

import Foundation
import MPCore

private enum Constants {
    static let baseURLToken = "https://api.mercadopago.com"
}

/// Endpoints
enum CoreMethodsEndpoint {
    case postCardToken(body: CardTokenBody)
}

/// Extension to conform to `RequestEndpoint`.
extension CoreMethodsEndpoint: RequestEndpoint {
    /// API version used by endpoints.
    var apiVersion: APIVersion {
        .v1
    }

    /// Endpoint base URL.
    var baseURL: String {
        switch self {
        case .postCardToken:
            return Constants.baseURLToken
        }
    }

    /// Endpoint HTTP method.
    var method: HTTPMethod {
        switch self {
        case .postCardToken:
            return .post
        }
    }

    /// Endpoint path.
    var path: String {
        switch self {
        case .postCardToken:
            return "card_tokens"
        }
    }

    /// Request headers.
    var headers: [String: String] {
        switch self {
        case .postCardToken:
            return [:]
        }
    }

    /// Request URL parameters.
    var urlParams: [String: any CustomStringConvertible] {
        switch self {
        case .postCardToken:
            return [:]
        }
    }

    /// Request body data.
    var body: Data? {
        switch self {
        case let .postCardToken(body):
            return body.toJSONData()
        }
    }
}
