//
//  OrderTransactionEndpoint.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 01/06/26.
//

import Foundation
import MPCore

enum OrderTransactionEndpoint {
    case process(orderId: String, params: OrderTransactionParams)
}

extension OrderTransactionEndpoint: RequestEndpoint {
    
    var apiVersion: MPCore.APIVersion {
        .v1
    }
    
    var method: MPCore.HTTPMethod {
        .post
    }
    
    var path: String {
        switch self {
        case .process(let orderId, _):
            "orders/\(orderId)/process"
        }

    }
    
    var baseURL: String {
        ConstantsEndpoint.baseURLBricks
    }
    
    var headers: [String : String] {
        switch self {
        case .process(_ , _):
            return [
                "Content-Type": "application/json",
                "X-Public-Key": MercadoPagoSDK.shared.getPublicKey()
            ]
        }
    }
    
    var urlParams: [String : any CustomStringConvertible] {
        [:]
    }
    
    var body: Data? {
        switch self {
        case .process(_ , let params):
            return try? JSONEncoder().encode(params)
        }
    }
}
