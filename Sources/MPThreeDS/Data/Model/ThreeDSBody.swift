//
//  ThreeDSParams.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 17/07/25.
//

import Foundation
import uSDK

typealias MPThreeDSTransaction = UTransaction

struct ThreeDSBody: Sendable {
    let token: String
    let sdkAppId: String
    let sdkEncData: String
    let sdkEphemPubKey: String
    let sdkMaxTimeout: String
    let sdkReferenceNumber: String
    let sdkTransId: String
    
    /// Inicializa o ThreeDSBody com os parâmetros de autenticação
    /// - Parameters:
    ///   - token: Token do cartão
    ///   - authenticationRequestParameters: Parâmetros de autenticação do 3DS SDK
    init(token: String, authenticationRequestParameters: UAuthenticationRequestParameters) {
        self.token = token
        self.sdkAppId = authenticationRequestParameters.getSDKAppID()
        self.sdkEncData = authenticationRequestParameters.getDeviceData()
        self.sdkEphemPubKey = authenticationRequestParameters.getSDKEphemeralPublicKey()
        self.sdkMaxTimeout = "06"
        self.sdkReferenceNumber = authenticationRequestParameters.getSDKReferenceNumber()
        self.sdkTransId = authenticationRequestParameters.getSDKTransactionID()
    }
}

extension ThreeDSBody {
    /// Converts the `ThreeDSBody` data to JSON format for use in a request body.
    ///
    /// - Returns: A `Data` object representing the post data in JSON format, or `nil` if the conversion fails.
    func toJSONData() -> Data? {
        let jsonObject: [String: Any] = [
            "token": token,
            "sdk_app_id": sdkAppId,
            "sdk_enc_data": sdkEncData,
            "sdk_ephem_pub_key": sdkEphemPubKey,
            "sdk_max_timeout": sdkMaxTimeout,
            "sdk_reference_number": sdkReferenceNumber,
            "sdk_trans_id": sdkTransId
        ]

        return try? JSONSerialization.data(withJSONObject: jsonObject, options: [])
    }
}
