@testable import CoreMethods
import XCTest

final class PaymentMethodMapperTests: XCTestCase {
    private func makeSUT() -> PaymentMethodMapper {
        PaymentMethodMapper()
    }

    // MARK: - map(responses:)

    func test_map_emptyArray_returnsEmpty() {
        let sut = self.makeSUT()
        XCTAssertTrue(sut.map(responses: []).isEmpty)
    }

    func test_map_multipleResponses_returnsAllMapped() {
        let sut = self.makeSUT()
        let responses = [makeResponse(id: "visa"), makeResponse(id: "master")]
        let result = sut.map(responses: responses)
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].id, "visa")
        XCTAssertEqual(result[1].id, "master")
    }

    // MARK: - map(response:) — root fields

    func test_map_response_mapsRootFieldsCorrectly() {
        let sut = self.makeSUT()
        let result = sut.map(response: makeResponse())

        XCTAssertEqual(result.id, "visa")
        XCTAssertEqual(result.paymentTypeId, "credit_card")
        XCTAssertEqual(result.status, "active")
        XCTAssertEqual(result.processingMode, "aggregator")
        XCTAssertEqual(result.accreditationTime, 0)
        XCTAssertEqual(result.merchantAccountId, "merchant-1")
        XCTAssertEqual(result.siteId, "MLA")
    }

    // MARK: - map(response:) — optional nil fields

    func test_map_response_withNilOptionals_returnsNilDomainFields() {
        let sut = self.makeSUT()
        let result = sut.map(response: makeResponse())

        XCTAssertNil(result.thumbnail)
        XCTAssertNil(result.financialInstitution)
        XCTAssertNil(result.issuer)
        XCTAssertNil(result.card)
        XCTAssertNil(result.bins)
        XCTAssertNil(result.agreements)
        XCTAssertNil(result.payerCosts)
        XCTAssertNil(result.labels)
        XCTAssertNil(result.additionalInfoNeeded)
    }

    // MARK: - map(response:) — financial institutions

    func test_map_response_withFinancialInstitutions_mapsThem() {
        let sut = self.makeSUT()
        let fi = PaymentMethodResponse.FinancialInstitutionResponse(id: "fi-1", description: "Bank A")
        let result = sut.map(response: makeResponse(financialInstitutions: [fi]))

        XCTAssertEqual(result.financialInstitution?.count, 1)
        XCTAssertEqual(result.financialInstitution?[0].id, "fi-1")
        XCTAssertEqual(result.financialInstitution?[0].description, "Bank A")
    }

    // MARK: - map(response:) — issuer

    func test_map_response_withIssuer_mapsIssuerCorrectly() {
        let sut = self.makeSUT()
        let issuer = PaymentMethodResponse.IssuerResponse(id: 123, isDefault: true, thumbnail: "https://thumb.com/issuer.png")
        let result = sut.map(response: makeResponse(issuer: issuer))

        XCTAssertEqual(result.issuer?.id, 123)
        XCTAssertEqual(result.issuer?.isDefault, true)
        XCTAssertEqual(result.issuer?.thumbnail, "https://thumb.com/issuer.png")
    }

    // MARK: - map(response:) — card info

    func test_map_response_withCardInfo_mapsCardInfoCorrectly() {
        let sut = self.makeSUT()
        let result = sut.map(response: makeResponse(card: makeCardInfo()))

        XCTAssertEqual(result.card?.bin, 411_111)
        XCTAssertEqual(result.card?.length.min, 16)
        XCTAssertEqual(result.card?.length.max, 16)
        XCTAssertEqual(result.card?.validation, "standard")
        XCTAssertEqual(result.card?.securityCode.mode, "mandatory")
        XCTAssertEqual(result.card?.securityCode.location, "back")
        XCTAssertEqual(result.card?.securityCode.length, 3)
    }

    // MARK: - map(response:) — payer costs

    func test_map_response_withPayerCosts_mapsThem() {
        let sut = self.makeSUT()
        let cost = PaymentMethodResponse.PayerCostResponse(
            installments: 6,
            installmentRate: 1.5,
            discountRate: 0.0,
            reimbursementRate: 0.0,
            minAllowedAmount: 100.0,
            maxAllowedAmount: 10000.0,
            paymentMethodOptionId: "opt-6",
            labels: ["recommended"]
        )
        let result = sut.map(response: makeResponse(payerCosts: [cost]))

        XCTAssertEqual(result.payerCosts?.count, 1)
        XCTAssertEqual(result.payerCosts?[0].installments, 6)
        XCTAssertEqual(result.payerCosts?[0].installmentRate, 1.5)
        XCTAssertEqual(result.payerCosts?[0].paymentMethodOptionId, "opt-6")
    }

    // MARK: - map(response:) — agreements & time frame

    func test_map_response_withValidDateInTimeFrame_parsesDate() {
        let sut = self.makeSUT()
        let dateString = "2025-01-01T00:00:00.000+0000"
        let agreement = PaymentMethodResponse.AgreementResponse(
            timeFrame: .init(startDate: dateString, endDate: dateString),
            merchantAccounts: [.init(id: "acc-1", paymentMethodOptionId: "opt-1")]
        )
        let result = sut.map(response: makeResponse(agreements: [agreement]))

        XCTAssertEqual(result.agreements?.count, 1)
        XCTAssertEqual(result.agreements?[0].merchantAccounts[0].id, "acc-1")
    }

    func test_map_response_withInvalidDateInTimeFrame_doesNotCrash() {
        let sut = self.makeSUT()
        let agreement = PaymentMethodResponse.AgreementResponse(
            timeFrame: .init(startDate: "invalid-date", endDate: "invalid-date"),
            merchantAccounts: []
        )
        let result = sut.map(response: makeResponse(agreements: [agreement]))
        XCTAssertEqual(result.agreements?.count, 1)
    }
}

// MARK: - Helpers

private extension PaymentMethodMapperTests {
    func makeResponse(
        id: String = "visa",
        financialInstitutions: [PaymentMethodResponse.FinancialInstitutionResponse]? = nil,
        issuer: PaymentMethodResponse.IssuerResponse? = nil,
        card: PaymentMethodResponse.CardInfoResponse? = nil,
        payerCosts: [PaymentMethodResponse.PayerCostResponse]? = nil,
        agreements: [PaymentMethodResponse.AgreementResponse]? = nil
    ) -> PaymentMethodResponse {
        PaymentMethodResponse(
            id: id,
            paymentTypeId: "credit_card",
            status: "active",
            processingMode: "aggregator",
            accreditationTime: 0,
            merchantAccountId: "merchant-1",
            siteId: "MLA",
            thumbnail: nil,
            minAccreditationDays: 0,
            maxAccreditationDays: 0,
            totalFinancialCost: 0.0,
            financialInstitutions: financialInstitutions,
            issuer: issuer,
            card: card,
            bins: nil,
            marketplace: nil,
            deferredCapture: nil,
            agreements: agreements,
            payerCosts: payerCosts,
            labels: nil,
            additionalInfoNeeded: nil
        )
    }

    func makeCardInfo() -> PaymentMethodResponse.CardInfoResponse {
        PaymentMethodResponse.CardInfoResponse(
            bin: 411_111,
            length: .init(min: 16, max: 16),
            validation: "standard",
            securityCode: .init(mode: "mandatory", location: "back", length: 3)
        )
    }
}
