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
        case .NIC:
            return "MNI"
        case .PAN:
            return "MPA"
        case .ECU:
            return "MEC"
        case .HND:
            return "MHN"
        case .GTM:
            return "MGT"
        case .SLV:
            return "MSV"
        case .CUB:
            return "MCU"
        case .PRY:
            return "MPY"
        case .DOM:
            return "MRD"
        case .PER:
            return "MPE"
        case .BOL:
            return "MBO"
        case .CRI:
            return "MCR"
        case .VEN:
            return "MLV"
        case .URY:
            return "MLU"
        }
    }
}
