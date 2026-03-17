//
//  MercadoPagoCheckoutError+Error.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 12/03/26.
//

extension MercadoPagoCheckoutError {
    public static var networkConnectionFailed: Code {
        .networkConnectionFailed
    }

    public static var networkTimeout: Code {
        .networkTimeout
    }

    public static var service: Code {
        .serviceError
    }

    public static var invalidConfiguration: Code {
        .invalidConfiguration
    }

    public static var unknown: Code {
        .unknown
    }
}

extension MercadoPagoCheckoutError: Equatable {
    public static func == (lhs: MercadoPagoCheckoutError, rhs: MercadoPagoCheckoutError) -> Bool {
        lhs.code == rhs.code && lhs.locationDescription == rhs.locationDescription
    }
}
