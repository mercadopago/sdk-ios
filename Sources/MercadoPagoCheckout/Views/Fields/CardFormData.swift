//
//  CardFormData.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 30/01/26.
//
import MPComponents

struct CardFormData {
    @CardFormValidate(
        RequiredRule(MPStrings.CardForm.CardNumber.errorEmpty),
        CardNumberRule()
    )
    var cardNumber = ""

    @CardFormValidate(
        RequiredRule(MPStrings.CardForm.CardHolder.errorEmpty),
        CardHolderRule()
    )
    var cardHolder = ""

    @CardFormValidate(
        RequiredRule(MPStrings.CardForm.Expiration.errorEmpty),
        ExpirationDateRule()
    )
    var expirationDate = ""

    @CardFormValidate(
        RequiredRule(MPStrings.CardForm.CVV.errorEmpty),
        SecurityCodeRule()
    )
    var securityCode = ""

    @CardFormValidate(
        RequiredRule(MPStrings.CardForm.Document.errorEmpty),
        DocumentRule()
    )
    var documentHolder = ""

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

    func isFormValid(isSecurityCodeMandatory: Bool) -> Bool {
        return _cardNumber.errorMessages.isEmpty
            && _cardHolder.errorMessages.isEmpty
            && _expirationDate.errorMessages.isEmpty
            && (isSecurityCodeMandatory ? _securityCode.errorMessages.isEmpty : true)
            && _documentHolder.errorMessages.isEmpty
    }

    // MARK: - Cancelled Form Context

    var cancelledFormContext: MPCancelledFormContext {
        var errors: [MPCancelledFormContext.FieldError] = []
        if let reason = cardNumberReason() { errors.append(.init(field: .cardNumber, reason: reason)) }
        if let reason = cardHolderReason() { errors.append(.init(field: .cardHolder, reason: reason)) }
        if let reason = expirationDateReason() { errors.append(.init(field: .expirationDate, reason: reason)) }
        if let reason = securityCodeReason() { errors.append(.init(field: .securityCode, reason: reason)) }
        if let reason = documentHolderReason() { errors.append(.init(field: .document, reason: reason)) }
        return MPCancelledFormContext(fieldErrors: errors)
    }

    private func cardNumberReason() -> MPCancelledFormContext.FieldError.Reason? {
        guard !_cardNumber.errorMessages.isEmpty else { return nil }
        let digits = self.cardNumber.filter(\.isNumber)
        if digits.isEmpty { return .empty }
        if let acceptanceError = cardAcceptanceError {
            switch acceptanceError {
            case let .paymentMethodNotAllowed(brand): return .cardBrandNotAccepted(brand: brand)
            case let .paymentTypeNotAllowed(cardType): return .cardTypeNotAccepted(cardType: cardType)
            }
        }
        return _cardNumber.errorMessages.contains(MPStrings.CardForm.CardNumber.errorIncomplete) ? .incomplete : .invalid
    }

    private func cardHolderReason() -> MPCancelledFormContext.FieldError.Reason? {
        guard !_cardHolder.errorMessages.isEmpty else { return nil }
        if self.cardHolder.trimmingCharacters(in: .whitespaces).isEmpty { return .empty }
        if _cardHolder.errorMessages.contains(MPStrings.CardForm.CardHolder.errorIncomplete) { return .incomplete }
        return .invalid
    }

    private func expirationDateReason() -> MPCancelledFormContext.FieldError.Reason? {
        guard !_expirationDate.errorMessages.isEmpty else { return nil }
        if self.expirationDate.filter(\.isNumber).isEmpty { return .empty }
        if _expirationDate.errorMessages.contains(MPStrings.CardForm.Expiration.errorIncomplete) { return .incomplete }
        return .invalid
    }

    private func securityCodeReason() -> MPCancelledFormContext.FieldError.Reason? {
        guard !_securityCode.errorMessages.isEmpty else { return nil }
        if self.securityCode.filter(\.isNumber).isEmpty { return .empty }
        return .incomplete
    }

    private func documentHolderReason() -> MPCancelledFormContext.FieldError.Reason? {
        guard !_documentHolder.errorMessages.isEmpty else { return nil }
        if self.documentHolder.filter(\.isNumber).isEmpty { return .empty }
        if _documentHolder.errorMessages.contains(MPStrings.CardForm.Document.errorIncomplete) { return .incomplete }
        return .invalid
    }
}
