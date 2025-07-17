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

public enum MPThreeDSDirectoryServer: String {
    case visa
    case debvisa
    case master
    case debmaster
    case amex

    var id: String {
        switch self {
        case .visa, .debvisa: return "A000000003"
        case .master, .debmaster: return "A000000004"
        case .amex: return "A000000025"
        }
    }
}

public struct MPThreeDSChallengeResult {
    public let transactionStatus: String?
    public let transactionId: String?
}

public class MPThreeDS: NSObject {

    private let messageVersion = "2.2.0"
    
    private let useCase = ThreeDSUseCase()
    
    private var challengeContinuation: CheckedContinuation<MPThreeDSChallengeResult, Error>?
    
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
        from navigationController: UINavigationController,
        cardtoken: String,
        paymentMethodId: String
    ) async throws(MPThreeDSError) -> MPThreeDSChallengeResult {
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
            let authenticated = try await useCase.authenticatedThreeDS(
                transaction: transaction,
                token: cardtoken,
                authenticationParams: authenticationRequestParameters
            )
            
            if authenticated.response == "CHALLENGE"  {
                return try await withCheckedThrowingContinuation { continuation in
                    self.challengeContinuation = continuation
                    
                    transaction.doChallenge(
                        navigationController,
                        challengeParameters: .init(
                            threeDSServerTransactionID: authenticated.threeDSServerTransID,
                            acsTransactionID: authenticated.acsTransID,
                            acsRefNumber: authenticated.acsReferenceNumber,
                            acsSignedContent: authenticated.acsSignedContent
                        ),
                        challengeStatusReceiver: self,
                        timeOut: 20
                    )
                }
            } else {
                return MPThreeDSChallengeResult(
                    transactionStatus: authenticated.response,
                    transactionId: authenticated.threeDSServerTransID
                )
            }
            
        } catch {
            throw .authentication(message: error.localizedDescription)
        }
    }
}

extension MPThreeDS: UChallengeStatusReceiver {

    public func completed(_ completionEvent: UCompletionEvent) {
        let result = MPThreeDSChallengeResult(
            transactionStatus: completionEvent.getTransactionStatus(),
            transactionId: completionEvent.getSDKTransactionID()
        )
        challengeContinuation?.resume(returning: result)
        challengeContinuation = nil
    }

    public func cancelled() {
        challengeContinuation?.resume(throwing: MPThreeDSError.challengeCancelled)
        challengeContinuation = nil
    }

    public func timedout() {
        challengeContinuation?.resume(throwing: MPThreeDSError.challengeTimeout)
        challengeContinuation = nil
    }

    public func protocolError(_ protocolErrorEvent: UProtocolErrorEvent) {
        let errorMessage = protocolErrorEvent.getErrorMessage()
        let error = MPThreeDSError.protocolError(
            code: errorMessage.getErrorCode(),
            message: errorMessage.getErrorDescription()
        )
        challengeContinuation?.resume(throwing: error)
        challengeContinuation = nil
    }

    public func runtimeError(_ runtimeErrorEvent: URuntimeErrorEvent) {
        let error = MPThreeDSError.runtimeError(
            code: runtimeErrorEvent.getErrorCode(),
            message: runtimeErrorEvent.getErrorMessage()
        )
        challengeContinuation?.resume(throwing: error)
        challengeContinuation = nil
    }
}
