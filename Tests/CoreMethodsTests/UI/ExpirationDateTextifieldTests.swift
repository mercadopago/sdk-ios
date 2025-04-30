//
//  ExpirationDateTextifieldTests.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 27/01/25.
//

import CommonTests
@testable import CoreMethods
import XCTest

@MainActor
final class ExpirationDateTextfieldTests: XCTestCase {
    private typealias SUT = (
        sut: ExpirationDateTextfield,
        input: PCIFieldState,
        analytics: MockAnalytics
    )

    // MARK: - Factory Methods

    private func makeSUT(
        file _: StaticString = #filePath,
        line _: UInt = #line
    ) -> SUT {
        let container = MockDependencyContainer()
        let analytics = container.mockAnalytics

        let sut = ExpirationDateTextfield(dependencies: container)
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

    // MARK: - Format Tests

    func test_shortFormat_shouldLimitToFourDigits() {
        let (sut, input, _) = self.makeSUT()

        sut.setFormat(.short)

        simulateTextInput("12345", input: input)

        XCTAssertEqual(sut.count, 4)
        XCTAssertEqual(input.textField.text, "12/34")

        // Internal
        XCTAssertEqual(sut.getMonth(), "12")
        XCTAssertEqual(sut.getYear(), "2034")
    }

    func test_longFormat_shouldLimitToSixDigits() {
        let (sut, input, _) = self.makeSUT()
        sut.setFormat(.long)

        simulateTextInput("123456", input: input)

        XCTAssertEqual(sut.count, 6)
        XCTAssertEqual(input.textField.text, "12/3456")
    }

    func test_setFormat_WhenSelectLong_shouldLimitToSixDigits() {
        let (sut, input, _) = self.makeSUT()
        sut.setFormat(.long)

        simulateTextInput("123456", input: input)

        XCTAssertEqual(sut.count, 6)
        XCTAssertEqual(input.textField.text, "12/3456")

        // Internal
        XCTAssertEqual(sut.getMonth(), "12")
        XCTAssertEqual(sut.getYear(), "3456")
    }

    // MARK: - Validation Tests

    func test_validation_shouldRejectInvalidMonth() {
        let (sut, input, _) = self.makeSUT()
        var capturedError: ExpirationDateError?
        sut.onError = { error in
            capturedError = error
        }

        simulateTextInput("13/25", input: input)
        input.onFocusChange?(false)

        XCTAssertEqual(capturedError, .invalidDate)
        XCTAssertFalse(sut.isValid)
    }

    func test_validation_shouldRejectExpiredDate() {
        let (sut, input, _) = self.makeSUT()
        var capturedError: ExpirationDateError?
        sut.onError = { error in
            capturedError = error
        }

        simulateTextInput("01/20", input: input)
        input.onFocusChange?(false)

        XCTAssertEqual(capturedError, .expired)
        XCTAssertFalse(sut.isValid)
    }

    func test_validation_shouldAcceptValidFutureDate() {
        let (sut, input, _) = self.makeSUT()
        var inputFilledCalled = false
        sut.onInputFilled = {
            inputFilledCalled = true
        }

        simulateTextInput("12/30", input: input)

        XCTAssertTrue(sut.isValid)
        XCTAssertTrue(inputFilledCalled)
    }

    // MARK: - onInputFilled Tests

    func test_onInputFilled_shouldTriggerWhenFieldValid() async {
        let (sut, input, _) = self.makeSUT()
        let expectation = expectation(description: "onInputFilled called")

        sut.onInputFilled = {
            expectation.fulfill()
        }

        simulateTextInput("12/25", input: input)

        await fulfillment(of: [expectation], timeout: 1.0)
    }

    // MARK: - Length Changed Tests

    func test_onLengthChanged_shouldTriggerWhenDigitsAdded() {
        let (sut, input, _) = self.makeSUT()
        var capturedLengths: [Int] = []
        sut.onLengthChanged = { length in
            capturedLengths.append(length)
        }

        simulateTextInput("12/25", input: input)

        XCTAssertEqual(capturedLengths, [1, 2, 2, 3, 4])
    }

    // MARK: - Focus Tests

    func test_onFocusChanged_shouldTrackFocusStateAndAnalytics() async {
        let (sut, input, analytics) = self.makeSUT()
        let expectEventData = SecureFieldEventData(field: .expirationDate, frameworkUI: .uikit)

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

        simulateTextInput("12/25", input: input)
        sut.clear()

        XCTAssertEqual(sut.count, 0)
        XCTAssertFalse(sut.isValid)
        XCTAssertEqual(input.getValue(), "")
    }

    // MARK: - Placeholder Tests

    func test_setPlaceholder_shouldUpdatePlaceholderAndReturnSelf() {
        let (sut, _, _) = self.makeSUT()
        let text = "MM/YY"

        let result = sut.setPlaceholder(text)

        XCTAssertTrue(result === sut)
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
}

// MARK: - Helpers

private extension ExpirationDateTextfieldTests {
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
