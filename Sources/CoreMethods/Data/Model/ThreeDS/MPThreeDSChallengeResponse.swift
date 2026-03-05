//
//  MPThreeDSResponse.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 04/11/25.
//

struct MPThreeDSChallengeResponse: Codable {
    let status: String
    let data: Challenge?
    
    struct Challenge: Codable {
        var threeDSServerTransID: String
        
        var acsReferenceNumber: String
        
        var acsTransID: String
        
        var acsSignedContent: String
        
        enum CodingKeys: String, CodingKey {
            case threeDSServerTransID = "threeds_server_trans_id"
            case acsReferenceNumber = "acs_reference_number"
            case acsSignedContent = "acs_signed_content"
            case acsTransID = "acs_trans_id"
        }
    }
}
