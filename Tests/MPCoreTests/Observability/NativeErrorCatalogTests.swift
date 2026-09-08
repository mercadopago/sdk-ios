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

    func testOperationModuleResolutionIsExhaustive() {
        let expected: [(NativeErrorOperation, NativeErrorModule)] = [
            (.identificationTypes, .coreMethods),
            (.installments, .coreMethods),
            (.paymentMethods, .coreMethods),
            (.issuers, .coreMethods),
            (.cardTokenization, .coreMethods),
            (.cardFormInitialization, .checkout),
            (.cardFormSubmission, .checkout),
            (.cardFormCancellation, .checkout),
            (.installmentsCancellation, .checkout),
            (.orderSubmission, .checkout)
        ]

        XCTAssertEqual(expected.map(\.0), NativeErrorOperation.allCases)
        for (operation, module) in expected {
            XCTAssertEqual(operation.module, module)
        }
    }

    func testDefaultModuleDeliveryPolicyUsesDualWriteIndependently() {
        let policy = NativeErrorModuleDeliveryPolicy()
        XCTAssertEqual(policy.mode(for: .coreMethods), .dualWrite)
        XCTAssertEqual(policy.mode(for: .checkout), .dualWrite)
    }

    func testColombiaObservabilitySiteDoesNotChangeProductMapping() {
        XCTAssertEqual(NativeErrorSiteMapper.siteID(for: .COL), "MCO")
        XCTAssertEqual(MercadoPagoSDK.Country.COL.getSiteId(), "MLC")
    }
}
