//
//  MPFooterSubtitleDataTests.swift
//  MercadoPagoSDK
//

@testable import MPComponents
import XCTest

final class MPFooterSubtitleDataTests: XCTestCase {
    func test_initWithText_shouldCreateSecondarySegment() throws {
        let result = MPFooterSubtitleData(text: "3x $ 100")

        let segment = try XCTUnwrap(result.segments.first)
        XCTAssertEqual(segment.text, "3x $ 100")
        XCTAssertEqual(segment.color, .secondary)
    }

    func test_initWithSegments_shouldPreserveIndependentColors() {
        let result = MPFooterSubtitleData(
            segments: [
                .init(text: "3x $ 100", color: .secondary),
                .init(text: "sin interés", color: .feedbackPositive)
            ]
        )

        XCTAssertEqual(result.segments.map(\.color), [.secondary, .feedbackPositive])
    }
}
