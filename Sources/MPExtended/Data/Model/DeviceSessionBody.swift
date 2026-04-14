//
//  DeviceSessionBody.swift
//  MercadoPagoSDK
//

import Foundation

struct DeviceSessionBody: @unchecked Sendable {
    let siteId: String
    let fingerPrint: [String: Any]?
}

extension DeviceSessionBody {
    func toJSONData() -> Data? {
        var jsonObject: [String: Any] = ["site_id": siteId]
        if let fingerPrint {
            jsonObject["finger_print"] = fingerPrint
        }
        return try? JSONSerialization.data(withJSONObject: jsonObject, options: [])
    }
}
