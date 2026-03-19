//
//  CardFormInitializationEndpoint.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 18/03/26.
//
import Foundation

#if SWIFT_PACKAGE
    import CoreMethods
    import MPCore
#endif

enum CardFormInitializationEndpoint {
    case getInitialization
}

extension CardFormInitializationEndpoint: RequestEndpoint {
    var apiVersion: APIVersion { .v1 }

    var baseURL: String { ConstantsEndpoint.baseURLBricks }

    var method: HTTPMethod { .get }

    var path: String { "initialization" }

    var headers: [String: String] {
        ["Content-Type": "application/json"]
    }

    var urlParams: [String: any CustomStringConvertible] {
        [
            "product_id": MPSDKProduct.id,
            "locale": MercadoPagoSDK.shared.configuration?.locale ?? Locale.current.identifier
        ]
    }

    var body: Data? { nil }
}
