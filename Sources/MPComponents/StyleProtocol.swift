//
//  StyleComponent.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 09/06/25.
//
import SwiftUI

public protocol StyleProtocol: DynamicProperty, Sendable {
    associatedtype Configuration
    associatedtype Body: View
    
    @ViewBuilder
    @MainActor
    func makeBody(configuration: Configuration) -> Body
}
