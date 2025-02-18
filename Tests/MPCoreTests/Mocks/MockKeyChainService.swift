//
//  MockKeyChainService.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 14/02/25.
//

@testable import MPCore
import XCTest

package final class MockKeyChainService: KeyChainManagerProtocol {
    actor Mock {
        enum Messages {
            case callSave
            case callRetrieve
            case delete
        }

        var messages: [Messages] = []

        var savedData: [String: String] = [:]
        var shouldThrowError = false

        func insert(value: String, account: String) {
            self.savedData[account] = value
        }

        func get(account: String) -> String? {
            return self.savedData[account]
        }

        func insertMesseges(_ message: Messages) {
            self.messages.append(message)
        }

        func getMessages() -> [Messages] {
            return self.messages
        }

        func insertShouldThrowError(_ value: Bool) {
            self.shouldThrowError = value
        }
    }

    let mock = Mock()

    package func save(_ value: String, account: String) async throws {
        if await self.mock.shouldThrowError {
            throw NSError(domain: "KeyChainError", code: -1)
        }
        await self.mock.insertMesseges(.callSave)

        await self.mock.insert(value: value, account: account)
    }

    package func retrieve(account: String) async throws -> String? {
        await self.mock.insertMesseges(.callRetrieve)

        if await self.mock.shouldThrowError {
            throw NSError(domain: "KeyChainError", code: -1)
        }

        return await self.mock.get(account: account)
    }

    package func delete(account _: String) async throws {
        await self.mock.insertMesseges(.delete)
    }
}
