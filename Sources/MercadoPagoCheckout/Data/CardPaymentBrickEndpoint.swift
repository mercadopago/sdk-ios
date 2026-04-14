//
//  CardPaymentBrickEndpoint.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 13/04/26.
//

import Foundation
import MPCore

enum CardPaymentBrickEndpoint {
    case getCard(params: CardPaymentBrickCardParams)
}

extension CardPaymentBrickEndpoint: RequestEndpoint {
    var apiVersion: APIVersion {
        .v1
    }

    var baseURL: String {
        "https://api.mercadopago.com/cho-off"
    }

    var method: HTTPMethod {
        .get
    }

    var path: String {
        switch self {
        case .getCard:
            return "card_payment_brick/card"
        }
    }

    var headers: [String: String] {
        ["Content-Type": "application/json"]
    }

    var urlParams: [String: any CustomStringConvertible] {
        switch self {
        case let .getCard(params):
            var result: [String: any CustomStringConvertible] = [
                "product_id": MPSDKProduct.id,
                "bin": params.bin,
                "checkout_type": params.checkoutType,
                "processing_mode": params.processingMode,
                "locale": params.locale
            ]
            result["amount"] = params.amount.map { "\($0)" }
            if !params.allowCardTypes.isEmpty {
                result["allow_card_types"] = params.allowCardTypes.joined(separator: ",")
            }
            if !params.allowCardBrands.isEmpty {
                result["allow_card_brands"] = params.allowCardBrands.joined(separator: ",")
            }
            return result
        }
    }

    var body: Data? {
        nil
    }
}
