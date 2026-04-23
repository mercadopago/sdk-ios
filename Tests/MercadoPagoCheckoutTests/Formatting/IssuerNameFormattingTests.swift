//
//  IssuerNameFormattingTests.swift
//  MercadoPagoSDK
//
//  Created by SDK on 22/04/26.
//

@testable import MercadoPagoCheckout
@testable import MPFoundation
import XCTest

final class IssuerNameFormattingTests: XCTestCase {
    // MARK: - cleanIssuerName

    func test_cleanIssuerName_whenEmpty_shouldReturnEmpty() {
        XCTAssertEqual(MPFormatIssuerName.cleanIssuerName(""), "")
    }

    func test_cleanIssuerName_whenNoMatch_shouldReturnUnchanged() {
        XCTAssertEqual(MPFormatIssuerName.cleanIssuerName("Itau"), "Itau")
    }

    func test_cleanIssuerName_shouldRemoveDebito() {
        XCTAssertEqual(MPFormatIssuerName.cleanIssuerName("Banco de débito"), "Banco de")
    }

    func test_cleanIssuerName_shouldRemoveDebit() {
        XCTAssertEqual(MPFormatIssuerName.cleanIssuerName("debit card"), "card")
    }

    func test_cleanIssuerName_shouldRemoveCredito() {
        XCTAssertEqual(MPFormatIssuerName.cleanIssuerName("Banco de crédito"), "Banco de")
    }

    func test_cleanIssuerName_shouldRemoveCredit() {
        XCTAssertEqual(MPFormatIssuerName.cleanIssuerName("credit Itau"), "Itau")
    }

    func test_cleanIssuerName_shouldBeCaseInsensitive() {
        XCTAssertEqual(MPFormatIssuerName.cleanIssuerName("DEBITO Itau"), "Itau")
        XCTAssertEqual(MPFormatIssuerName.cleanIssuerName("CREDITO Itau"), "Itau")
    }

    func test_cleanIssuerName_shouldCollapseMultipleSpaces() {
        // Arrange — after removing words, double-spaces collapse
        XCTAssertEqual(MPFormatIssuerName.cleanIssuerName("Banco   de    Brasil"), "Banco de Brasil")
    }

    func test_cleanIssuerName_shouldTrimWhitespace() {
        XCTAssertEqual(MPFormatIssuerName.cleanIssuerName("  Itau  "), "Itau")
    }

    func test_cleanIssuerName_shouldStripTrailingDots() {
        XCTAssertEqual(MPFormatIssuerName.cleanIssuerName("Banco S.A..."), "Banco S.A")
    }

    func test_cleanIssuerName_shouldNotStripInternalDots() {
        // Arrange — only trailing dots are stripped
        XCTAssertEqual(MPFormatIssuerName.cleanIssuerName("Banco.com"), "Banco.com")
    }

    func test_cleanIssuerName_whenWordBoundaryFails_shouldKeepWord() {
        // Arrange — "credited" contains "credit" but lacks trailing word boundary
        XCTAssertEqual(MPFormatIssuerName.cleanIssuerName("credited balance"), "credited balance")
    }

    func test_cleanIssuerName_whenOnlyDebitWord_shouldReturnEmpty() {
        XCTAssertEqual(MPFormatIssuerName.cleanIssuerName("débito"), "")
    }

    func test_cleanIssuerName_shouldRemoveBothDebitAndCredit() {
        // Arrange — unlikely input but validates both regexes run
        XCTAssertEqual(MPFormatIssuerName.cleanIssuerName("credit debit Itau"), "Itau")
    }

    // MARK: - applyCapitalizationRules

    func test_applyCapitalizationRules_whenEmpty_shouldReturnEmpty() {
        XCTAssertEqual(MPFormatIssuerName.applyCapitalizationRules(""), "")
    }

    func test_applyCapitalizationRules_whenSingleWord_shouldCapitalizeFirstLetter() {
        XCTAssertEqual(MPFormatIssuerName.applyCapitalizationRules("banco"), "Banco")
    }

