import CryptoKit
import Foundation
import XCTest
@testable import MPCore

final class NativeErrorClassifierTests: XCTestCase {
    private let expectedFixtureSHA256 = "9916d9e605a1458bfdcdc7fcd546832754a4f07d8ae7414111b396ad22dec51d"

    func testCanonicalClassificationVectors() throws {
        let data = try fixtureData()
        XCTAssertEqual(SHA256.hash(data: data).hexString, expectedFixtureSHA256)

        let fixture = try JSONDecoder().decode(ClassificationFixture.self, from: data)
        XCTAssertEqual(fixture.schemaVersion, 1)
        XCTAssertEqual(fixture.vectors.count, 16)

        for vector in fixture.vectors {
            let operation = try XCTUnwrap(NativeErrorOperation(rawValue: vector.operation), vector.id)
            let input = NativeErrorInput(
                type: try XCTUnwrap(NativeErrorInputType(rawValue: vector.input.type), vector.id),
                code: vector.input.code.flatMap(NativeErrorEvidenceCode.init(rawValue:)),
                httpStatus: vector.input.httpStatus,
                responseState: vector.input.responseState.flatMap(NativeErrorResponseState.init(rawValue:)),
                requestCorrelationID: vector.input.requestCorrelationID
            )

            let output = NativeErrorClassifier.classify(operation: operation, input: input)

            XCTAssertEqual(output.code.rawValue, vector.expected.code, vector.id)
            XCTAssertEqual(output.code.category.rawValue, vector.expected.category, vector.id)
            XCTAssertEqual(output.code.isCritical, vector.expected.critical, vector.id)
            XCTAssertEqual(output.statusCode, vector.expected.statusCode, vector.id)
            XCTAssertEqual(output.requestCorrelationID, vector.expected.requestCorrelationID, vector.id)
            XCTAssertEqual(output.serviceTarget?.rawValue, vector.expected.serviceTarget, vector.id)
            XCTAssertEqual(output.diagnosticCode?.rawValue, vector.expected.diagnosticCode, vector.id)
        }
    }

    func testClosedVocabulariesRemainCanonical() {
        XCTAssertEqual(Set(NativeErrorInputType.allCases.map(\.rawValue)), [
            "request", "service", "validation", "user_cancellation", "request_cancellation", "unknown"
        ])
        XCTAssertEqual(Set(NativeErrorEvidenceCode.allCases.map(\.rawValue)), [
            "cancelled", "configuration", "integration", "invalid_url", "offline", "dns_failure",
            "connection_lost", "timeout", "empty_body", "exception", "unknown_error",
            "http_unauthorized", "http_forbidden"
        ])
        XCTAssertEqual(Set(NativeErrorResponseState.allCases.map(\.rawValue)), ["empty_body", "decode_failure"])
    }

    func testPrecedenceAndOptionalSanitization() {
        let userCancellation = NativeErrorClassifier.classify(
            operation: .cardFormCancellation,
            input: .init(type: .userCancellation, code: .timeout, httpStatus: 504)
        )
        XCTAssertEqual(userCancellation.code, .userCancelled)

        let integration = NativeErrorClassifier.classify(
            operation: .cardFormInitialization,
            input: .init(type: .validation, code: .integration, responseState: .decodeFailure)
        )
        XCTAssertEqual(integration.code, .sdkConfigurationInvalid)

        let invalidOptionals = NativeErrorClassifier.classify(
            operation: .cardFormSubmission,
            input: .init(type: .unknown, httpStatus: 99, requestCorrelationID: "unsafe correlation")
        )
        XCTAssertNil(invalidOptionals.statusCode)
        XCTAssertNil(invalidOptionals.requestCorrelationID)

        let longestSafeCorrelation = String(repeating: "a", count: 128)
        let validOptionals = NativeErrorClassifier.classify(
            operation: .orderSubmission,
            input: .init(type: .service, httpStatus: 599, requestCorrelationID: longestSafeCorrelation)
        )
        XCTAssertEqual(validOptionals.statusCode, 599)
        XCTAssertEqual(validOptionals.requestCorrelationID, longestSafeCorrelation)
    }

    private func fixtureData() throws -> Data {
        let testsDirectory = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        return try Data(contentsOf: testsDirectory
            .appendingPathComponent("Fixtures/native-error-v2/classification_vectors.json"))
    }
}

private struct ClassificationFixture: Decodable {
    let schemaVersion: Int
    let vectors: [ClassificationVector]

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case vectors
    }
}

private struct ClassificationVector: Decodable {
    struct Input: Decodable {
        let type: String
        let code: String?
        let httpStatus: Int?
        let responseState: String?
        let requestCorrelationID: String?

        enum CodingKeys: String, CodingKey {
            case type, code
            case httpStatus = "http_status"
            case responseState = "response_state"
            case requestCorrelationID = "request_correlation_id"
        }
    }

    struct Expected: Decodable {
        let code: String
        let category: String
        let critical: Bool
        let statusCode: Int?
        let requestCorrelationID: String?
        let serviceTarget: String?
        let diagnosticCode: String?

        enum CodingKeys: String, CodingKey {
            case code, category, critical
            case statusCode = "status_code"
            case requestCorrelationID = "request_correlation_id"
            case serviceTarget = "service_target"
            case diagnosticCode = "diagnostic_code"
        }
    }

    let id: String
    let operation: String
    let input: Input
    let expected: Expected
}

private extension Digest {
    var hexString: String { map { String(format: "%02x", $0) }.joined() }
}
