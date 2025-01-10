//
//  PCIFieldStateSnapshotTests.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 09/01/25.
//

@testable import CoreMethods
import SnapshotTesting
import XCTest

struct MockValidation: InputValidation {
    func isValid(_: String) -> Bool {
        return true
    }
}

@MainActor
final class PCIFieldStateSnapshotTests: XCTestCase {
    func simulateTyping(sut: PCIFieldState, text: String) {
        for char in text {
            let range = NSRange(location: sut.textField.text?.count ?? 0, length: 0)
            _ = sut.textField(
                sut.textField,
                shouldChangeCharactersIn: range,
                replacementString: String(char)
            )
        }
    }

    private func makeSUT(
        maxLength: Int = 16,
        validation: InputValidation = MockValidation(),
        style: PCIFieldStateStyleProtocol = TextFieldDefaultStyle(),
        mask: PCIFieldState.Configuration.Mask? = nil
    ) -> PCIFieldState {
        let config = PCIFieldState.Configuration(
            maxLength: maxLength,
            validation: validation,
            style: style,
            mask: mask
        )
        let frame = CGRect(x: 0, y: 0, width: 300, height: 50)
        let field = PCIFieldState(configuration: config)
        field.frame = frame
        return field
    }

    // MARK: - Default Style Tests

    func test_defaultStyle() {
        let sut = self.makeSUT()
        assertSnapshot(of: sut, as: .image)
    }

    func test_defaultStyle_withPlaceholder() {
        let sut = self.makeSUT()
        sut.setPlaceholder("Enter card number")
        assertSnapshot(of: sut, as: .image)
    }

    // MARK: - Custom Style Tests

    func test_customStyle() {
        let style = TextFieldDefaultStyle()
            .backgroundColor(.systemGray6)
            .borderColor(.systemBlue)
            .borderWidth(1)
            .cornerRadius(8)
            .textColor(.systemBlue)
            .backgroundColor(.white)
            .font(.systemFont(ofSize: 18, weight: .medium))

        let sut = self.makeSUT()
        sut.setPlaceholder("Field customized")
        sut.setStyle(style)
        assertSnapshot(of: sut, as: .image)
    }

    func test_disabledState() {
        let style = TextFieldDefaultStyle()
            .backgroundColor(.systemGray5)
            .borderColor(.systemGray3)
            .borderWidth(1)
            .cornerRadius(8)
            .textColor(.systemGray3)
            .opacity(0.7)

        let sut = self.makeSUT()
        sut.setPlaceholder("Disabled field")
        sut.setStyle(style)
        sut.isEnabled = false
        assertSnapshot(of: sut, as: .image)
    }

    // MARK: - Mask Tests

    func test_withCardMask() {
        let mask = PCIFieldState.Configuration.Mask(
            pattern: "#### #### #### ####",
            separator: " "
        )

        let text = "5390287952984029"

        let sut = self.makeSUT(mask: mask)

        self.simulateTyping(sut: sut, text: text)

        assertSnapshot(of: sut, as: .image)
    }

    func test_withExpirationDateMask() {
        let mask = PCIFieldState.Configuration.Mask(
            pattern: "##/##",
            separator: "/"
        )
        let text = "0125"
        let sut = self.makeSUT(mask: mask)

        sut.setPlaceholder("MM/AA")

        self.simulateTyping(sut: sut, text: text)

        assertSnapshot(of: sut, as: .image)
    }

    // MARK: - Side View Tests

    func test_withLeftView() {
        let imageView = UIImageView(image: UIImage(systemName: "creditcard"))
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)

        let sut = self.makeSUT()
        sut.setLeftView(imageView, mode: .always)
        sut.setPlaceholder("With icon on the left")

        assertSnapshot(of: sut, as: .image)
    }

    func test_withRightView() {
        let imageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        imageView.tintColor = .systemGreen
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)

        let sut = self.makeSUT()
        sut.setRightView(imageView, mode: .always)
        sut.setPlaceholder("With icon on the right")

        assertSnapshot(of: sut, as: .image)
    }
}
