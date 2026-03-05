//
//  MPSellerInfoTests.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 07/01/25.
//

@testable import MPAnalytics
import XCTest

private class BundleMock: @unchecked Sendable, BundleProtocol {
    var mockMinimumVersion: String?

    func object(forInfoDictionaryKey key: String) -> Any? {
        switch key {
        case "MinimumOSVersion":
            return self.mockMinimumVersion
        default:
            return nil
        }
    }
}

private extension MPSellerInfoTests {
    typealias DependencySUT = (
        sut: MPSellerInfo,
        bundleMock: BundleMock
    )

    func makeSUT(minimumVersion: String? = nil, file _: StaticString = #filePath, line _: UInt = #line) -> DependencySUT {
        let bundleMock = BundleMock()
        bundleMock.mockMinimumVersion = minimumVersion
        let sut = MPSellerInfo(bundle: bundleMock)

        return (sut, bundleMock)
    }
}

final class MPSellerInfoTests: XCTestCase {
    func test_getDistribution_whenUsingCocoapods_shouldReturnCocoapods() {
        let sut = self.makeSUT()

        #if COCOAPODS
            XCTAssertEqual(sut.getDistribution(), .cocoapods)
        #endif
    }

    func test_getDistribution_whenUsingSPM_shouldReturnSPM() {
        let (sut, _) = self.makeSUT()

        #if SWIFT_PACKAGE
            XCTAssertEqual(sut.getDistribution(), .spm)
        #endif
    }

    func test_getDistribution_whenUsingXcode_shouldReturnXcode() {
        let sut = self.makeSUT()

        #if !COCOAPODS && !SWIFT_PACKAGE
            XCTAssertEqual(sut.getDistribution(), .xcode)
        #endif
    }

    func test_getTargetMinimum_whenVersionExists_shouldReturnFormattedVersion() {
        let version = "13.0"
        let (sut, _) = self.makeSUT(minimumVersion: version)

        let result = sut.getTargetMinimum()

        XCTAssertEqual(result, "iOS \(version)")
    }
}
