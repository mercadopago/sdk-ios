//
//  CardFormData.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 30/01/26.
//
import MPComponents

struct CardFormData {
    @CardFormValidate var cardNumber: String
    @CardFormValidate var cardHolder: String
    @CardFormValidate var expirationDate: String
    @CardFormValidate var securityCode: String
    @CardFormValidate var documentHolder: String

    init(fields: CardFormTexts.Fields) {
        _cardNumber = CardFormValidate(
            wrappedValue: "",
            RequiredRule(fields.cardNumber.validation.errorEmpty),
            CardNumberRule(validation: fields.cardNumber.validation)
        )
        _cardHolder = CardFormValidate(
            wrappedValue: "",
            RequiredRule(fields.cardHolder.validation.errorEmpty),
            CardHolderRule(validation: fields.cardHolder.validation)
        )
        _expirationDate = CardFormValidate(
            wrappedValue: "",
            RequiredRule(fields.expiration.validation.errorEmpty),
            ExpirationDateRule(validation: fields.expiration.validation)
        )
        _securityCode = CardFormValidate(
            wrappedValue: "",
            RequiredRule(fields.cvv.validation.errorEmpty),
            SecurityCodeRule(validation: fields.cvv.validation)
        )
        _documentHolder = CardFormValidate(
            wrappedValue: "",
            RequiredRule(fields.document.validation.errorEmpty),
            DocumentRule(validation: fields.document.validation)
        )
    }

    private var cardAcceptanceError: CardAcceptanceError?

    mutating func setSecurityCodeLength(_ length: Int) {
        _securityCode.update(.securityCodeLength(length))
    }

    mutating func setDocumentLength(_ min: Int, _ max: Int) {
        _documentHolder.update(.documentLength(min: min, max: max))
    }

    mutating func setCardNumberLength(_ minLength: Int = 13, _ maxLength: Int = 16) {
        _cardNumber.update(.cardNumberRange(min: minLength, max: maxLength))
    }

    mutating func cleanSecurityCodeField() {
        self.securityCode = ""
    }

    mutating func setCardNumberExternalError(_ error: CardAcceptanceError?) {
        self.cardAcceptanceError = error
        _cardNumber.update(.cardNumberExternalError(error))
    }

    var cardNumberLiveErrors: [String] {
        _cardNumber.liveErrorMessages
    }

    func isFormValid(isSecurityCodeMandatory: Bool, isDocumentRequired: Bool = true) -> Bool {
        return _cardNumber.errorMessages.isEmpty
            && _cardHolder.errorMessages.isEmpty
            && _expirationDate.errorMessages.isEmpty
            && (isSecurityCodeMandatory ? _securityCode.errorMessages.isEmpty : true)
            && (isDocumentRequired ? _documentHolder.errorMessages.isEmpty : true)
    }

    // MARK: - Cancelled Form Context

    var cancelledFormContext: CardFormUserCancelledContext {
        CardFormUserCancelledContext(fields: [
            .init(field: .cardNumber, state: self.cardNumberState()),
            .init(field: .cardHolder, state: self.cardHolderState()),
            .init(field: .expirationDate, state: self.expirationDateState()),
            .init(field: .securityCode, state: self.securityCodeState()),
            .init(field: .document, state: self.documentHolderState())
        ])
    }

    private func cardNumberState() -> CardFormUserCancelledContext.FieldState.State {
        guard !_cardNumber.errorMessages.isEmpty else { return .valid }
        let digits = self.cardNumber.filter(\.isNumber)
        if digits.isEmpty { return .empty }
        if let acceptanceError = cardAcceptanceError {
            switch acceptanceError {
            case let .paymentMethodNotAllowed(brand): return .cardBrandNotAccepted(brand: brand)
            case let .paymentTypeNotAllowed(cardType): return .cardTypeNotAccepted(cardType: cardType)
            case .paymentMethodNotFound: return .invalid
            }
        }
        return _cardNumber.errorMessages.contains(MPStrings.CardForm.CardNumber.errorIncomplete) ? .incomplete : .invalid
    }

    private func cardHolderState() -> CardFormUserCancelledContext.FieldState.State {
        guard !_cardHolder.errorMessages.isEmpty else { return .valid }
        if self.cardHolder.trimmingCharacters(in: .whitespaces).isEmpty { return .empty }
        if _cardHolder.errorMessages.contains(MPStrings.CardForm.CardHolder.errorIncomplete) { return .incomplete }
        return .invalid
    }

    private func expirationDateState() -> CardFormUserCancelledContext.FieldState.State {
        guard !_expirationDate.errorMessages.isEmpty else { return .valid }
        if self.expirationDate.filter(\.isNumber).isEmpty { return .empty }
        if _expirationDate.errorMessages.contains(MPStrings.CardForm.Expiration.errorIncomplete) { return .incomplete }
        return .invalid
    }

    private func securityCodeState() -> CardFormUserCancelledContext.FieldState.State {
        guard !_securityCode.errorMessages.isEmpty else { return .valid }
        if self.securityCode.filter(\.isNumber).isEmpty { return .empty }
        return .incomplete
    }

    private func documentHolderState() -> CardFormUserCancelledContext.FieldState.State {
        guard !_documentHolder.errorMessages.isEmpty else { return .valid }
        if self.documentHolder.filter(\.isNumber).isEmpty { return .empty }
        if _documentHolder.errorMessages.contains(MPStrings.CardForm.Document.errorIncomplete) { return .incomplete }
        return .invalid
    }
}
