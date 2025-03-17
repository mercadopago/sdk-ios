//
//  SecurityCodeTextFieldSnapshotTests.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 21/01/25.
//

import CommonTests
@testable import CoreMethods
import SnapshotTesting
import XCTest

@MainActor
final class SecurityCodeTextFieldSnapshotTests: XCTestCase {
    private typealias SUT = (
        sut: SecurityCodeTextField,
        input: PCIFieldState,
        analytics: MockAnalytics
    )

    // MARK: - Factory Methods

    private func makeSUT(
        style: PCIFieldStateStyleProtocol = TextFieldDefaultStyle(),
        file _: StaticString = #filePath,
        line _: UInt = #line
    ) -> SUT {
        let container = MockDependencyContainer()
        let analytics = container.mockAnalytics

        let sut = SecurityCodeTextField(style: style, dependencies: container)
        sut.frame = CGRect(x: 0, y: 0, width: 300, height: 56)
        sut.backgroundColor = .white
        sut.setPlaceholder("Insert security code")

        return (sut, sut.input, analytics)
    }

    private func makeCustomStyle() -> TextFieldDefaultStyle {
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

    private func makeErrorCustomStyle() -> TextFieldDefaultStyle {
        TextFieldDefaultStyle()
            .textColor(.red)
            .font(.systemFont(ofSize: 20))
            .backgroundColor(.white)
            .borderColor(.red)
            .borderWidth(2)
            .cornerRadius(10)
            .placeholderColor(.gray)
            .clearButtonTintColor(.blue)
            .textAlignment(.center)
            .adjustsFontSizeToFitWidth(true)
    }

    // MARK: - Appearance Tests

    func test_defaultAppearance() {
        let (sut, _, _) = self.makeSUT()

        assertSnapshot(
            of: sut,
            as: .image(size: sut.frame.size),
            named: "card_field_default"
        )
    }

    func test_customStyleAppearance() {
        let style = self.makeCustomStyle()
        let (sut, _, _) = self.makeSUT(style: style)

        assertSnapshot(
            of: sut,
            as: .image(size: sut.frame.size),
            named: "card_field_custom_style"
        )
    }

    // MARK: - Input State Tests

    func test_partiallyFilledAppearance() {
        let (sut, input, _) = self.makeSUT()

        simulateTextInput("1", input: input)

        assertSnapshot(
            of: sut,
            as: .image(size: sut.frame.size),
            named: "security_field_partially_filled"
        )
    }

    func test_completelyFilledAppearance() {
        let (sut, input, _) = self.makeSUT()

        simulateTextInput("123", input: input)

        assertSnapshot(
            of: sut,
            as: .image(size: sut.frame.size),
            named: "security_field_completely_filled"
        )
    }

    // MARK: - Validation State Tests

    func test_customMaxLength() {
        let (sut, input, _) = self.makeSUT()
        sut.setMaxLength(4)

        simulateTextInput("1234", input: input)

        assertSnapshot(
            of: sut,
            as: .image(size: sut.frame.size),
            named: "security_field_max_length_four"
        )
    }

    func test_errorStateAppearance() async {
        let (sut, _, _) = self.makeSUT(style: self.makeCustomStyle())

        sut.setStyle(self.makeErrorCustomStyle())

        assertSnapshot(
            of: sut,
            as: .image(size: sut.frame.size),
            named: "security_field_error_state"
        )
    }

    func test_disabledStateAppearance() {
        let (sut, _, _) = self.makeSUT()

        sut.isEnabled = false

        assertSnapshot(
            of: sut,
            as: .image(size: sut.frame.size),
            named: "security_field_disabled"
        )
    }

    // MARK: - Side Views Tests

    func test_leftIconAppearance() {
        let (sut, _, _) = self.makeSUT()
        let imageView = UIImageView(image: UIImage(systemName: "creditcard.fill"))
        imageView.tintColor = .blue
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)

        sut.setLeftImage(view: imageView)

        assertSnapshot(
            of: sut,
            as: .image(size: sut.frame.size),
            named: "security_field_left_icon"
        )
    }

    func test_rightIconAppearance() {
        let (sut, _, _) = self.makeSUT()
        let imageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        imageView.tintColor = .green
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)

        sut.setRightImage(view: imageView)

        assertSnapshot(
            of: sut,
            as: .image(size: sut.frame.size),
            named: "security_field_right_icon"
        )
    }

    func test_init_shouldSendEventData() async {
        let (sut, _, analytics) = self.makeSUT()
        let expectEventData = SecureFieldEventData(field: .securityCode, frameworkUI: .uikit)

        await sut.analyticsTask?.value

        let messages = await analytics.mock.getMessages()

        XCTAssertEqual(
            messages,
            [
                .trackView("/sdk-native/core-methods/pci_field"),
                .setEventData(expectEventData.toDictionary()),
                .send
            ]
        )
    }
}

// MARK: - Helpers

private extension SecurityCodeTextFieldSnapshotTests {
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
