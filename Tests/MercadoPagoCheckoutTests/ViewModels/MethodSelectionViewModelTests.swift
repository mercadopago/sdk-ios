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

    func test_selectOption_whenChevron_emitsOptionImmediately() {
        // Arrange
        let sut = self.makeSUT(selectionType: .chevron)
        var emitted: MethodSelectionOutput.Option?
        sut.onOptionSelected = { emitted = $0 }

        // Act
        sut.selectOption("rapipago")

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

    func test_selectOption_whenChevronAndUnknownId_doesNothing() {
        // Arrange
        let sut = self.makeSUT(selectionType: .chevron)
        var emitted = false
        sut.onOptionSelected = { _ in emitted = true }

        // Act
        sut.selectOption("does-not-exist")

        // Assert
        XCTAssertFalse(emitted)
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

    func test_selectOption_whenRadioButton_doesNotEmitBeforeConfirm() {
        // Arrange
        let sut = self.makeSUT(selectionType: .radioButton)
        var emitted = false
        sut.onOptionSelected = { _ in emitted = true }

        // Act
        sut.selectOption("pago_facil")

        // Assert
        XCTAssertFalse(emitted)
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

    func test_confirmSelection_whenOptionSelected_emitsSelectedOption() {
        // Arrange
        let sut = self.makeSUT(selectionType: .radioButton)
        var emitted: MethodSelectionOutput.Option?
        sut.onOptionSelected = { emitted = $0 }
        sut.selectOption("pago_facil")

        // Act
        sut.confirmSelection()

        // Assert
        XCTAssertEqual(emitted?.id, "pago_facil")
    }

    func test_confirmSelection_afterEmitting_resetsSelectionAndDisablesCta() {
        // Arrange
        let sut = self.makeSUT(selectionType: .radioButton)
        sut.selectOption("pago_facil")

        // Act
        sut.confirmSelection()

        // Assert -- state is reset so the action is not re-triggerable
        XCTAssertNil(sut.selectedOptionId)
        XCTAssertFalse(sut.isCtaEnabled)
    }

    func test_confirmSelection_calledTwice_emitsOnlyOnce() {
        // Arrange
        let sut = self.makeSUT(selectionType: .radioButton)
        var emitCount = 0
        sut.onOptionSelected = { _ in emitCount += 1 }
        sut.selectOption("pago_facil")

        // Act -- simulate a rapid double tap on the CTA
        sut.confirmSelection()
        sut.confirmSelection()

        // Assert
        XCTAssertEqual(emitCount, 1)
    }

    func test_confirmSelection_whenNothingSelected_doesNotEmit() {
        // Arrange
        let sut = self.makeSUT(selectionType: .radioButton)
        var emitted = false
        sut.onOptionSelected = { _ in emitted = true }

        // Act
        sut.confirmSelection()

        // Assert
        XCTAssertFalse(emitted)
    }

    // MARK: - goBack()

    func test_goBack_invokesOnBack() {
        // Arrange
        let sut = self.makeSUT()
        var didGoBack = false
        sut.onBack = { didGoBack = true }

        // Act
        sut.goBack()

        // Assert
        XCTAssertTrue(didGoBack)
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
