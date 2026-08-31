//
//  ReviewConfirmEndpoint.swift
//  MercadoPagoSDK
//

import Foundation
#if SWIFT_PACKAGE
    import CoreMethods
    import MPCore
#endif

struct ReviewConfirmEndpoint: RequestEndpoint {
    let clientToken: String
    let requestBody: ReviewConfirmRequestBody

    var apiVersion: APIVersion {
        .v1
    }

    var baseURL: String {
        ConstantsEndpoint.baseURLBricks
    }

    var method: HTTPMethod {
        .post
    }

    var path: String {
        "payment_brick/review_confirm"
    }

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
