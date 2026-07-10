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
    let checkoutType: String
    let orderId: String?
    let clientToken: String?

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
        var headers = [
            "Content-Type": "application/json",
            "X-Public-Key": MercadoPagoSDK.shared.getPublicKey()
        ]

        if let clientToken {
            headers["Authorization"] = "Bearer \(clientToken)"
        }

        return headers
    }

    var urlParams: [String: any CustomStringConvertible] {
        var params: [String: any CustomStringConvertible] = [
            "product_id": MPSDKProduct.id,
            "checkout_type": self.checkoutType,
            "amount": 0
        ]

        if let orderId {
            params["order_id"] = orderId
        }

        return params
    }

    var body: Data? {
        nil
    }
}
