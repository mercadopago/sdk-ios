//
//  SecurityCodeViewModelTests.swift
//  MercadoPagoSDK
//

import CommonTests
@testable import CoreMethods
@testable import MercadoPagoCheckout
@testable import MPComponents
import XCTest

@MainActor
final class SecurityCodeViewModelTests: XCTestCase {
    // MARK: - Computed properties

    func test_cardTitle_shouldExposeItemTitle() {
        // Arrange / Act
        let sut = self.makeSUT(itemTitle: "Mastercard •••• 6351")

        // Assert
        XCTAssertEqual(sut.cardTitle, "Mastercard •••• 6351")
    }

    func test_amount_shouldExposeTransactionAmountAsMPAmountData() {
        // Arrange / Act
        let sut = self.makeSUT(transactionAmount: 100)

        // Assert
        XCTAssertEqual(sut.amount, MPAmountData(from: Decimal(100)))
    }

    func test_screenOutput_shouldExposeConfigurationScreenOutput() {
        // Arrange
        let screenOutput = self.makeScreenOutput(length: 4)

        // Act
        let sut = self.makeSUT(screenOutput: screenOutput)

        // Assert
        XCTAssertEqual(sut.screenOutput, screenOutput)
    }

    // MARK: - submit(code:)

    func test_submit_whenSuccessful_returnsToken() async throws {
        // Arrange
        let service = MockCheckoutService()
        await service.setCreateCardTokenResult(.success(self.makeCardToken(token: "TOKEN-123")))
        let sut = self.makeSUT(service: service)

        // Act
        let token = try await sut.submit(code: "123")

        // Assert
        XCTAssertEqual(token, "TOKEN-123")
    }

    func test_submit_usesItemIdAsCardId() async throws {
        // Arrange
        let service = MockCheckoutService()
        await service.setCreateCardTokenResult(.success(self.makeCardToken(token: "TOKEN-123")))
        let sut = self.makeSUT(itemId: "card-9999", service: service)

        // Act
        _ = try await sut.submit(code: "123")

        // Assert
        let capturedCardId = await service.capturedCardParams?.cardId
        XCTAssertEqual(capturedCardId, "card-9999")
    }

