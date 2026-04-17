//
//  MercadoPagoSDKCountry+Locale.swift
//  MercadoPagoSDK-iOS
//

extension MercadoPagoSDK.Country {
    func getLocale() -> String {
        switch self {
        case .BRA:
            return "pt_BR"
        case .ARG:
            return "es_AR"
        case .COL:
            return "es_CO"
        case .MEX:
            return "es_MX"
        case .CHL:
            return "es_CL"
        case .NIC:
            return "es_NI"
        case .PAN:
            return "es_PA"
        case .ECU:
            return "es_EC"
        case .HND:
            return "es_HN"
        case .GTM:
            return "es_GT"
        case .SLV:
            return "es_SV"
        case .CUB:
            return "es_CU"
        case .PRY:
            return "es_PY"
        case .DOM:
            return "es_DO"
        case .PER:
            return "es_PE"
        case .BOL:
            return "es_BO"
        case .CRI:
            return "es_CR"
        case .VEN:
            return "es_VE"
        case .URY:
            return "es_UY"
        }
    }
}
