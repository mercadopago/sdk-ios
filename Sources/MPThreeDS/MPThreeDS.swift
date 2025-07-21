//
//  MPThreeDS.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 14/07/25.
//
import uSDK
import MPCore

public enum MPThreeDSError: Error {
    case noDirectoryServerAvailable
    case transaction
    case authenticationRequestParameters
    case authentication(message: String)
    case challengeCancelled
    case challengeTimeout
    case protocolError(code: String, message: String)
    case runtimeError(code: String, message: String)
}

public class MPThreeDS: NSObject {

    private let messageVersion = "2.2.0"
    
    private let useCase = ThreeDSUseCase()
    
    public weak var challengeDelegate: MPThreeDSChallengeDelegate?
    
    public init(customization: UUiCustomization = UUiCustomization()) {
        let locale = MercadoPagoSDK.shared.configuration?.locale ?? "en_US"
        UThreeDS2ServiceImpl.shared().u_initialize(UConfigParameters(), locale: locale, uiCustomization: customization) { error in
            if let error = error {
                print("3DS SDK failed to initialize \(error)")
            } else {
                print("3DS SDK successfully initialized")
            }
        }
    }
    
    
    public func requestChallenge(
        cardtoken: String,
        paymentMethodId: String
    ) async throws(MPThreeDSError) -> MPThreeDSAuthenticated {
        /**
         Gets the Directory Server from the selected Payment Method ID
         */
        guard let directoryServer = MPThreeDSDirectoryServer(rawValue: paymentMethodId) else {
            throw .noDirectoryServerAvailable
        }

        /**
         Creates an instance of Transaction. 3DS Requestor App gets the data that is required to perform the transaction.
         */
        guard let transaction = UThreeDS2ServiceImpl.shared().createTransaction(directoryServer.id, messageVersion: messageVersion) else {
            throw .transaction
        }

        /**
         When the 3DS Requestor App calls this method, the 3DS SDK encrypts the
         device information that it collects during initialization and sends this information along with the SDK information to
         the 3DS Requestor App.
         */
        guard let authenticationRequestParameters = transaction.getAuthenticationRequestParameters() else {
            throw .authenticationRequestParameters
        }
        
        do {
            return try await useCase.authenticatedThreeDS(
                transaction: transaction,
                token: cardtoken,
                authenticationParams: authenticationRequestParameters
            )
            
        } catch {
            throw .authentication(message: error.localizedDescription)
        }
    }
    
    @MainActor
    public func startChallenge(
        from navigationController: UINavigationController,
        data: MPThreeDSAuthenticated
    ) async {
        data.transaction.doChallenge(
            navigationController,
            challengeParameters: .init(
                threeDSServerTransactionID: data.parameters.threeDSServerTransID,
                acsTransactionID: data.parameters.acsTransID,
                acsRefNumber: data.parameters.acsReferenceNumber,
                acsSignedContent: data.parameters.acsSignedContent
            ),
            challengeStatusReceiver: self,
            timeOut: 20
        )
    }
}

extension MPThreeDS: UChallengeStatusReceiver {

    public func completed(_ completionEvent: UCompletionEvent) {
        challengeDelegate?.completed(
            transactionStatus: completionEvent.getTransactionStatus(),
            transactionId: completionEvent.getSDKTransactionID()
        )
    }

    public func cancelled() {
        challengeDelegate?.cancelled()
    }

    public func timedout() {
        challengeDelegate?.timedout()
    }

    public func protocolError(_ protocolErrorEvent: UProtocolErrorEvent) {
        
        let errorMessage = protocolErrorEvent.getErrorMessage()
        
        let challengeError = MPThreeDSChallengeError(
            code: errorMessage.getErrorCode(),
            errorType: .protocolError,
            message: errorMessage.getErrorDescription(),
            detail: errorMessage.getErrorDetails()
        )
        
        challengeDelegate?.protocolError?(
            transactionId: protocolErrorEvent.getSDKTransactionID(),
            error: challengeError
        )
    }

    public func runtimeError(_ runtimeErrorEvent: URuntimeErrorEvent) {
        
        let error = MPThreeDSChallengeError(
            code: runtimeErrorEvent.getErrorCode(),
            errorType: .runtimeError,
            message: runtimeErrorEvent.getErrorMessage(),
            detail: nil
        )
        
        challengeDelegate?.runtimeError?(error: error)
    }
}
