//
//  DeviceSessionEndpoint.swift
//  MercadoPagoSDK
//

import Foundation
#if SWIFT_PACKAGE
    import MPCore
#endif

private enum Constants {
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
        Constants.baseURL
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

    var urlRequest: URLRequest? {
        var components = URLComponents(string: baseURL + self.apiVersion.rawValue + self.path)

        let items = self.urlParams.map { key, value in
            URLQueryItem(name: key, value: String(describing: value))
        }

        components?.queryItems = items.isEmpty ? nil : items

        guard let url = components?.url else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = self.method.rawValue
        request.allHTTPHeaderFields = self.headers
        request.httpBody = self.body
        request.cachePolicy = isCacheable ? cachePolicy : .reloadIgnoringLocalCacheData

        return request
    }

    var body: Data? {
        switch self {
        case let .putSession(body):
            return body.toJSONData()
        }
    }
}
