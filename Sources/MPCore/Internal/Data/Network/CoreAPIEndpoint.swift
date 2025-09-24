//
//  CoreAPIEndpoint.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 11/02/25.
//

import Foundation

package enum Constants {
    static let baseURL = "https://api.mercadopago.com/cho-off"
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
        return [
            "product_id": MPSDKProduct.id
        ]
    }

    /// Request body data.
    var body: Data? {
        switch self {
        case .getSiteID:
            return nil
        }
    }

    var isCacheable: Bool {
        switch self {
        case .getSiteID:
            return true
        }
    }

    var cachePolicy: NSURLRequest.CachePolicy {
        switch self {
        case .getSiteID:
            return .returnCacheDataElseLoad
        }
    }

    var cacheTTLSeconds: TimeInterval? {
        return nil
    }
}
