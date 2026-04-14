//
//  DeviceSessionEndpoint.swift
//  MercadoPagoSDK
//

import Foundation
#if SWIFT_PACKAGE
    import MPCore
#endif

private enum ConstantsMPDevice {
    static let baseURL = "https://api.mercadopago.com/cho-off"
}

enum DeviceSessionEndpoint {
    case putSession(body: DeviceSessionBody)
}

extension DeviceSessionEndpoint: RequestEndpoint {
    var apiVersion: APIVersion {
        .v1
    }

    var baseURL: String {
        ConstantsMPDevice.baseURL
    }

    var method: HTTPMethod {
        .put
    }

    var path: String {
        "devices/session"
    }

    var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "X-Public-Key": MercadoPagoSDK.shared.getPublicKey()
        ]
    }

    var urlParams: [String: any CustomStringConvertible] {
        [:]
    }

    var body: Data? {
        switch self {
        case let .putSession(body):
            return body.toJSONData()
        }
    }
}
