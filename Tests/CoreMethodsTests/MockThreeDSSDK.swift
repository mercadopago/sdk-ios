//
//  MockThreeDSSDK.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 17/11/25.
//

@testable import CoreMethods
import Foundation
import UIKit
import uSDK

/// Mock implementation of ThreeDSTransactionProtocol for testing
package final class MockThreeDSTransaction: ThreeDSTransactionProtocol, @unchecked Sendable {
    package let id: String
    package var authRequestParameters: MPThreeDSAuthRequestParametersBody?
    package var challengeCalled: Bool = false
    package var closeCalled: Bool = false
    package var shouldThrowOnClose: Bool = false
    
    package init(
        id: String = "mock-transaction-id",
        authRequestParameters: MPThreeDSAuthRequestParametersBody? = nil
    ) {
        self.id = id
        self.authRequestParameters = authRequestParameters
    }
    
    package func getAuthenticationRequestParameters() -> MPThreeDSAuthRequestParametersBody? {
        return authRequestParameters
    }
    
    package func doChallenge(
        _ navigationController: UINavigationController,
        challengeParameters: MPThreeDSChallengeParameters,
        challengeStatusReceiver: ThreeDSChallengeStatusReceiver,
        timeOut: Int32
    ) {
        challengeCalled = true
    }
    
    package func close() throws {
        closeCalled = true
        if shouldThrowOnClose {
            throw NSError(domain: "MockThreeDSTransaction", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Mock close error"
            ])
        }
    }
}

/// Mock implementation of ThreeDSSDKProtocol for testing
package final class MockThreeDSSDK: ThreeDSSDKProtocol, @unchecked Sendable {
    package enum Action: Equatable, Sendable {
        case initialize(locale: String)
        case createTransaction(directoryServerId: String, messageVersion: String)
        case getWarnings
    }
    
    // Configuration
    package var initializeError: Error?
    package var transactionToReturn: MockThreeDSTransaction?
    package var warningsToReturn: [MPThreeDSWarning]
    
    // Callbacks
    package var onInitialize: ((String) -> Void)?
    package var onCreateTransaction: ((String, String) -> Void)?
    package var onGetWarnings: (() -> Void)?
    
    package init(
        initializeError: Error? = nil,
        transactionToReturn: MockThreeDSTransaction? = nil,
        warningsToReturn: [MPThreeDSWarning] = []
    ) {
        self.initializeError = initializeError
        self.transactionToReturn = transactionToReturn
        self.warningsToReturn = warningsToReturn
    }
    
    // MARK: - ThreeDSSDKProtocol
    
    package func initialize(
        config: ThreeDSConfig,
        locale: String,
        completion: @escaping (Error?) -> Void
    ) {
        onInitialize?(locale)
        completion(initializeError)
    }
    
    package func createTransaction(
        directoryServerId: String,
        messageVersion: String
    ) -> ThreeDSTransactionProtocol? {
        onCreateTransaction?(directoryServerId, messageVersion)
        return transactionToReturn
    }
    
    package func getWarnings() -> [MPThreeDSWarning] {
        onGetWarnings?()
        return warningsToReturn
    }
}
