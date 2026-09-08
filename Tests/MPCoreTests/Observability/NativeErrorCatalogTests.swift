import XCTest
@testable import MPCore

final class NativeErrorCatalogTests: XCTestCase {
    func testCodesDeriveAuthoritativeCategoryAndCriticality() {
        let expected: [(NativeErrorCode, NativeErrorCategory, Bool)] = [
            (.userCancelled, .cancellation, false),
            (.requestCancelled, .cancellation, false),
            (.inputValidationFailed, .inputValidation, false),
            (.connectionUnavailable, .network, false),
            (.requestTimeout, .service, true),
            (.upstreamRejected, .service, true),
            (.responseContractInvalid, .integration, true),
            (.sdkConfigurationInvalid, .integration, true),
            (.operationFailed, .unknown, true)
        ]

        XCTAssertEqual(expected.count, NativeErrorCode.allCases.count)
        for (code, category, critical) in expected {
            XCTAssertEqual(code.category, category)
            XCTAssertEqual(code.isCritical, critical)
        }
    }

    func testOperationModulesAndColombiaSiteAreCorrect() {
        XCTAssertEqual(NativeErrorOperation.identificationTypes.module, .coreMethods)
        XCTAssertEqual(NativeErrorOperation.orderSubmission.module, .checkout)
        XCTAssertEqual(NativeErrorSiteMapper.siteID(for: .COL), "MCO")
        XCTAssertEqual(MercadoPagoSDK.Country.COL.getSiteId(), "MLC")
    }
}
