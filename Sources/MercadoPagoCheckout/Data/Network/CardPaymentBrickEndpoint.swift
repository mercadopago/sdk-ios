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
        ConstantsEndpoint.baseURLBricks
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
        switch self {
        case let .getCard(params):
            var headers = [
                "Content-Type": "application/json",
                "X-Public-Key": MercadoPagoSDK.shared.getPublicKey()
            ]
            if let clientToken = params.clientToken {
                headers["Authorization"] = "Bearer \(clientToken)"
            }
            return headers
        }
    }

    var urlParams: [String: any CustomStringConvertible] {
        switch self {
        case let .getCard(params):
            var result: [String: any CustomStringConvertible] = [
                "product_id": MPSDKProduct.id,
                "bin": params.bin,
                "checkout_type": params.checkoutType,
                "processing_mode": params.processingMode
            ]

            if let screens = params.screens, !screens.isEmpty {
                result["screens"] = screens
            }
            if !params.excludedCardTypes.isEmpty {
                result["excluded_payment_types"] = params.excludedCardTypes.joined(separator: ",")
            }
            if !params.excludedCardBrands.isEmpty {
                result["excluded_payment_methods"] = params.excludedCardBrands.joined(separator: ",")
            }
            if let amount = params.amount {
                result["amount"] = amount
            }
            if let minInstallments = params.minInstallments {
                result["min_installments"] = minInstallments
            }
            if let maxInstallments = params.maxInstallments {
                result["max_installments"] = maxInstallments
            }
            if let orderId = params.orderId {
                result["order_id"] = orderId
            }
            return result
        }
    }

    var body: Data? {
        nil
    }

    var urlRequest: URLRequest? {
        var components = URLComponents(string: baseURL + self.apiVersion.rawValue + self.path)
        components?.queryItems = self.urlParams.map { key, value in
            URLQueryItem(name: key, value: String(describing: value))
        }

        guard let url = components?.url else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = self.method.rawValue
        request.allHTTPHeaderFields = self.headers
        request.httpBody = self.body
        request.cachePolicy = isCacheable ? cachePolicy : .reloadIgnoringLocalCacheData

        return request
    }
}
