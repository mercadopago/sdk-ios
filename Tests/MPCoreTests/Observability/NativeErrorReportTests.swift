import XCTest
@testable import MPCore

final class NativeErrorReportTests: XCTestCase {
    func testReportEncodesOnlyAllowlistedFields() throws {
        let pending = PendingNativeError(
            eventID: UUID(uuidString: "3f6fd694-4ba8-4f45-ae7c-871c4698aace")!,
            occurredAt: Date(timeIntervalSince1970: 1_777_000_000),
            environment: .init(sdkVersion: "1.0.0", siteID: "MLB", osVersion: "18.6"),
            error: .init(
                operation: .cardTokenization,
                code: .requestTimeout,
                statusCode: 504,
                requestCorrelationID: "req-5cc7f5",
                serviceTarget: .cardTokens,
                diagnosticCode: .timeout
            )
        )

        let data = try JSONEncoder().encode(NativeErrorReport(pending: pending))
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(Set(json.keys), ["event_id", "occurred_at", "source", "site_id", "error", "device"])
        let source = try XCTUnwrap(json["source"] as? [String: Any])
        XCTAssertEqual(source["sdk_name"] as? String, "openplatform_sdk_ios")
        XCTAssertEqual(source["host_platform"] as? String, "ios")
        XCTAssertEqual(source["sdk_technology"] as? String, "native")
        let error = try XCTUnwrap(json["error"] as? [String: Any])
        XCTAssertEqual(error["category"] as? String, "service")
        XCTAssertEqual(error["critical"] as? Bool, true)

        let encoded = String(decoding: data, as: UTF8.self)
        for prohibited in ["public_key", "order_id", "payment_id", "url", "body", "raw_error", "user_info"] {
            XCTAssertFalse(encoded.contains(prohibited))
        }
    }

    func testInvalidOptionalValuesAreOmittedConstructively() throws {
        let classified = ClassifiedNativeError(
            operation: .installments,
            code: .upstreamRejected,
            statusCode: 999,
            requestCorrelationID: "contains spaces"
        )
        XCTAssertNil(classified.statusCode)
        XCTAssertNil(classified.requestCorrelationID)
    }

    func testOccurredAtPreservesSubsecondPrecision() {
        let pending = PendingNativeError(
            eventID: UUID(uuidString: "3f6fd694-4ba8-4f45-ae7c-871c4698aace")!,
            occurredAt: Date(timeIntervalSince1970: 1_777_000_000.123),
            environment: .init(sdkVersion: "1.0.0", siteID: "MLB", osVersion: "18.6"),
            error: .init(operation: .installments, code: .requestTimeout)
        )

        XCTAssertTrue(NativeErrorReport(pending: pending).occurredAt.hasSuffix(".123Z"))
    }

    func testEnvironmentSnapshotsDoNotChangeRetroactively() {
        let environment = NativeErrorEnvironment(osVersionProvider: { "18.6" })
        environment.configure(sdkVersion: "1.0.0", country: .BRA)
        let first = environment.snapshot()
        environment.configure(sdkVersion: "2.0.0", country: .COL)

        XCTAssertEqual(first, .init(sdkVersion: "1.0.0", siteID: "MLB", osVersion: "18.6"))
        XCTAssertEqual(environment.snapshot(), .init(sdkVersion: "2.0.0", siteID: "MCO", osVersion: "18.6"))
    }
}
