//
//  RetryUtilsTests.swift
//  MercadoPagoSDK
//
//  Created by SDK on 22/04/26.
//

@testable import MercadoPagoCheckout
import XCTest

final class RetryUtilsTests: XCTestCase {
    // MARK: - Success paths

    func test_withRetry_whenOperationSucceedsFirstTime_shouldReturnResult() async throws {
        // Arrange
        let counter = CallCounter()

        // Act
        let result: String = try await withRetry {
            await counter.inc()
            return "ok"
        }

        // Assert
        XCTAssertEqual(result, "ok")
        let count = await counter.count
        XCTAssertEqual(count, 1)
    }

    func test_withRetry_whenFirstAttemptFails_shouldRetryAndSucceed() async throws {
        // Arrange
        let counter = CallCounter()

        // Act -- first attempt throws, second returns "ok"
        let result: String = try await withRetry(maxAttempts: 3) {
            let wasFirst = await counter.count == 0
            await counter.inc()
            if wasFirst { throw TestError(id: 1) }
            return "ok"
        }

        // Assert
        XCTAssertEqual(result, "ok")
        let count = await counter.count
        XCTAssertEqual(count, 2)
    }

    // MARK: - Failure paths

    func test_withRetry_whenAllAttemptsFail_shouldThrowLastError() async {
        // Arrange
        let counter = CallCounter()

        // Act / Assert
        do {
            let _: Int = try await withRetry(maxAttempts: 3) {
                await counter.inc()
                let current = await counter.count
                throw TestError(id: current)
            }
            XCTFail("Expected TestError")
        } catch let error as TestError {
            // Last error (from 3rd attempt) should be propagated
            XCTAssertEqual(error.id, 3)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }

        let count = await counter.count
        XCTAssertEqual(count, 3)
    }

    func test_withRetry_whenMaxAttemptsIsOne_shouldNotRetry() async {
        // Arrange
        let counter = CallCounter()

        // Act / Assert
        do {
            let _: Int = try await withRetry(maxAttempts: 1) {
                await counter.inc()
                throw TestError(id: 99)
            }
            XCTFail("Expected TestError")
        } catch let error as TestError {
            XCTAssertEqual(error.id, 99)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }

        let count = await counter.count
        XCTAssertEqual(count, 1)
    }

    func test_withRetry_whenMaxAttemptsIsZero_shouldNotCallOperation() async {
        // Arrange -- loop body never runs; lastError stays nil; fallback is CancellationError
        let counter = CallCounter()

        // Act / Assert
        do {
            let _: Int = try await withRetry(maxAttempts: 0) {
                await counter.inc()
                return 42
            }
            XCTFail("Expected CancellationError fallback")
        } catch is CancellationError {
            // expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        let count = await counter.count
        XCTAssertEqual(count, 0)
    }

    // MARK: - isRetryable predicate

    func test_withRetry_whenIsRetryableReturnsFalse_shouldThrowImmediately() async {
        // Arrange
        let counter = CallCounter()

        // Act / Assert
        do {
            let _: Int = try await withRetry(
                maxAttempts: 5,
                isRetryable: { _ in false }
            ) {
                await counter.inc()
                throw TestError(id: 1)
            }
            XCTFail("Expected TestError")
        } catch let error as TestError {
            XCTAssertEqual(error.id, 1)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        let count = await counter.count
        XCTAssertEqual(count, 1) // no retry
    }

    func test_withRetry_whenIsRetryableDiscriminatesByErrorKind_shouldStopAtNonRetryable() async {
        // Arrange -- id=1 is retryable, id=2 is not
        let counter = CallCounter()

        // Act / Assert
        do {
            let _: Int = try await withRetry(
                maxAttempts: 5,
                isRetryable: { error in (error as? TestError)?.id == 1 }
            ) {
                let current = await counter.count
                await counter.inc()
                throw TestError(id: current == 0 ? 1 : 2)
            }
            XCTFail("Expected TestError")
        } catch let error as TestError {
            // Second attempt threw id=2 (non-retryable), propagated immediately
            XCTAssertEqual(error.id, 2)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        let count = await counter.count
        XCTAssertEqual(count, 2)
    }

    // MARK: - Cancellation

    func test_withRetry_whenOperationThrowsCancellationError_shouldNotRetry() async {
        // Arrange
        let counter = CallCounter()

        // Act / Assert -- cancellation always short-circuits, never retried
        do {
            let _: Int = try await withRetry(maxAttempts: 5) {
                await counter.inc()
                throw CancellationError()
            }
            XCTFail("Expected CancellationError")
        } catch is CancellationError {
            // expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        let count = await counter.count
        XCTAssertEqual(count, 1)
    }
}

// MARK: - Test Helpers

private actor CallCounter {
    private(set) var count = 0
    func inc() { self.count += 1 }
}

private struct TestError: Error, Equatable {
    let id: Int
}
