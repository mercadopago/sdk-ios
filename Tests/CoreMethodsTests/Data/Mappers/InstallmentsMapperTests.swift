@testable import CoreMethods
import XCTest

final class InstallmentsMapperTests: XCTestCase {
    private func makeSUT() -> InstallmentsMapper {
        InstallmentsMapper()
    }

    // MARK: - map(responses:)

    func test_map_emptyArray_returnsEmpty() {
        let sut = self.makeSUT()
        XCTAssertTrue(sut.map(responses: []).isEmpty)
    }

    func test_map_multipleResponses_returnsAllMapped() {
        let sut = self.makeSUT()
        let responses = [
            makeResponse(paymentMethodId: "visa"),
            makeResponse(paymentMethodId: "master")
        ]
        let result = sut.map(responses: responses)
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].paymentMethodId, "visa")
        XCTAssertEqual(result[1].paymentMethodId, "master")
    }

    // MARK: - map(response:) — root fields

    func test_map_response_mapsRootFieldsCorrectly() {
        let sut = self.makeSUT()
        let result = sut.map(response: makeResponse())

        XCTAssertEqual(result.paymentMethodId, "visa")
        XCTAssertEqual(result.paymentTypeId, "credit_card")
        XCTAssertEqual(result.thumbnail, "https://thumb.com/visa.png")
        XCTAssertEqual(result.processingMode, "aggregator")
        XCTAssertEqual(result.merchantAccountId, "merchant-1")
    }

    // MARK: - map(response:) — issuer

    func test_map_response_mapsIssuerCorrectly() {
        let sut = self.makeSUT()
        let result = sut.map(response: makeResponse())

        XCTAssertEqual(result.issuer.id, "issuer-1")
        XCTAssertEqual(result.issuer.thumbnail, "https://thumb.com/issuer.png")
    }

    // MARK: - map(response:) — payer costs

    func test_map_response_mapsPayerCostsCorrectly() {
        let sut = self.makeSUT()
        let result = sut.map(response: makeResponse())

        XCTAssertEqual(result.payerCosts.count, 1)
        let cost = result.payerCosts[0]
        XCTAssertEqual(cost.installments, 3)
        XCTAssertEqual(cost.installmentAmount, 100.0)
        XCTAssertEqual(cost.installmentRate, 0.5)
        XCTAssertEqual(cost.totalAmount, 300.0)
        XCTAssertEqual(cost.minAllowedAmount, 50.0)
        XCTAssertEqual(cost.maxAllowedAmount, 5000.0)
        XCTAssertEqual(cost.discountRate, 0.0)
        XCTAssertEqual(cost.reimbursementRate, 0.0)
        XCTAssertEqual(cost.labels, ["recommended_installment"])
        XCTAssertEqual(cost.paymentMethodOptionId, "opt-1")
    }

    func test_map_response_payerCostId_equalsInstallments() {
        let sut = self.makeSUT()
        let result = sut.map(response: makeResponse())
        XCTAssertEqual(result.payerCosts[0].id, result.payerCosts[0].installments)
    }

    func test_map_response_withEmptyPayerCosts_returnsEmpty() {
        let sut = self.makeSUT()
        let result = sut.map(response: makeResponse(payerCosts: []))
        XCTAssertTrue(result.payerCosts.isEmpty)
    }

    // MARK: - map(response:) — agreements

    func test_map_response_mapsAgreementsCorrectly() {
        let sut = self.makeSUT()
        let result = sut.map(response: makeResponse())

        XCTAssertEqual(result.agreements.count, 1)
        let agreement = result.agreements[0]
        XCTAssertEqual(agreement.merchantAccounts.count, 1)
        XCTAssertEqual(agreement.merchantAccounts[0].id, "acc-1")
        XCTAssertEqual(agreement.merchantAccounts[0].paymentMethodOptionId, "opt-1")
        XCTAssertEqual(agreement.timeFrame.startDate, "2025-01-01")
        XCTAssertEqual(agreement.timeFrame.endDate, "2025-12-31")
    }

    func test_map_response_withEmptyAgreements_returnsEmpty() {
        let sut = self.makeSUT()
        let result = sut.map(response: makeResponse(agreements: []))
        XCTAssertTrue(result.agreements.isEmpty)
    }
}

// MARK: - Helpers

private extension InstallmentsMapperTests {
    func makeResponse(
        paymentMethodId: String = "visa",
        payerCosts: [InstallmentsResponse.PayerCost]? = nil,
        agreements: [InstallmentsResponse.Agreement]? = nil
    ) -> InstallmentsResponse {
        InstallmentsResponse(
            paymentMethodId: paymentMethodId,
            paymentTypeId: "credit_card",
            thumbnail: "https://thumb.com/visa.png",
            issuer: .init(id: "issuer-1", thumbnail: "https://thumb.com/issuer.png"),
            processingMode: "aggregator",
            merchantAccountId: "merchant-1",
            payerCosts: payerCosts ?? [self.makePayerCost()],
            agreements: agreements ?? [self.makeAgreement()]
        )
    }

    func makePayerCost() -> InstallmentsResponse.PayerCost {
        InstallmentsResponse.PayerCost(
            installments: 3,
            installmentAmount: 100.0,
            installmentRate: 0.5,
            installmentRateCollector: [],
            totalAmount: 300.0,
            minAllowedAmount: 50.0,
            maxAllowedAmount: 5000.0,
            discountRate: 0.0,
            reimbursementRate: 0.0,
            labels: ["recommended_installment"],
            paymentMethodOptionId: "opt-1"
        )
    }

    func makeAgreement() -> InstallmentsResponse.Agreement {
        InstallmentsResponse.Agreement(
            merchantAccounts: [.init(id: "acc-1", paymentMethodOptionId: "opt-1")],
            timeFrame: .init(startDate: "2025-01-01", endDate: "2025-12-31")
        )
    }
}
