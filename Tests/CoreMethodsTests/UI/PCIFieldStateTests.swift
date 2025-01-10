//
//  PCIFieldStateTests.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 10/01/25.
//

@testable import CoreMethods
import XCTest

private extension PCIFieldStateTests {
    typealias SUT = (
        sut: PCIFieldState,
        textfield: UITextField
    )

    func makeSUT(file _: StaticString = #filePath, line _: UInt = #line) -> SUT {
        let style = self.makeCustomStyle()
        let configuration = PCIFieldState.Configuration(
            maxLength: 16,
            validation: MockCardValidation(),
            style: style,
            mask: .init(pattern: "#### #### #### ####", separator: " ")
        )

        let sut = PCIFieldState(configuration: configuration)
        let textField = sut.textField

        return (sut, textField)
    }

    func makeCustomStyle() -> TextFieldDefaultStyle {
        TextFieldDefaultStyle()
            .textColor(.red)
            .font(.systemFont(ofSize: 20))
            .backgroundColor(.white)
            .borderColor(.blue)
            .borderWidth(2)
            .cornerRadius(10)
            .placeholderColor(.gray)
            .clearButtonMode(.whileEditing)
            .clearButtonTintColor(.blue)
            .textAlignment(.center)
            .adjustsFontSizeToFitWidth(true)
    }
}

@MainActor
final class PCIFieldStateTests: XCTestCase {
    // MARK: - Initialization Tests

    func test_initialization_shouldConfigureTextFieldCorrectly() {
        let (_, textField) = self.makeSUT()

        XCTAssertEqual(textField.keyboardType, .numberPad)
        XCTAssertEqual(textField.autocorrectionType, .no)
        XCTAssertTrue(textField.isAccessibilityElement)
        XCTAssertEqual(textField.rightViewMode, .never)
        XCTAssertEqual(textField.leftViewMode, .never)
    }

    func test_initialization_shouldApplyCustomStyle() {
        let (_, textField) = self.makeSUT()
        let style = self.makeCustomStyle()

        XCTAssertEqual(textField.textColor, style.textColor)
        XCTAssertEqual(textField.font, style.font)
        XCTAssertEqual(textField.backgroundColor, style.backgroundColor)
        XCTAssertEqual(textField.layer.borderColor, style.borderColor.cgColor)
        XCTAssertEqual(textField.layer.borderWidth, style.borderWidth)
        XCTAssertEqual(textField.layer.cornerRadius, style.cornerRadius)
        XCTAssertEqual(textField.clearButtonMode, style.clearButtonMode)
        XCTAssertEqual(textField.textAlignment, style.textAlignment)
        XCTAssertEqual(textField.adjustsFontSizeToFitWidth, style.adjustsFontSizeToFitWidth)
    }

    // MARK: - Text Input Tests

    func test_textInput_shouldRespectMaxLength() {
        let (sut, _) = self.makeSUT()

        simulateTextInput("12345678901234567", sut: sut)

        XCTAssertEqual(sut.getValue(), "1234567890123456")
    }

    func test_textInput_shouldApplyMaskCorrectly() {
        let (sut, textField) = self.makeSUT()

        simulateTextInput("5390287952984029", sut: sut)

        XCTAssertEqual(textField.text, "5390 2879 5298 4029")
    }

    func test_textInput_shouldOnlyAllowNumbers() {
        let (sut, _) = self.makeSUT()

        simulateTextInput("abc123def456", sut: sut)

        XCTAssertEqual(sut.getValue(), "123456")
    }

    // MARK: - Validation Tests

    func test_validation_shouldTriggerOnCompleteWhenMaxLengthReached() async {
        let (sut, _) = self.makeSUT()
        let expectation = expectation(description: "onComplete called")

        sut.onComplete = {
            expectation.fulfill()
        }

        simulateTextInput("1234567890123456", sut: sut)
        await fulfillment(of: [expectation], timeout: 1.0)
    }

    func test_validation_shouldUpdateValidState() {
        let (sut, _) = self.makeSUT()

        simulateTextInput("1234567890123456", sut: sut)
        XCTAssertTrue(sut.isValid)

        sut.textField.text = ""

        simulateTextInput("1234", sut: sut)
        XCTAssertFalse(sut.isValid)
    }

    // MARK: - Side Views Tests

    func test_sideViews_shouldConfigureLeftViewCorrectly() {
        let (sut, textField) = self.makeSUT()
        let imageView = UIImageView(image: UIImage())

        sut.setLeftView(imageView, mode: .always)

        XCTAssertNotNil(textField.leftView)
        XCTAssertEqual(textField.leftViewMode, .always)
    }

    func test_sideViews_shouldConfigureRightViewCorrectly() {
        let (sut, textField) = self.makeSUT()
        let imageView = UIImageView(image: UIImage())

        sut.setRightView(imageView, mode: .always)

        XCTAssertNotNil(textField.rightView)
        XCTAssertEqual(textField.rightViewMode, .always)
    }

