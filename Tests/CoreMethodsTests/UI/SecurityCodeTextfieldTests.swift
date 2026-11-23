//
//  SecurityCodeTextfieldTests.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 21/01/25.
//

import CommonTests
@testable import CoreMethods
import XCTest

@MainActor
final class SecurityCodeTextFieldTests: XCTestCase {
    private typealias SUT = (
        sut: SecurityCodeTextField,
        input: PCIFieldState,
        analytics: MockAnalytics
    )

    // MARK: - Factory Methods

    private func makeSUT(
        maxLength: Int = 3,
        isMasked: Bool = false,
        file _: StaticString = #filePath,
        line _: UInt = #line
    ) -> SUT {
        let container = MockDependencyContainer()
        let analytics = container.mockAnalytics

        let sut = SecurityCodeTextField(maxLength: maxLength, isMasked: isMasked, dependencies: container)
        return (sut, sut.input, analytics)
    }

    // MARK: - Initialization Tests

    func test_init_defaultValues() {
        let (sut, _, _) = self.makeSUT()

        XCTAssertNotNil(sut.style)
        XCTAssertTrue(sut.isEnabled)
        XCTAssertEqual(sut.count, 0)
        XCTAssertFalse(sut.isValid)
    }

    // MARK: - onInputFilled Tests

    func test_onInputFilled_shouldTriggerWhenFieldValid() async {
        let (sut, input, _) = self.makeSUT()
        let expectation = expectation(description: "onInputFilled called")

        sut.onInputFilled = {
            expectation.fulfill()
        }

        simulateTextInput("123", input: input)

        await fulfillment(of: [expectation], timeout: 1.0)
    }

    // MARK: - Last Four Digits Tests

    func test_onLengthChanged_shouldTriggerWhenValidNumberCompleted() {
        let (sut, input, _) = self.makeSUT()
        var capturedLength: Int?
        sut.onLengthChanged = { length in
            capturedLength = length
        }

        simulateTextInput("123", input: input)

        XCTAssertEqual(capturedLength, 3)
    }

    func test_onLengthChanged_shouldTriggerWhenDigitNumberInField() {
        let (sut, input, _) = self.makeSUT()
        var currentLength = 0
        sut.onLengthChanged = { length in
            currentLength = length
        }

        simulateTextInput("123", input: input)

        XCTAssertEqual(currentLength, 3)
    }

    // MARK: - Error Handling Tests

    func test_onError_shouldTriggerWithInvalidLength() {
        let (sut, input, _) = self.makeSUT()
        var capturedError: SecurityCodeError?
        sut.onError = { error in
            capturedError = error
        }

        simulateTextInput("12", input: input)
        input.onFocusChange?(false)

        XCTAssertEqual(capturedError, .invalidLength)
    }

    // MARK: - Focus Tests

    func test_onFocusChanged_shouldTrackFocusStateAndAnalytics() async {
        let (sut, input, analytics) = self.makeSUT()
        let expectEventData = SecureFieldEventData(field: .securityCode, frameworkUI: .uikit)

        await sut.analyticsTask?.value

        var focusStates: [Bool] = []
        sut.onFocusChanged = { isFocused in
            focusStates.append(isFocused)
        }

        input.onFocusChange?(true)
        input.onFocusChange?(false)

        await sut.analyticsTask?.value

        let messages = await analytics.mock.getMessages()

        XCTAssertEqual(focusStates, [true, false])

        XCTAssertEqual(
            messages,
            [
                .trackView("/checkout_api_native/core_methods/pci_field"),
                .setEventData(expectEventData.toDictionary()),
                .send,
                .track(path: "/checkout_api_native/core_methods/focus"),
                .setEventData(expectEventData.toDictionary()),
                .send
            ]
        )
    }

    // MARK: - Style Tests

    func test_setStyle_shouldUpdateAndReturnSelf() {
        let (sut, _, _) = self.makeSUT()
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
        let (sut, input, _) = self.makeSUT()

        simulateTextInput("4111111111111111", input: input)
        sut.clear()

        XCTAssertEqual(sut.count, 0)
        XCTAssertFalse(sut.isValid)
        XCTAssertEqual(input.getValue(), "")
    }

    // MARK: - Max Length Tests

    func test_setMaxLength_shouldUpdateAndReturnSelf() {
        let (sut, input, _) = self.makeSUT()
        let newMaxLength = 13
        let text = "4123456789111213145"

        let result = sut.setMaxLength(newMaxLength)
        simulateTextInput(text, input: input)

        XCTAssertTrue(result === sut)
        XCTAssertEqual(sut.count, newMaxLength)
    }

    // MARK: - Placeholder

    func test_setPlaceholder_shouldUpdatePlaceholderAndReturnSelf() {
        let (sut, input, _) = self.makeSUT()
        let text = "card number insert"

        sut.setPlaceholder(text)
        simulateTextInput(text, input: input)

        XCTAssertEqual(sut.input.textField.placeholder, text)
    }

    // MARK: - Side View Tests

    func test_setLeftImage_shouldUpdateAndReturnSelf() {
        let (sut, _, _) = self.makeSUT()
        let imageView = UIImageView()

        let result = sut.setLeftImage(view: imageView)

        XCTAssertTrue(result === sut)
    }

    func test_setRightImage_shouldUpdateAndReturnSelf() {
        let (sut, _, _) = self.makeSUT()
        let imageView = UIImageView()

        let result = sut.setRightImage(view: imageView)

        XCTAssertTrue(result === sut)
    }

    // MARK: - Masking Tests

    func test_init_isNotMaskedByDefault() {
        let (sut, input, _) = self.makeSUT()

        XCTAssertFalse(sut.isMasked)
        XCTAssertFalse(input.textField.isSecureTextEntry)
    }

    func test_init_withIsMasked_shouldEnableSecureTextEntry() {
        let (sut, input, _) = self.makeSUT(isMasked: true)

        XCTAssertTrue(sut.isMasked)
        XCTAssertTrue(input.textField.isSecureTextEntry)
    }

    func test_publicInit_withIsMasked_shouldEnableSecureTextEntry() {
        let sut = SecurityCodeTextField(isMasked: true)

        XCTAssertTrue(sut.isMasked)
        XCTAssertTrue(sut.input.textField.isSecureTextEntry)
    }

    func test_setMasked_shouldToggleSecureTextEntryAndReturnSelf() {
        let (sut, input, _) = self.makeSUT()

        let result = sut.setMasked(true)

        XCTAssertTrue(result === sut)
        XCTAssertTrue(input.textField.isSecureTextEntry)

        sut.setMasked(false)

        XCTAssertFalse(input.textField.isSecureTextEntry)
    }

    func test_masked_shouldKeepKeyboardConfiguration() {
        let (_, input, _) = self.makeSUT(isMasked: true)

        XCTAssertEqual(input.textField.keyboardType, .numberPad)
        XCTAssertEqual(input.textField.autocorrectionType, .no)
    }

    func test_masked_shouldKeepRealValueForTokenization() {
        let (sut, input, _) = self.makeSUT(isMasked: true)

        simulateTextInput("123", input: input)

        XCTAssertEqual(input.getValue(), "123")
        XCTAssertEqual(sut.count, 3)
        XCTAssertTrue(sut.isValid)
    }

    func test_masked_toggleAfterInput_shouldNotChangeValue() {
        let (sut, input, _) = self.makeSUT()
        simulateTextInput("456", input: input)

        sut.setMasked(true)
        XCTAssertEqual(input.getValue(), "456")

        sut.setMasked(false)
        XCTAssertEqual(input.getValue(), "456")
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
