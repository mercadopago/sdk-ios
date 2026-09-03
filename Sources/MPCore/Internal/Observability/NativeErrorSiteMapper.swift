package enum NativeErrorSiteMapper {
    package static func siteID(for country: MercadoPagoSDK.Country) -> String {
        switch country {
        case .ARG: "MLA"
        case .BRA: "MLB"
        case .CHL: "MLC"
        case .COL: "MCO"
        case .MEX: "MLM"
        case .URY: "MLU"
        case .PER: "MPE"
        case .NIC: "MNI"
        case .PAN: "MPA"
        case .ECU: "MEC"
        case .HND: "MHN"
        case .GTM: "MGT"
        case .SLV: "MSV"
        case .CUB: "MCU"
        case .PRY: "MPY"
        case .DOM: "MRD"
        case .BOL: "MBO"
        case .CRI: "MCR"
        case .VEN: "MLV"
        }
    }
}
