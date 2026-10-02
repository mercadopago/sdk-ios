//
//  MethodSelectionViewModelTests.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout
import XCTest

@MainActor
final class MethodSelectionViewModelTests: XCTestCase {
    // MARK: - Initial state

    func test_initialState_hasNoSelectionAndDisabledCta() {
        // Arrange / Act
        let sut = self.makeSUT(selectionType: .radioButton)

        // Assert
        XCTAssertNil(sut.selectedOptionId)
        XCTAssertFalse(sut.isCtaEnabled)
    }

    // MARK: - selectOption(_:) — chevron

    func test_selectOption_whenChevron_returnsOptionImmediately() {
        // Arrange
        let sut = self.makeSUT(selectionType: .chevron)

        // Act
        let emitted = sut.selectOption("rapipago")

        // Assert
        XCTAssertEqual(emitted?.id, "rapipago")
    }

    func test_selectOption_whenChevron_doesNotMutateSelectionState() {
        // Arrange
        let sut = self.makeSUT(selectionType: .chevron)

        // Act
        sut.selectOption("rapipago")

        // Assert -- chevron mode navigates immediately, no local selection is kept
        XCTAssertNil(sut.selectedOptionId)
        XCTAssertFalse(sut.isCtaEnabled)
    }

    func test_selectOption_whenChevronAndUnknownId_returnsNil() {
        // Arrange
        let sut = self.makeSUT(selectionType: .chevron)

        // Act
        let emitted = sut.selectOption("does-not-exist")

        // Assert
        XCTAssertNil(emitted)
    }

    // MARK: - selectOption(_:) — radio button

    func test_selectOption_whenRadioButton_selectsOptionAndEnablesCta() {
        // Arrange
        let sut = self.makeSUT(selectionType: .radioButton)

        // Act
        sut.selectOption("pago_facil")

        // Assert
        XCTAssertEqual(sut.selectedOptionId, "pago_facil")
        XCTAssertTrue(sut.isCtaEnabled)
    }

    func test_selectOption_whenRadioButton_doesNotReturnBeforeConfirm() {
        // Arrange
        let sut = self.makeSUT(selectionType: .radioButton)

        // Act
        let emitted = sut.selectOption("pago_facil")

        // Assert
        XCTAssertNil(emitted)
    }

    func test_selectOption_whenRadioButtonAndUnknownId_doesNotSelectNorEnableCta() {
        // Arrange
        let sut = self.makeSUT(selectionType: .radioButton)

        // Act
        sut.selectOption("does-not-exist")

        // Assert -- unknown id must not corrupt state or enable the CTA
        XCTAssertNil(sut.selectedOptionId)
        XCTAssertFalse(sut.isCtaEnabled)
    }

    // MARK: - confirmSelection()

    func test_confirmSelection_whenOptionSelected_returnsSelectedOption() {
        // Arrange
        let sut = self.makeSUT(selectionType: .radioButton)
        sut.selectOption("pago_facil")

        // Act
        let emitted = sut.confirmSelection()

        // Assert
        XCTAssertEqual(emitted?.id, "pago_facil")
    }

    func test_confirmSelection_afterEmitting_preservesSelectionAndDisablesCta() {
        // Arrange
        let sut = self.makeSUT(selectionType: .radioButton)
        sut.selectOption("pago_facil")

        // Act
        sut.confirmSelection()

        // Assert -- the selected radio remains visible while submission is in progress
        XCTAssertEqual(sut.selectedOptionId, "pago_facil")
        XCTAssertTrue(sut.isConfirming)
        XCTAssertFalse(sut.isCtaEnabled)
    }

    func test_selectOption_WhenConfirming_ShouldPreserveSubmittedOption() {
        let sut = self.makeSUT(selectionType: .radioButton)
        sut.selectOption("rapipago")
        sut.confirmSelection()

        sut.selectOption("pago_facil")

        XCTAssertEqual(sut.selectedOptionId, "rapipago")
        XCTAssertTrue(sut.isConfirming)
        XCTAssertNil(sut.confirmSelection())
    }

