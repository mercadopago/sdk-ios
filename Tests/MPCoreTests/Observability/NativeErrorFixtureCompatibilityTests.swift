import XCTest
@testable import MPCore

final class NativeErrorFixtureCompatibilityTests: XCTestCase {
    func testIOSCoreMethodsReportMatchesFrozenBackendFixture() throws {
        let report = NativeErrorReport(pending: PendingNativeError(
            eventID: UUID(uuidString: "3f6fd694-4ba8-4f45-ae7c-871c4698aace")!,
            occurredAt: try fixtureDate("2026-08-26T14:00:00.123Z"),
            environment: .init(sdkVersion: "1.0.0", siteID: "MLB", osVersion: "18.6"),
            error: .init(
                operation: .cardTokenization,
                code: .requestTimeout,
                statusCode: 504,
                requestCorrelationID: "req-5cc7f5",
                serviceTarget: .cardTokens,
                diagnosticCode: .timeout
            )
        ))

        let generated = try jsonObject(JSONEncoder().encode(report))
        var fixture = try fixtureObject("valid_ios_core_methods.json")
        var device = try XCTUnwrap(fixture["device"] as? [String: Any])
        XCTAssertEqual(device.removeValue(forKey: "connectivity") as? String, "wifi")
        fixture["device"] = device

        XCTAssertEqual(generated as NSDictionary, fixture as NSDictionary)
    }

    func testCheckoutCancellationMatchesFrozenBackendFixtureAndIsNonCritical() throws {
        let report = NativeErrorReport(pending: PendingNativeError(
            eventID: UUID(uuidString: "ddf87080-b427-47cf-a7d0-b7a568d60ea1")!,
            occurredAt: try fixtureDate("2026-08-26T14:02:00.456Z"),
            environment: .init(sdkVersion: "1.0.0", siteID: "MCO", osVersion: nil),
            error: .init(
                operation: .cardFormCancellation,
                code: .userCancelled,
                diagnosticCode: .cancelled
            )
        ))

        let generated = try jsonObject(JSONEncoder().encode(report))
        let fixture = try fixtureObject("cancellation.json")
        XCTAssertEqual(generated as NSDictionary, fixture as NSDictionary)
        let error = try XCTUnwrap(generated["error"] as? [String: Any])
        XCTAssertEqual(error["critical"] as? Bool, false)
    }

    func testConstructiveEncoderCannotProduceProhibitedFixtureField() throws {
        let prohibited = try fixtureObject("prohibited_field.json")
        let prohibitedError = try XCTUnwrap(prohibited["error"] as? [String: Any])
        XCTAssertNotNil(prohibitedError["raw_error"], "Frozen negative fixture must remain meaningful")

        let report = NativeErrorReport(pending: PendingNativeError(
            eventID: UUID(),
            occurredAt: Date(timeIntervalSince1970: 0),
            environment: .init(sdkVersion: "1.0.0", siteID: "MLB", osVersion: nil),
            error: .init(operation: .cardFormSubmission, code: .operationFailed)
        ))
        let encoded = String(decoding: try JSONEncoder().encode(report), as: UTF8.self)

        for prohibitedKey in [
            "raw_error", "user_info", "public_key", "authorization", "cookie",
            "pan", "bin", "cvv", "payer", "order_id", "payment_id", "url", "body", "stack_trace"
        ] {
            XCTAssertFalse(encoded.contains(prohibitedKey), prohibitedKey)
        }
    }

    private func fixtureObject(_ name: String) throws -> [String: Any] {
        let testsDirectory = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let data = try Data(contentsOf: testsDirectory
            .appendingPathComponent("Fixtures/native-error-v2")
            .appendingPathComponent(name))
        return try jsonObject(data)
    }

    private func jsonObject(_ data: Data) throws -> [String: Any] {
        try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    private func fixtureDate(_ value: String) throws -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return try XCTUnwrap(formatter.date(from: value))
    }
}
