//
//  EmailViewModelTests.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 02/06/26.
//

@testable import MercadoPagoCheckout
import XCTest

@MainActor
final class EmailViewModelTests: XCTestCase {
    // MARK: - Pre-fill

    func test_init_shouldPrefillEmailFromConfiguration() {
        // Arrange / Act
        let sut = self.makeSUT(email: "maria@mail.com")

        // Assert
        XCTAssertEqual(sut.email, "maria@mail.com")
    }

    func test_initResult_shouldExposeReceivedTextData() {
        // Arrange / Act
        let sut = self.makeSUT()

        // Assert
        XCTAssertEqual(sut.initResult.title, "Completá el e-mail")
        XCTAssertEqual(sut.initResult.button, "Continuar")
        XCTAssertEqual(sut.initResult.label, "E-mail")
        XCTAssertEqual(sut.initResult.placeholder, "Ejemplo: juan.perez@gmail.com")
    }

    // MARK: - isEmailValid

    func test_isEmailValid_withWellFormedEmail_shouldReturnTrue() {
        // Arrange
        let sut = self.makeSUT(email: "juan.perez@gmail.com")

        // Act / Assert
        XCTAssertTrue(sut.isEmailValid)
    }

    func test_isEmailValid_withEmptyEmail_shouldReturnFalse() {
        // Arrange
        let sut = self.makeSUT(email: "")

        // Act / Assert
        XCTAssertFalse(sut.isEmailValid)
    }

    func test_isEmailValid_withMissingDomain_shouldReturnFalse() {
        // Arrange
        let sut = self.makeSUT(email: "juan.perez@")

        // Act / Assert
        XCTAssertFalse(sut.isEmailValid)
    }

    func test_isEmailValid_withMissingAt_shouldReturnFalse() {
        // Arrange
        let sut = self.makeSUT(email: "juan.perez.gmail.com")

        // Act / Assert
        XCTAssertFalse(sut.isEmailValid)
    }

    func test_isEmailValid_withMissingTLD_shouldReturnFalse() {
        // Arrange
        let sut = self.makeSUT(email: "juan@gmail")

        // Act / Assert
        XCTAssertFalse(sut.isEmailValid)
    }

    // MARK: - emailErrors

    func test_emailErrors_whenEmpty_shouldReturnEmptyError() {
        // Arrange
        let sut = self.makeSUT(email: "")

        // Act
        let result = sut.emailErrors()

        // Assert
        XCTAssertEqual(result, ["Completá este campo."])
    }

    func test_emailErrors_whenInvalid_shouldReturnInvalidError() {
        // Arrange
        let sut = self.makeSUT(email: "not-an-email")

        // Act
        let result = sut.emailErrors()

        // Assert
        XCTAssertEqual(result, ["Ingresá un e-mail válido."])
    }

    func test_emailErrors_whenValid_shouldReturnNoErrors() {
        // Arrange
        let sut = self.makeSUT(email: "juan.perez@gmail.com")

        // Act
        let result = sut.emailErrors()

        // Assert
        XCTAssertEqual(result, [])
    }

    func test_emailErrors_afterEditingToValid_shouldClearError() {
        // Arrange -- starts empty (error), then user types a valid e-mail
        let sut = self.makeSUT(email: "")
        XCTAssertEqual(sut.emailErrors(), ["Completá este campo."])

        // Act
        sut.email = "juan.perez@gmail.com"

        // Assert
        XCTAssertEqual(sut.emailErrors(), [])
        XCTAssertTrue(sut.isEmailValid)
    }

    // MARK: - Helpers

    private func makeSUT(email: String = "") -> EmailViewModel {
        EmailViewModel(
            config: .init(
                initResult: EmailInitializationOutput(
                    title: "Completá el e-mail",
                    button: "Continuar",
                    label: "E-mail",
                    email: email,
                    placeholder: "Ejemplo: juan.perez@gmail.com",
                    errorEmpty: "Completá este campo.",
                    errorInvalid: "Ingresá un e-mail válido."
                )
            )
        )
    }
}
