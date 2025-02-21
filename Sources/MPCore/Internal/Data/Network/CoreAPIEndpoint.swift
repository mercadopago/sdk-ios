//
//  CoreAPIEndpoint.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 11/02/25.
//

import Foundation

private enum Constants {
    static let baseURL = "https://api.mercadopago.com"
}

/// Endpoints
enum CoreAPIEndpoint {
    case getSiteID
}

/// Extension to conform to `RequestEndpoint`.
extension CoreAPIEndpoint: RequestEndpoint {
    /// API version used by endpoints.
    var apiVersion: APIVersion {
        .v1
    }

    /// Endpoint base URL.
    var baseURL: String {
        return Constants.baseURL
    }

    /// Endpoint HTTP method.
    var method: HTTPMethod {
        switch self {
        case .getSiteID:
            return .get
        }
    }

    /// Endpoint path.
    var path: String {
        switch self {
        case .getSiteID:
            return "site_id"
        }
    }

    /// Request headers.
    var headers: [String: String] {
        switch self {
        case .getSiteID:
            return [:]
        }
    }

    /// Request URL parameters.
    var urlParams: [String: any CustomStringConvertible] {
        return [:]
    }

    /// Request body data.
    var body: Data? {
        switch self {
        case .getSiteID:
            return nil
        }
    }
}
