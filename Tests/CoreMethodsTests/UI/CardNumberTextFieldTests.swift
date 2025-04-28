//
//  CardNumberTextFieldTests.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 20/01/25.
//

import CommonTests
@testable import CoreMethods
import XCTest

@MainActor
final class CardNumberTextFieldTests: XCTestCase {
    private typealias SUT = (
        sut: CardNumberTextField,
        input: PCIFieldState,
        analytics: MockAnalytics
    )

    // MARK: - Factory Methods

    private func makeSUT(
        maxLength: Int = 19,
        file _: StaticString = #filePath,
        line _: UInt = #line
    ) -> SUT {
        let container = MockDependencyContainer()
        let analytics = container.mockAnalytics

        let sut = CardNumberTextField(maxLength: maxLength, dependencies: container)

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

    // MARK: - BIN Detection Tests

    func test_onBinChanged_shouldTriggerWhenFirst8DigitsEntered() {
        let (sut, input, _) = self.makeSUT()
        var capturedBin: String?
        sut.onBinChanged = { bin in
            capturedBin = bin
        }

        simulateTextInput("41111111", input: input)

        XCTAssertEqual(capturedBin, "41111111")
    }

    func test_onBinChanged_shouldTriggerWithLessThan8Digits() {
        let (sut, input, _) = self.makeSUT()
        var binChangeCount = 0
        sut.onBinChanged = { _ in
            binChangeCount += 1
        }

        simulateTextInput("411111133", input: input)

        XCTAssertEqual(binChangeCount, 2)
    }

    // MARK: - Last Four Digits Tests

    func test_onLastFourDigitsFilled_shouldTriggerWhenValidNumberCompleted() {
        let (sut, input, _) = self.makeSUT()
        var capturedLastFour: String?
        sut.onLastFourDigitsFilled = { lastFour in
            capturedLastFour = lastFour
        }

        simulateTextInput("4111111111114321", input: input)

        XCTAssertEqual(capturedLastFour, "4321")
    }

    func test_onLastFourDigitsFilled_shouldValidateLuhn() {
        let (sut, input, _) = self.makeSUT()
        var capturedLastFour: String?
        sut.onLastFourDigitsFilled = { lastFour in
            capturedLastFour = lastFour
        }

        simulateTextInput("5181163347419299", input: input)

        XCTAssertEqual(capturedLastFour, "9299")
        XCTAssertTrue(sut.isValid)
    }

    // MARK: - Luhn Validation Tests

    func test_onLastFourDigitsFilled_When19Digits_shouldValidateLuhn() async {
        let (sut, input, _) = self.makeSUT()

        var capturedLastFour: String?
        sut.onLastFourDigitsFilled = { lastFour in
            capturedLastFour = lastFour
        }
        simulateTextInput("5993199916395529539", input: input)

        XCTAssertEqual(capturedLastFour, "9539")
        XCTAssertTrue(sut.isValid)
    }

    func test_onLastFourDigitsFilled_When15Digitis_shouldValidateLuhn() {
        let (sut, input, _) = self.makeSUT(maxLength: 15)

        sut.setMask(pattern: "#### ###### #####")

        var capturedLastFour: String?
        sut.onLastFourDigitsFilled = { lastFour in
            capturedLastFour = lastFour
        }

        simulateTextInput("341369256028272", input: input)

        XCTAssertEqual(capturedLastFour, "8272")
        XCTAssertTrue(sut.isValid)
    }

    // MARK: - Error Handling Tests

    func test_onError_shouldTriggerWithInvalidLuhn() {
        let (sut, input, _) = self.makeSUT()
        var capturedError: CardNumberError?
        sut.onError = { error in
            capturedError = error
        }

        simulateTextInput("4111111111111112", input: input)
        input.onFocusChange?(false)

        XCTAssertEqual(capturedError, .invalidLuhn)
    }

    func test_onError_shouldTriggerWithInvalidLength() {
        let (sut, input, _) = self.makeSUT()
        var capturedError: CardNumberError?
        sut.onError = { error in
            capturedError = error
        }

        simulateTextInput("41111", input: input)
        input.onFocusChange?(false)

        XCTAssertEqual(capturedError, .invalidLength)
    }

    func test_onError_When19Digits_shouldNotValidateLuhn() async {
        let (sut, input, _) = self.makeSUT()

        var capturedError: CardNumberError?
        sut.onError = { error in
            capturedError = error
        }

        simulateTextInput("5993199916395529", input: input)
        input.onFocusChange?(false)

        XCTAssertEqual(capturedError, .invalidLuhn)
    }

    // MARK: - Focus Tests

    func test_onFocusChanged_shouldTrackFocusStateAndAnalytics() async {
        let (sut, input, analytics) = self.makeSUT()
        let expectEventData = SecureFieldEventData(field: .cardNumber, frameworkUI: .uikit)

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

    func test_init_shouldSendEventData() async {
        let (sut, _, analytics) = self.makeSUT()
        let expectEventData = SecureFieldEventData(field: .cardNumber, frameworkUI: .uikit)

        await sut.analyticsTask?.value

        let messages = await analytics.mock.getMessages()

        XCTAssertEqual(
            messages,
            [
                .trackView("/checkout_api_native/core_methods/pci_field"),
                .setEventData(expectEventData.toDictionary()),
                .send
            ]
        )
    }
}

// MARK: - Helpers

private extension CardNumberTextFieldTests {
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
