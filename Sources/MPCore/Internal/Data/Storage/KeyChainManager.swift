//
//  KeyChainManager.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 12/02/25.
//

import Foundation
import Security

enum KeychainError: Error {
    case itemNotFound
    case unexpectedData
    case unsupportedFormat
    case invalidParameter
    case operationFailed
}

package protocol HasKeyChain: Sendable {
    /// The key chain interface instance used for save safelty
    var keyChainService: KeyChainManagerProtocol { get }
}

final class KeychainManager: KeyChainManagerProtocol {
    private let serviceIdentifier: String

    init(serviceIdentifier: String = "com.mercadopago.sdk", accessGroup _: String? = nil) {
        self.serviceIdentifier = serviceIdentifier
    }

    private func keychainItem(forQuery query: [String: Any]) -> CFDictionary {
        var item = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: self.serviceIdentifier
        ] as [String: Any]

        item.merge(query) { _, new in new }
        return item as CFDictionary
    }

    func save(_ data: String, account: String) async throws {
        let dataToSave = data.data(using: .utf8)!
        let query: [String: Any] = [
            kSecValueData as String: dataToSave,
            kSecAttrAccount as String: account
        ]

        let item = self.keychainItem(forQuery: query)
        SecItemDelete(item)

        let status = SecItemAdd(item, nil)
        guard status == errSecSuccess else {
            throw KeychainError.operationFailed
        }
    }

    func retrieve(account: String) async throws -> String? {
        let query: [String: Any] = [
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        let item = self.keychainItem(forQuery: query)
        var dataTypeRef: CFTypeRef?
        let status = SecItemCopyMatching(item, &dataTypeRef)

        guard status != errSecItemNotFound else {
            return nil
        }

        guard status == errSecSuccess, let data = dataTypeRef as? Data else {
            if status == errSecSuccess, dataTypeRef is NSString {
                throw KeychainError.unsupportedFormat
            }
            throw KeychainError.operationFailed
        }

        return String(data: data, encoding: .utf8)
    }

    func delete(account: String) async throws {
        let query: [String: Any] = [
            kSecAttrAccount as String: account
        ]

        let item = self.keychainItem(forQuery: query)
        let status = SecItemDelete(item)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.operationFailed
        }
    }
}