    func test_submit_usesScreenOutputLengthAsExpectedLength() async {
        // Arrange -- expectedLength (4) mismatches the submitted code length (3)
        let service = MockCheckoutService()
        let sut = self.makeSUT(screenOutput: self.makeScreenOutput(length: 4), service: service)

        // Act & Assert
        do {
            _ = try await sut.submit(code: "123")
            XCTFail("Expected throw for mismatched length")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func test_submit_togglesIsTokenizing() async throws {
        // Arrange
        let service = MockCheckoutService()
        await service.setCreateCardTokenResult(.success(self.makeCardToken(token: "TOKEN-123")))
        let sut = self.makeSUT(service: service)
        XCTAssertFalse(sut.isTokenizing)

        // Act
        _ = try await sut.submit(code: "123")

        // Assert -- reverted to false after completion
        XCTAssertFalse(sut.isTokenizing)
    }

    func test_submit_whenServiceThrows_propagatesError() async {
        // Arrange
        let service = MockCheckoutService()
        await service.setCreateCardTokenResult(
            .failure(MercadoPagoCheckoutError(code: .serviceError, localizedDescription: "failed", location: .tokenization))
        )
        let sut = self.makeSUT(service: service)

        // Act & Assert
        do {
            _ = try await sut.submit(code: "123")
            XCTFail("Expected throw")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    // MARK: - trackInitialize

    func test_trackInitialize_withCardData_shouldTrackInitializePath() async {
        // Arrange
        let analytics = MockAnalytics()
        let sut = self.makeSUT(cardData: self.makeCardData(), analytics: analytics)

        // Act
        sut.trackInitialize()
        await analytics.mock.waitForSend()

        // Assert
        let messages = await analytics.mock.getMessages()
        XCTAssertTrue(messages.contains(.trackView(SecurityCodeAnalyticsPath.initialize)))
        XCTAssertTrue(messages.contains(.send))
    }

    func test_trackInitialize_withCardData_shouldSendPaymentMethodTypeIssuerAndCardId() async {
        // Arrange
        let analytics = MockAnalytics()
        let sut = self.makeSUT(
            itemId: "card-9999",
            cardData: self.makeCardData(paymentMethodId: "master", paymentTypeId: "credit_card", issuerId: 2),
            analytics: analytics
        )

        // Act
        sut.trackInitialize()
        await analytics.mock.waitForSend()

        // Assert
        let messages = await analytics.mock.getMessages()
        XCTAssertTrue(messages.contains(.setEventData([
            "payment_method_id": "master",
            "payment_type_id": "credit_card",
            "issuer_id": 2,
            "card_id": "card-9999"
        ])))
    }

    func test_trackInitialize_withoutCardData_shouldNotTrack() async {
        // Arrange
        let analytics = MockAnalytics()
        let sut = self.makeSUT(cardData: nil, analytics: analytics)

        // Act
        sut.trackInitialize()

        // Assert -- nothing was ever tracked, so waiting for a send would hang; assert synchronously instead.
        let messages = await analytics.mock.getMessages()
        XCTAssertTrue(messages.isEmpty)
    }

    // MARK: - trackSubmit (via submit(code:))

    func test_submit_whenSuccessful_shouldTrackSubmitPath() async throws {
        // Arrange
        let analytics = MockAnalytics()
        let service = MockCheckoutService()
        await service.setCreateCardTokenResult(.success(self.makeCardToken(token: "TOKEN-123")))
        let sut = self.makeSUT(service: service, analytics: analytics)

        // Act
        _ = try await sut.submit(code: "123")
        await analytics.mock.waitForSend()

        // Assert
        let messages = await analytics.mock.getMessages()
        XCTAssertTrue(messages.contains(.track(path: SecurityCodeAnalyticsPath.submit)))
        XCTAssertTrue(messages.contains(.send))
    }

    // MARK: - trackSubmitError (via submit(code:))

    func test_submit_whenServiceThrows_shouldTrackSubmitErrorPath() async {
        // Arrange
        let analytics = MockAnalytics()
        let service = MockCheckoutService()
        await service.setCreateCardTokenResult(
            .failure(MercadoPagoCheckoutError(code: .serviceError, localizedDescription: "failed", location: .tokenization))
        )
        let sut = self.makeSUT(service: service, analytics: analytics)

        // Act
        do {
            _ = try await sut.submit(code: "123")
            XCTFail("Expected throw")
        } catch {
            // no-op -- asserted via analytics below
        }
        await analytics.mock.waitForSend()

        // Assert
        let messages = await analytics.mock.getMessages()
        XCTAssertTrue(messages.contains(.track(path: SecurityCodeAnalyticsPath.submitError)))
        XCTAssertTrue(messages.contains(.send))
    }

    // MARK: - trackCanceledError (via goBack())

    func test_goBack_shouldTrackUserCanceledErrorPath() async {
        // Arrange
        let analytics = MockAnalytics()
        let sut = self.makeSUT(analytics: analytics)

        // Act
        sut.goBack()
        await analytics.mock.waitForSend()

        // Assert
        let messages = await analytics.mock.getMessages()
        XCTAssertTrue(messages.contains(.track(path: SecurityCodeAnalyticsPath.userCanceledError)))
        XCTAssertTrue(messages.contains(.setError("back_pressed")))
        XCTAssertTrue(messages.contains(.send))
    }

    // MARK: - Helpers

    private func makeSUT(
        itemId: String = "card-9999",
        itemTitle: String = "Mastercard •••• 6351",
        cardData: PaymentInitializationOutput.Item.CardData? = nil,
        screenOutput: SecurityCodeScreenOutput? = nil,
        transactionAmount: Decimal = 100,
        service: MockCheckoutService = MockCheckoutService(),
        analytics: MockAnalytics = MockAnalytics()
    ) -> SecurityCodeViewModel {
        SecurityCodeViewModel(
            config: .init(
                screenOutput: screenOutput ?? self.makeScreenOutput(),
                item: .init(
                    id: itemId,
                    title: itemTitle,
                    description: "Master Crédito",
                    icon: .system("creditcard"),
                    route: "saved_card",
                    cardData: cardData
                ),
                transactionAmount: transactionAmount
            ),
            securityCodeUseCase: SecurityCodeUseCase(service: service),
            analytics: analytics
        )
    }

    private func makeCardData(
        paymentMethodId: String = "master",
        paymentTypeId: String = "credit_card",
        issuerId: Int = 2
    ) -> PaymentInitializationOutput.Item.CardData {
        .init(
            paymentMethodId: paymentMethodId,
            paymentTypeId: paymentTypeId,
            issuerId: issuerId,
            securityCodeScreen: nil
        )
    }

    private func makeScreenOutput(length: Int = 3) -> SecurityCodeScreenOutput {
        SecurityCodeScreenOutput(
            length: length,
            headerTitle: "Completá el código de seguridad",
            field: .init(
                label: "Código de seguridad",
                placeholder: "Ej.: 123",
                helper: "Está en el reverso de tu tarjeta.",
                error: "Completá este campo."
            ),
            buttonLabel: "Continuar"
        )
    }

    private func makeCardToken(token: String) -> CardToken {
        CardToken(
            token: token,
            publicKey: nil,
            bin: nil,
            expirationMonth: nil,
            expirationYear: nil,
            lastFourDigits: nil,
            cardHolder: nil,
            status: nil,
            dateCreated: nil,
            dateLastUpdated: nil,
            dateDue: nil,
            luhnValidation: nil,
            liveMode: nil,
            requireEsc: nil,
            cardNumberLength: nil,
            securityCodeLength: nil,
            truncCardNumber: nil
        )
    }
}
