//
//  CoreMethodsEndpoint.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 18/02/25.
//

import Foundation
#if SWIFT_PACKAGE
    import MPCore
#endif

private enum ConstantsCoreMethods {
    static let baseURLToken = "https://api.mercadopago.com"
    static let baseURLBricks = "https://api.mercadopago.com/cho-off"
}

/// Endpoints
enum CoreMethodsEndpoint {
    case postCardToken(body: CardTokenBody)
    case getIdentificationTypes
    case getInstallments(params: InstallmentsParams)
    case getPaymentMethods(params: PaymentMethodsParams)
    case getIssuers(params: IssuersParams)
}

/// Extension to conform to `RequestEndpoint`.
extension CoreMethodsEndpoint: RequestEndpoint {
    /// API version used by endpoints.
    var apiVersion: APIVersion {
        .v1
    }

    /// Endpoint base URL.
    var baseURL: String {
        switch self {
        case .postCardToken:
            return ConstantsCoreMethods.baseURLToken
        default:
            return ConstantsCoreMethods.baseURLBricks
        }
    }

    /// Endpoint HTTP method.
    var method: HTTPMethod {
        switch self {
        case .postCardToken:
            return .post
        case .getIdentificationTypes, .getInstallments, .getPaymentMethods, .getIssuers:
            return .get
        }
    }

    /// Endpoint path.
    var path: String {
        switch self {
        case .postCardToken:
            return "card_tokens"
        case .getIdentificationTypes:
            return "identification_types"
        case .getInstallments:
            return "installments"
        case .getPaymentMethods:
            return "payment_methods"
        case .getIssuers:
            return "card_issuers"
        }
    }

    /// Request headers.
    var headers: [String: String] {
        switch self {
            
        case .postCardToken:
            return [
                "Content-Type": "application/json",
                "X-Product-id": MPSDKProduct.id
            ]
            
        default:
            return [
                "Content-Type": "application/json"
            ]
        }
    }

    /// Request URL parameters.
    var urlParams: [String: any CustomStringConvertible] {
        switch self {
        case .postCardToken, .getIdentificationTypes:
            return [:]
        case let .getInstallments(params):
            return [
                "bin": params.bin,
                "amount": "\(params.amount)",
                "product_id": MPSDKProduct.id
            ]
        case let .getPaymentMethods(params):
            return [
                "bin": params.bin,
                "product_id": MPSDKProduct.id,
                "processing_mode": params.processingMode
            ]
        case let .getIssuers(params):
            return [
                "bin": params.bin,
                "payment_method_id": params.paymentMethodID,
                "product_id": MPSDKProduct.id
            ]
        }
    }

    /// Request body data.
    var body: Data? {
        switch self {
        case let .postCardToken(body):
            return body.toJSONData()
        default:
            return nil
        }
    }
}
