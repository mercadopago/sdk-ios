//
//  EndpointMock.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 29/01/25.
//

import Foundation
import MPCore

struct EndpointMock: RequestEndpoint {
    var method: HTTPMethod = .get
    var path = "test"
    var baseURL = "https://api.test.com"
    var headers: [String: String] = [:]
    var urlParams: [String: CustomStringConvertible] = [:]
    var body: Data? = nil
    var apiVersion: APIVersion = .v1
}
