//
//  MPThreeDSAuthenticated.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 17/07/25.
//

/// Container for 3D Secure authentication data and transaction management.
///
/// This structure holds both the initial authentication request parameters and
/// optional challenge parameters received from the server. It manages the lifecycle
/// of a 3DS authentication flow from parameter generation to challenge completion.
///
/// ## Usage
/// 
/// 1. Obtain this object from ``MPThreeDS/requestParameters(paymentMethodId:)``
/// 2. Send the `parameters` to your backend for server-side validation  
/// 3. If challenge is required, populate `challengeParameters` with server response
/// 4. Use this object with ``MPThreeDS/startChallenge(from:data:timeOut:)``
public struct MPThreeDSParameters: Sendable {
    /// Initial authentication request parameters to send to your backend.
    ///
    /// These parameters contain device information and SDK data required 
    /// for the 3DS server to determine if a challenge is needed.
    public let authenticationRequestParameters: MPThreeDSAuthRequestParameters
    
    /// Challenge parameters received from your backend when challenge is required.
    ///
    /// Set this property with data received from your backend when the 3DS server
    /// determines that user challenge is necessary. Required for ``MPThreeDS/startChallenge(from:data:timeOut:)``.
    public var challengeParameters: MPThreeDSChallengeParameters?
    
    /// Security warnings generated during 3DS SDK initialization.
    public let warnings: [MPThreeDSWarning]
    
    /// Internal transaction reference for SDK operations.
    let transaction: ThreeDSTransactionProtocol
    
    /// Challenge parameters required to start the 3DS challenge flow.
    public struct MPThreeDSChallengeParameters: Sendable {
        /// 3DS Server Transaction ID assigned by the 3DS Server.
        public var threeDSServerTransID: String
        
        /// ACS Reference Number assigned by the ACS to identify a single transaction.
        public var acsReferenceNumber: String
        
        /// Directory Server Transaction ID assigned by the Directory Server.
        public var dsTransID: String
        
        /// ACS Transaction ID assigned by the ACS.
        public var acsTransID: String
        
        /// ACS Signed Content contains the JWS object created by the ACS.
        public var acsSignedContent: String 
    }
}
