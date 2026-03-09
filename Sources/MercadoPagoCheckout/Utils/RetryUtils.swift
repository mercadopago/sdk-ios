//
//  RetryUtils.swift
//  MercadoPagoSDK
//
//  Created by SDK on 09/03/26.
//

import Foundation

/// Executes the given `operation` up to `maxAttempts` times, retrying on any thrown error.
/// Throws the last error if all attempts fail.
///
/// - Parameters:
///   - maxAttempts: Maximum number of attempts. Defaults to 2.
///   - operation: The async throwing closure to execute.
func withRetry<T>(
    maxAttempts: Int = 2,
    isolation _: isolated (any Actor)? = #isolation,
    operation: () async throws -> T
) async throws -> T {
    var lastError: Error?
    for _ in 0 ..< maxAttempts {
        do {
            return try await operation()
        } catch {
            lastError = error
        }
    }
    throw lastError ?? CancellationError()
}
