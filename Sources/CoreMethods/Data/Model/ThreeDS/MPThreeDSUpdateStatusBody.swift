//
//  MPThreeDSUpdateStatus.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 05/01/26.
//

struct MPThreeDSUpdateStatusBody: Sendable, Codable {
    let status: Status
    let errorDetail: ErrorDetail?
    
    enum Status: String, Codable {
        case completed = "COMPLETED"
        case cancelled = "CANCELLED"
        case timeout = "TIMEOUT"
        case error = "ERROR"
    }

    struct ErrorDetail: Codable {
        let type: String
        let code: String
    }

    enum CodingKeys: String, CodingKey {
        case status = "app_id"
        case errorDetail = "error_detail"
    }
}
