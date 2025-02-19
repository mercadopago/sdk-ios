//
//  MercadoPagoSDKCountry+SiteID.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 19/02/25.
//

extension MercadoPagoSDK.Country {
    func getSiteId() -> String {
        switch self {
        case .BRA:
            return "MLB"
        case .ARG:
            return "MLA"
        case .COL:
            return "MLC"
        case .MEX:
            return "MLM"
        case .CHL:
            return "MLC"
        }
    }
}
