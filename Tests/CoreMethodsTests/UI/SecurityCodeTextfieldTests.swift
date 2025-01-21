//
//  SecurityCodeTextfieldTests.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 21/01/25.
//

@testable import CoreMethods
import XCTest

@MainActor
final class SecurityCodeTextFieldTests: XCTestCase {
    private typealias SUT = (
        sut: SecurityCodeTextField,
        input: PCIFieldState
    )

    // MARK: - Factory Methods

    private func makeSUT(
        maxLength: Int = 3,
        file _: StaticString = #filePath,
        line _: UInt = #line
    ) -> SUT {
        let sut = SecurityCodeTextField(maxLength: maxLength)
        return (sut, sut.input)
    }

    // MARK: - Initialization Tests

    func test_init_defaultValues() {
        let (sut, _) = self.makeSUT()

        XCTAssertNotNil(sut.style)
        XCTAssertTrue(sut.isEnabled)
        XCTAssertEqual(sut.count, 0)
        XCTAssertFalse(sut.isValid)
    }

    // MARK: - onInputFilled Tests

    func test_onInputFilled_shouldTriggerWhenFieldValid() async {
        let (sut, input) = self.makeSUT()
        let expectation = expectation(description: "onInputFilled called")

        sut.onInputFilled = {
            expectation.fulfill()
        }

        simulateTextInput("123", input: input)

        await fulfillment(of: [expectation], timeout: 1.0)
    }

    // MARK: - Last Four Digits Tests

    func test_onLengthChanged_shouldTriggerWhenValidNumberCompleted() {
        let (sut, input) = self.makeSUT()
        var capturedLength: Int?
        sut.onLengthChanged = { length in
            capturedLength = length
        }

        simulateTextInput("123", input: input)

        XCTAssertEqual(capturedLength, 3)
    }

    func test_onLengthChanged_shouldTriggerWhenDigitNumberInField() {
        let (sut, input) = self.makeSUT()
        var currentLength = 0
        sut.onLengthChanged = { length in
            currentLength = length
        }

        simulateTextInput("123", input: input)

        XCTAssertEqual(currentLength, 3)
    }

    // MARK: - Error Handling Tests

    func test_onError_shouldTriggerWithInvalidLength() {
        let (sut, input) = self.makeSUT()
        var capturedError: SecurityCodeError?
        sut.onError = { error in
            capturedError = error
        }

        simulateTextInput("12", input: input)
        input.onFocusChange?(false)

        XCTAssertEqual(capturedError, .invalidLength)
    }

    // MARK: - Focus Tests

    func test_onFocusChanged_shouldTrackFocusState() {
        let (sut, input) = self.makeSUT()
        var focusStates: [Bool] = []
        sut.onFocusChanged = { isFocused in
            focusStates.append(isFocused)
        }

        input.onFocusChange?(true)
        input.onFocusChange?(false)

        XCTAssertEqual(focusStates, [true, false])
    }

    // MARK: - Style Tests

    func test_setStyle_shouldUpdateAndReturnSelf() {
        let (sut, _) = self.makeSUT()
        let newStyle = TextFieldDefaultStyle()
            .textColor(.red)
            .borderColor(.blue)

        let result = sut.setStyle(newStyle)

        XCTAssertTrue(result === sut)
        XCTAssertEqual(sut.style.textColor, newStyle.textColor)
        XCTAssertEqual(sut.style.borderColor, newStyle.borderColor)
    }

    // MARK: - Clear Tests

    func test_clear_shouldResetToInitialState() {
        let (sut, input) = self.makeSUT()

        simulateTextInput("4111111111111111", input: input)
        sut.clear()

        XCTAssertEqual(sut.count, 0)
        XCTAssertFalse(sut.isValid)
        XCTAssertEqual(input.getValue(), "")
    }

    // MARK: - Max Length Tests

    func test_setMaxLength_shouldUpdateAndReturnSelf() {
        let (sut, input) = self.makeSUT()
        let newMaxLength = 13
        let text = "4123456789111213145"

        let result = sut.setMaxLength(newMaxLength)
        simulateTextInput(text, input: input)

        XCTAssertTrue(result === sut)
        XCTAssertEqual(sut.count, newMaxLength)
    }

    // MARK: - Placeholder

    func test_setPlaceholder_shouldUpdatePlaceholderAndReturnSelf() {
        let (sut, input) = self.makeSUT()
        let text = "card number insert"

        sut.setPlaceholder(text)
        simulateTextInput(text, input: input)

        XCTAssertEqual(sut.input.textField.placeholder, text)
    }

    // MARK: - Side View Tests

    func test_setLeftImage_shouldUpdateAndReturnSelf() {
        let (sut, _) = self.makeSUT()
        let imageView = UIImageView()

        let result = sut.setLeftImage(view: imageView)

        XCTAssertTrue(result === sut)
    }

    func test_setRightImage_shouldUpdateAndReturnSelf() {
        let (sut, _) = self.makeSUT()
        let imageView = UIImageView()

        let result = sut.setRightImage(view: imageView)

        XCTAssertTrue(result === sut)
    }
}

// MARK: - Helpers

private extension SecurityCodeTextFieldTests {
    func simulateTextInput(_ text: String, input: PCIFieldState) {
        for char in text {
            let range = NSRange(location: input.textField.text?.count ?? 0, length: 0)
            _ = input.textField(
                input.textField,
                shouldChangeCharactersIn: range,
                replacementString: String(char)
            )
        }
    }
}
