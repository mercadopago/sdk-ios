//
//  BinFetchError.swift
//  MercadoPagoSDK
//
import MPCore

package enum BinFetchError: Error {
    case acceptance(CardAcceptanceError)
    case network(MercadoPagoCheckoutError)

    var isRetriable: Bool {
        switch self {
        case .acceptance:
            return false
        case let .network(error):
            return error.code == .networkConnectionFailed
                || error.code == .networkTimeout
                || error.code == .serviceError
        }
    }
}