    func test_applyCapitalizationRules_whenAllCapsNormalWord_shouldTitleCase() {
        // Arrange — non-special word: "B" + "anco" (lowercased rest)
        XCTAssertEqual(MPFormatIssuerName.applyCapitalizationRules("BANCO"), "Banco")
    }

    func test_applyCapitalizationRules_whenMultipleWords_shouldCapitalizeEach() {
        XCTAssertEqual(MPFormatIssuerName.applyCapitalizationRules("banco do brasil"), "Banco do Brasil")
    }

    func test_applyCapitalizationRules_shouldPreserveSpecialWord_BBVA() {
        XCTAssertEqual(MPFormatIssuerName.applyCapitalizationRules("bbva frances"), "BBVA Frances")
    }

    func test_applyCapitalizationRules_shouldPreserveSpecialWord_Itau_Rappi() {
        XCTAssertEqual(
            MPFormatIssuerName.applyCapitalizationRules("itau/rappi bank"),
            "Itau/Rappi Bank"
        )
    }

    func test_applyCapitalizationRules_shouldPreserveLowercaseConnector() {
        // Arrange — "da", "de", "del", "do", "la", "por" stay lowercased
        XCTAssertEqual(MPFormatIssuerName.applyCapitalizationRules("banco DO brasil"), "Banco do Brasil")
        XCTAssertEqual(MPFormatIssuerName.applyCapitalizationRules("banco DA silva"), "Banco da Silva")
    }

    func test_applyCapitalizationRules_shouldReturnSA_whenInputIsSA() {
        XCTAssertEqual(MPFormatIssuerName.applyCapitalizationRules("s.a"), "S.A.")
        XCTAssertEqual(MPFormatIssuerName.applyCapitalizationRules("S.A."), "S.A.")
        XCTAssertEqual(MPFormatIssuerName.applyCapitalizationRules("sa"), "S.A.")
    }

    func test_applyCapitalizationRules_shouldPreserveMixedCaseSpecial_iO() {
        // Arrange — "iO" is in specialWords with this exact casing
        XCTAssertEqual(MPFormatIssuerName.applyCapitalizationRules("IO bank"), "iO Bank")
    }

    func test_applyCapitalizationRules_shouldPreserveSpecial_oHBang() {
        // Arrange — "oH!" with bang preserved
        XCTAssertEqual(MPFormatIssuerName.applyCapitalizationRules("oh! card"), "oH! Card")
    }

    // MARK: - formattedPaymentType

    func test_formattedPaymentType_whenCreditCard_shouldReturnCreditCardString() {
        XCTAssertEqual(
            MPFormatIssuerName.formattedPaymentType("credit_card"),
            MPStrings.Common.creditCard
        )
    }

    func test_formattedPaymentType_whenDebitCard_shouldReturnDebitCardString() {
        XCTAssertEqual(
            MPFormatIssuerName.formattedPaymentType("debit_card"),
            MPStrings.Common.debitCard
        )
    }

    func test_formattedPaymentType_whenUnknown_shouldReturnEmpty() {
        XCTAssertEqual(MPFormatIssuerName.formattedPaymentType("prepaid_card"), "")
        XCTAssertEqual(MPFormatIssuerName.formattedPaymentType(""), "")
        XCTAssertEqual(MPFormatIssuerName.formattedPaymentType("random"), "")
    }

    // MARK: - specialWords inventory

    func test_specialWords_shouldNotBeEmpty() {
        // Guardrail: if someone accidentally wipes the list, catch it here.
        XCTAssertFalse(MPFormatIssuerName.specialWords.isEmpty)
    }

    func test_specialWords_shouldContainExpectedIssuers() {
        // Smoke test on a known subset — not exhaustive, just a sanity check.
        let expected = ["BBVA", "BCP", "HSBC", "Itau/Rappi", "iO", "oH!"]
        for entry in expected {
            XCTAssertTrue(
                MPFormatIssuerName.specialWords.contains(entry),
                "Expected specialWords to contain '\(entry)'"
            )
        }
    }
}
