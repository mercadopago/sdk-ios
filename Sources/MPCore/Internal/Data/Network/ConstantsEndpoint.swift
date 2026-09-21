//
//  ConstantsEndpoint.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 18/03/26.
//

package enum ConstantsEndpoint {
    package static let baseURLToken = "https://api.mercadopago.com"
    package static let baseURLBricks = "https://api.mercadopago.com/cho-off"
    /// Temporary base for the order process v2 contract, while `payment_processed` is only
    /// available on beta. Remove once the production endpoint serves the same contract.
    package static let baseURLBricksBeta = "\(baseURLBricks)/beta"
}
