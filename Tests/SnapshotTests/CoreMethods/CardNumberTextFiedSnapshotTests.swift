//
//  CardNumberTextFiedSnapshotTests.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 17/01/25.
//

import CommonTests
@testable import CoreMethods
import SnapshotTesting
import XCTest

@MainActor
final class CardNumberTextFieldSnapshotTests: XCTestCase {
    private typealias SUT = (
        sut: CardNumberTextField,
        input: PCIFieldState
    )

    // MARK: - Factory Methods

    private func makeSUT(
        style: PCIFieldStateStyleProtocol = TextFieldDefaultStyle(),
        file _: StaticString = #filePath,
        line _: UInt = #line
    ) -> SUT {
        let container = MockDependencyContainer()

        let sut = CardNumberTextField(style: style, dependencies: container)
        sut.frame = CGRect(x: 0, y: 0, width: 300, height: 56)
        sut.backgroundColor = .white
        sut.setPlaceholder("Card number")

        return (sut, sut.input)
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
        let (sut, _) = self.makeSUT()

        assertSnapshot(
            of: sut,
            as: .image(size: sut.frame.size),
            named: "card_field_default"
        )
    }

    func test_customStyleAppearance() {
        let style = self.makeCustomStyle()
        let (sut, _) = self.makeSUT(style: style)

        assertSnapshot(
            of: sut,
            as: .image(size: sut.frame.size),
            named: "card_field_custom_style"
        )
    }

    // MARK: - Input State Tests

    func test_partiallyFilledAppearance() {
        let (sut, input) = self.makeSUT()

        simulateTextInput("4111", input: input)

        assertSnapshot(
            of: sut,
            as: .image(size: sut.frame.size),
            named: "card_field_partially_filled"
        )
    }

    func test_completelyFilledAppearance() {
        let (sut, input) = self.makeSUT()

        simulateTextInput("4111111111111111", input: input)

        assertSnapshot(
            of: sut,
            as: .image(size: sut.frame.size),
            named: "card_field_completely_filled"
        )
    }

    // MARK: - Validation State Tests

    func test_customMaxLength() {
        let (sut, input) = self.makeSUT()
        sut.setMaxLength(4)

        simulateTextInput("4111111111111111", input: input)

        assertSnapshot(
            of: sut,
            as: .image(size: sut.frame.size),
            named: "card_field_max_length_four"
        )
    }

    func test_errorStateAppearance() async {
        let (sut, _) = self.makeSUT(style: self.makeCustomStyle())

        sut.setStyle(self.makeErrorCustomStyle())

        assertSnapshot(
            of: sut,
            as: .image(size: sut.frame.size),
            named: "card_field_error_state"
        )
    }

    func test_disabledStateAppearance() {
        let (sut, _) = self.makeSUT()

        sut.isEnabled = false

        assertSnapshot(
            of: sut,
            as: .image(size: sut.frame.size),
            named: "card_field_disabled"
        )
    }

    // MARK: - Side Views Tests

    func test_leftIconAppearance() {
        let (sut, _) = self.makeSUT()
        let imageView = UIImageView(image: UIImage(systemName: "creditcard.fill"))
        imageView.tintColor = .blue
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)

        sut.setLeftImage(view: imageView)

        assertSnapshot(
            of: sut,
            as: .image(size: sut.frame.size),
            named: "card_field_left_icon"
        )
    }

    func test_rightIconAppearance() {
        let (sut, _) = self.makeSUT()
        let imageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        imageView.tintColor = .green
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)

        sut.setRightImage(view: imageView)

        assertSnapshot(
            of: sut,
            as: .image(size: sut.frame.size),
            named: "card_field_right_icon"
        )
    }

    // MARK: - Masks

    func test_customMask() {
        let (sut, input) = self.makeSUT()
        sut.setMaxLength(15)
        sut.setMask(pattern: "#### ###### #####")

        simulateTextInput("341369256028272", input: input)

        assertSnapshot(
            of: sut,
            as: .image(size: sut.frame.size),
            named: "card_field_mask_america_express_max_length_15"
        )
    }

    func test_with19Digits() {
        let (sut, input) = self.makeSUT()

        simulateTextInput("5993199916395529539", input: input)

        assertSnapshot(
            of: sut,
            as: .image(size: sut.frame.size),
            named: "card_field"
        )
    }

    func test_with16Digits() {
        let (sut, input) = self.makeSUT()

        simulateTextInput("5993199916395529", input: input)

        assertSnapshot(
            of: sut,
            as: .image(size: sut.frame.size),
            named: "card_field"
        )
    }
}

// MARK: - Helpers

private extension CardNumberTextFieldSnapshotTests {
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
