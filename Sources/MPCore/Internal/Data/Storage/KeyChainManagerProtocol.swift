//
//  KeyChainManagerProtocol.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 12/02/25.
//

package protocol KeyChainManagerProtocol: Sendable {
    func save(_ data: String, account: String) async throws
    func retrieve(account: String) async throws -> String?
    func delete(account: String) async throws
}
