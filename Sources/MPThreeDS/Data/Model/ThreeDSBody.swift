//
//  ThreeDSParams.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 17/07/25.
//

import Foundation

struct ThreeDSBody: Sendable {
    let token: String
    let sdkAppId: String
    let sdkEncData: String
    let sdkEphemPubKey: String
    let sdkMaxTimeout: String
    let sdkReferenceNumber: String
    let sdkTransId: String
    
    /// Initializes the ThreeDSBody with authentication parameters
    /// - Parameters:
    ///   - token: Card token
    ///   - authenticationRequestParameters: 3DS SDK authentication parameters
    ///   - sdkMaxTimeout: SDK maximum timeout (default: "06")
    init(
        token: String, 
        authenticationRequestParameters: ThreeDSAuthRequestParameters,
        sdkMaxTimeout: String = "06"
    ) {
        self.token = token
        self.sdkAppId = authenticationRequestParameters.sdkAppId
        self.sdkEncData = authenticationRequestParameters.deviceData
        self.sdkEphemPubKey = authenticationRequestParameters.sdkEphemeralPublicKey
        self.sdkMaxTimeout = sdkMaxTimeout
        self.sdkReferenceNumber = authenticationRequestParameters.sdkReferenceNumber
        self.sdkTransId = authenticationRequestParameters.sdkTransactionId
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
