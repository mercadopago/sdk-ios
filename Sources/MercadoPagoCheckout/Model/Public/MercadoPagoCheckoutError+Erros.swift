//
//  MercadoPagoCheckoutError+Erros.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 12/03/26.
//

extension MercadoPagoCheckoutError {
    public static var noConnection: Code {
        .noConnection
    }

    public static var timeout: Code {
        .timeout
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
        lhs.code == rhs.code
    }
}
