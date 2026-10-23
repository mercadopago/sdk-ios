//
//  PaymentBrickInitializationEndpoint.swift
//  MercadoPagoSDK
//
//  Created by SDK on 22/06/26.
//
import Foundation

#if SWIFT_PACKAGE
    import CoreMethods
    import MPCore
#endif

struct PaymentBrickInitializationEndpoint: RequestEndpoint {
    let orderId: String
    let clientToken: String
    let screens: String?

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
        "payment_brick/initialization"
    }

    var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "X-Public-Key": MercadoPagoSDK.shared.getPublicKey(),
            "Authorization": "Bearer \(self.clientToken)"
        ]
    }

    var urlParams: [String: any CustomStringConvertible] {
        var params: [String: any CustomStringConvertible] = ["order_id": self.orderId]
        if let screens = self.screens, !screens.isEmpty {
            params["screens"] = screens
        }
        return params
    }

    var body: Data? {
        nil
    }
}
