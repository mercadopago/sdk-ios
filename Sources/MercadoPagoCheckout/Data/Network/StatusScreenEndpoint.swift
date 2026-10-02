//
//  StatusScreenEndpoint.swift
//  MercadoPagoSDK
//

import Foundation
#if SWIFT_PACKAGE
    import CoreMethods
    import MPCore
#endif

struct StatusScreenEndpoint: RequestEndpoint {
    let clientToken: String
    let requestBody: StatusScreenRequestBody

    var apiVersion: APIVersion { .v1 }
    var baseURL: String { ConstantsEndpoint.baseURLBricks }
    var method: HTTPMethod { .post }
    var path: String { "payment_brick/status_screen" }

    var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "X-Public-Key": MercadoPagoSDK.shared.getPublicKey(),
            "Authorization": "Bearer \(self.clientToken)"
        ]
    }

    var urlParams: [String: any CustomStringConvertible] {
        ["product_id": MPSDKProduct.id]
    }

    var body: Data? {
        try? JSONEncoder().encode(self.requestBody)
    }
}
