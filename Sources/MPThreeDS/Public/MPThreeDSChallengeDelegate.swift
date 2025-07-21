//
//  MPThreeDSChallengeDelegate.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 21/07/25.
//


import Foundation

@objc public protocol MPThreeDSChallengeDelegate: AnyObject {
    func completed(transactionStatus: String, transactionId: String)
    func cancelled()
    func timedout()
    @objc optional func protocolError(transactionId: String, error: MPThreeDSChallengeError)
    
    @objc optional func runtimeError(error: MPThreeDSChallengeError)
}
