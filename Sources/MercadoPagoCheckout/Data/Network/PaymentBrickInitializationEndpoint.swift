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
    let totalAmount: Decimal
    let customerId: String?
    let cardIds: [String]

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
            "X-Public-Key": MercadoPagoSDK.shared.getPublicKey()
        ]
    }

    var urlParams: [String: any CustomStringConvertible] {
        var params: [String: any CustomStringConvertible] = [
            "order_id": self.orderId,
            "total_amount": self.totalAmount
        ]

        if let customerId = self.customerId {
            params["customer_id"] = customerId
        }

        if !self.cardIds.isEmpty {
            params["card_ids"] = self.cardIds.joined(separator: ",")
        }

        return params
    }

    var body: Data? {
        nil
    }
}
