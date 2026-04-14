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

struct CardFormInitializationEndpoint: RequestEndpoint {
    let amount: Double?
    let checkoutType: String

    var apiVersion: APIVersion {
        .v1
    }

    var baseURL: String {
        ConstantsEndpoint.baseURLBricks
    }

    var method: HTTPMethod {
        .get
    }

    var path: String {
        "card_payment_brick/initialization"
    }

    var headers: [String: String] {
        ["Content-Type": "application/json"]
    }

    var urlParams: [String: any CustomStringConvertible] {
        [
            "product_id": MPSDKProduct.id,
            "locale": MercadoPagoSDK.shared.configuration?.locale ?? Locale.current.identifier,
            "checkout_type": self.checkoutType,
            "amount": self.amount ?? 0
        ]
    }

    var body: Data? {
        nil
    }
}
