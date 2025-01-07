//
//  BundleProtocol.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 07/01/25.
//

import Foundation

protocol BundleProtocol: Sendable {
    func object(forInfoDictionaryKey key: String) -> Any?
}

extension Bundle: BundleProtocol {}