    func test_sideViews_shouldRemoveViewsCorrectly() {
        let (sut, textField) = self.makeSUT()
        let imageView = UIImageView(image: UIImage())

        sut.setLeftView(imageView, mode: .always)
        sut.setLeftView(nil, mode: .never)

        XCTAssertNil(textField.leftView)
        XCTAssertEqual(textField.leftViewMode, .never)
    }

    // MARK: - State Tests

    func test_disabled_shouldApplyCorrectStyle() {
        let (sut, textField) = self.makeSUT()
        let style = self.makeCustomStyle()

        sut.isEnabled = false

        XCTAssertFalse(sut.isEnabled)
        XCTAssertEqual(textField.textColor, style.textColor)
        XCTAssertEqual(textField.backgroundColor, style.backgroundColor)
        XCTAssertEqual(textField.layer.borderColor, style.borderColor.cgColor)
        XCTAssertEqual(textField.layer.opacity, style.opacity, accuracy: 0.0001)
    }

    // MARK: - Callback Tests

    func test_callbacks_shouldTriggerOnChangeWithCorrectValue() {
        let (sut, _) = self.makeSUT()
        var receivedValue: String?

        sut.onChange = { value in
            receivedValue = value
        }

        simulateTextInput("123", sut: sut)

        XCTAssertEqual(receivedValue, "123")
    }

    func test_callbacks_shouldTriggerOnFocusChangeWhenFocusChanges() {
        let (sut, textField) = self.makeSUT()
        var focusStates: [Bool] = []

        sut.onFocusChange = { isFocused in
            focusStates.append(isFocused)
        }

        textField.delegate?.textFieldDidBeginEditing?(textField)
        textField.delegate?.textFieldDidEndEditing?(textField)

        XCTAssertEqual(focusStates, [true, false])
    }

    // MARK: - Placeholder Tests

    func test_placeholder_shouldUpdateCorrectly() {
        let (sut, textField) = self.makeSUT()
        let placeholder = "Enter card number"

        sut.setPlaceholder(placeholder)

        XCTAssertEqual(textField.placeholder, placeholder)
    }

    // MARK: - Clear Method Tests

    func test_clear_shouldResetStateCorrectly() {
        let (sut, _) = self.makeSUT()

        simulateTextInput("1234", sut: sut)
        sut.clear()

        XCTAssertEqual(sut.getValue(), "")
        XCTAssertEqual(sut.count, 0)
        XCTAssertFalse(sut.isValid)
    }

    // MARK: - Dynamic Configuration Tests

    func test_maxLength_shouldUpdateDynamically() {
        let (sut, _) = self.makeSUT()

        sut.setMaxLenght(4)
        simulateTextInput("12345", sut: sut)

        XCTAssertEqual(sut.getValue(), "1234")
    }

    func test_style_shouldUpdateDynamically() {
        let (sut, textField) = self.makeSUT()
        let newStyle = TextFieldDefaultStyle()
            .textColor(.green)
            .borderColor(.red)
            .cornerRadius(20)

        sut.setStyle(newStyle)

        XCTAssertEqual(textField.textColor, newStyle.textColor)
        XCTAssertEqual(textField.layer.borderColor, newStyle.borderColor.cgColor)
        XCTAssertEqual(textField.layer.cornerRadius, newStyle.cornerRadius)
    }

    // MARK: - Mask Configuration Tests

    func test_differentMaskPatterns_shouldFormatCorrectly() {
        let configuration = PCIFieldState.Configuration(
            maxLength: 6,
            validation: MockCardValidation(),
            mask: .init(pattern: "##-##-##", separator: "-")
        )
        let sut = PCIFieldState(configuration: configuration)

        simulateTextInput("123456", sut: sut)

        XCTAssertEqual(sut.textField.text, "12-34-56")
    }

    // MARK: - Edge Cases Tests

    func test_input_shouldHandlePasteCorrectly() {
        let (sut, textField) = self.makeSUT()

        let range = NSRange(location: 0, length: 0)
        _ = sut.textField(textField, shouldChangeCharactersIn: range, replacementString: "1234567890")

        XCTAssertEqual(sut.getValue(), "1234567890")
    }
}

// MARK: - Helpers

private extension PCIFieldStateTests {
    func simulateTextInput(_ text: String, sut: PCIFieldState) {
        for char in text {
            let range = NSRange(location: sut.textField.text?.count ?? 0, length: 0)
            _ = sut.textField(
                sut.textField,
                shouldChangeCharactersIn: range,
                replacementString: String(char)
            )
        }
    }
}

// MARK: - Mocks

private class MockCardValidation: InputValidation {
    func isValid(_ input: String) -> Bool {
        input.count == 16
    }
}
