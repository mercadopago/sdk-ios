//
//  ThreeDSEndpoint.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 02/01/26.
//

import Foundation
#if SWIFT_PACKAGE
    import MPCore
#endif

/// Endpoints for 3DS operations.
enum ThreeDSEndpoint {
    case postDeviceData(body: MPThreeDSAuthRequestParametersBody)
    case patchChallenge(id: String, body: MPThreeDSUpdateStatusBody)
    case getChallenge(id: String)
}

/// Extension to conform to `RequestEndpoint`.
extension ThreeDSEndpoint: RequestEndpoint {
    /// API version used by endpoints.
    var apiVersion: APIVersion {
        .v1
    }

    /// Endpoint base URL.
    var baseURL: String {
        return ConstantsEndpoint.baseURLBricks + "/beta"
    }

    /// Endpoint HTTP method.
    var method: HTTPMethod {
        switch self {
        case .postDeviceData:
            return .post
        case .getChallenge:
            return .get
        case .patchChallenge:
            return .patch
        }
    }

    /// Endpoint path.
    var path: String {
        switch self {
        case .postDeviceData:
            return "challenges/threeds/device"
        case let .getChallenge(id), let .patchChallenge(id, _):
            return "challenges/threeds/\(id)/authenticate"
        }
    }

    /// Request headers.
    var headers: [String: String] {
        switch self {
        default:
            return [
                "Content-Type": "application/json",
                "X-Public-Key": MercadoPagoSDK.shared.getPublicKey()
            ]
        }
    }

    /// Request URL parameters.
    var urlParams: [String: any CustomStringConvertible] {
        return [:]
    }

    /// Request body data.
    var body: Data? {
        switch self {
        case let .postDeviceData(body):
            return try? JSONEncoder().encode(body)
        case let .patchChallenge(_, body):
            return try? JSONEncoder().encode(body)
        default:
            return nil
        }
    }
}
