//
//  RetryUtils.swift
//  MercadoPagoSDK
//
//  Created by SDK on 09/03/26.
//

import Foundation

/// Executes the given `operation` up to `maxAttempts` times, retrying on eligible errors.
/// Throws the last error if all attempts fail.
///
/// - Parameters:
///   - maxAttempts: Maximum number of attempts. Defaults to 2.
///   - isRetryable: Predicate that decides whether a given error should be retried.
///     `CancellationError` is never retried regardless of this predicate.
///   - operation: The async throwing closure to execute.
func withRetry<T>(
    maxAttempts: Int = 2,
    isRetryable: @Sendable (Error) -> Bool = { _ in true },
    isolation _: isolated (any Actor)? = #isolation,
    operation: () async throws -> T
) async throws -> T {
    var lastError: Error?
    for _ in 0 ..< maxAttempts {
        do {
            return try await operation()
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            if isRetryable(error) {
                lastError = error
            } else {
                throw error
            }
        }
    }
    throw lastError ?? CancellationError()
}
