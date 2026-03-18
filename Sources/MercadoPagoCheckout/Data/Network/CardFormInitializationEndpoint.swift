//
//  CardFormInitializationEndpoint.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 18/03/26.
//

#if SWIFT_PACKAGE
    import MPCore
#endif

enum CardFormInitializationEndpoint {
    case getInitialization
}

extension CardFormInitializationEndpoint: RequestEndpoint {
    var apiVersion: APIVersion { .v1 }

    var baseURL: String { ConstantsCoreMethods.baseURLBricks }

    var method: HTTPMethod { .get }

    var path: String { "initialization" }

    var headers: [String: String] {
        ["Content-Type": "application/json"]
    }

    var urlParams: [String: any CustomStringConvertible] { [:] }

    var body: Data? { nil }
}