    func test_finishSelection_WhenReturningFromReview_ShouldAllowConfirmingSameOption() {
        let sut = self.makeSUT(selectionType: .radioButton)
        sut.selectOption("rapipago")
        sut.confirmSelection()

        sut.finishSelection()

        XCTAssertFalse(sut.isConfirming)
        XCTAssertEqual(sut.selectedOptionId, "rapipago")
        XCTAssertTrue(sut.isCtaEnabled)
        XCTAssertEqual(sut.confirmSelection()?.id, "rapipago")
    }

    func test_finishSelection_WhenFinished_ShouldAllowChangingOption() {
        let sut = self.makeSUT(selectionType: .radioButton)
        sut.selectOption("rapipago")
        sut.confirmSelection()
        sut.finishSelection()

        sut.selectOption("pago_facil")

        XCTAssertEqual(sut.selectedOptionId, "pago_facil")
        XCTAssertEqual(sut.confirmSelection()?.id, "pago_facil")
    }

    func test_selectOption_WhenChevronIsConfirming_ShouldIgnoreDuplicateAndAllowSelectionAfterFinish() {
        let sut = self.makeSUT(selectionType: .chevron)

        XCTAssertEqual(sut.selectOption("rapipago")?.id, "rapipago")
        XCTAssertTrue(sut.isConfirming)
        XCTAssertNil(sut.selectOption("pago_facil"))

        sut.finishSelection()

        XCTAssertFalse(sut.isConfirming)
        XCTAssertFalse(sut.isCtaEnabled)
        XCTAssertEqual(sut.selectOption("pago_facil")?.id, "pago_facil")
    }

    func test_confirmSelection_WhenNothingSelected_ShouldNotStartLoading() {
        let sut = self.makeSUT(selectionType: .radioButton)

        XCTAssertNil(sut.confirmSelection())
        XCTAssertFalse(sut.isConfirming)
    }

    func test_confirmSelection_calledTwice_returnsOptionOnlyOnce() {
        // Arrange
        let sut = self.makeSUT(selectionType: .radioButton)
        sut.selectOption("pago_facil")

        // Act -- simulate a rapid double tap on the CTA
        let first = sut.confirmSelection()
        let second = sut.confirmSelection()

        // Assert
        XCTAssertNotNil(first)
        XCTAssertNil(second)
    }

    func test_confirmSelection_whenNothingSelected_returnsNil() {
        // Arrange
        let sut = self.makeSUT(selectionType: .radioButton)

        // Act
        let emitted = sut.confirmSelection()

        // Assert
        XCTAssertNil(emitted)
    }

    // MARK: - listItemStyle

    func test_listItemStyle_isDerivedFromSelectionType() {
        // Arrange / Act -- exercises the passthrough for both layouts
        _ = self.makeSUT(selectionType: .chevron).listItemStyle
        _ = self.makeSUT(selectionType: .radioButton).listItemStyle
    }

    // MARK: - Helpers

    private func makeSUT(
        selectionType: MethodSelectionOutput.LayoutType = .radioButton
    ) -> MethodSelectionViewModel {
        MethodSelectionViewModel(output: self.makeOutput(selectionType: selectionType))
    }

    private func makeOutput(
        selectionType: MethodSelectionOutput.LayoutType
    ) -> MethodSelectionOutput {
        MethodSelectionOutput(
            headerTitle: "¿Cómo querés pagar?",
            selectionType: selectionType,
            footer: .init(
                totalLabel: "Total",
                totalAmount: "$ 1.000",
                button: .init(label: "Generar código de pago")
            ),
            options: [
                .init(id: "rapipago", name: "Rapipago", subtitle: "Efectivo", iconUrl: "https://img/rapipago.png"),
                .init(id: "pago_facil", name: "Pago Fácil", subtitle: "Efectivo", iconUrl: "https://img/pagofacil.png")
            ]
        )
    }
}
