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

    init(fields: CardFormFields.Fields) {
        _cardNumber = CardFormValidate(
            wrappedValue: "",
            RequiredRule(fields.cardNumber.validation.errorEmpty),
            CardNumberRule(
                validation: fields.cardNumber.validation,
                min: fields.cardNumber.config.length.min,
                max: fields.cardNumber.config.length.max
            )
        )
        _cardHolder = CardFormValidate(
            wrappedValue: "",
            RequiredRule(fields.cardHolder.validation.errorEmpty),
            CardHolderRule(
                validation: fields.cardHolder.validation,
                maxLength: fields.cardHolder.config.length.max
            )
        )
        _expirationDate = CardFormValidate(
            wrappedValue: "",
            RequiredRule(fields.expiration.validation.errorEmpty),
            ExpirationDateRule(
                validation: fields.expiration.validation,
                length: fields.expiration.config.length.max
            )
        )
        _securityCode = CardFormValidate(
            wrappedValue: "",
            RequiredRule(fields.cvv.validation.errorEmpty),
            SecurityCodeRule(
                validation: fields.cvv.validation,
                length: fields.cvv.config.length.max
            )
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

    mutating func setDocumentType(isNumeric: Bool) {
        _documentHolder.update(.documentType(isNumeric: isNumeric))
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

    var documentHolderLiveErrors: [String] {
        _documentHolder.liveErrorMessages
    }

    func isFormValid(isSecurityCodeMandatory: Bool, isDocumentRequired: Bool = true) -> Bool {
        return _cardNumber.errors.isEmpty
            && _cardNumber.liveErrorMessages.isEmpty
            && _cardHolder.errors.isEmpty
            && _expirationDate.errors.isEmpty
            && (isSecurityCodeMandatory ? _securityCode.errors.isEmpty : true)
            && (isDocumentRequired ? _documentHolder.errors.isEmpty : true)
    }

    // MARK: - Cancelled Form Context

    var cancelledFormContext: MPCardFormUserCancelledContext {
        MPCardFormUserCancelledContext(fields: [
            .init(field: .cardNumber, state: self.cardNumberState()),
            .init(field: .cardHolder, state: self.cardHolderState()),
            .init(field: .expirationDate, state: self.expirationDateState()),
            .init(field: .securityCode, state: self.securityCodeState()),
            .init(field: .document, state: self.documentHolderState())
        ])
    }

    private func cardNumberState() -> MPCardFormUserCancelledContext.FieldState.State {
        guard !_cardNumber.errors.isEmpty else { return .valid }
        let digits = self.cardNumber.filter(\.isNumber)
        if digits.isEmpty { return .empty }
        if let acceptanceError = cardAcceptanceError {
            switch acceptanceError {
            case .paymentMethodNotAllowed:
                return .cardBrandNotAccepted
            case .paymentTypeNotAllowed:
                return .cardTypeNotAccepted
            case .paymentMethodNotFound: return .invalid
            }
        }
        return _cardNumber.errors.contains(where: { $0.type == .incomplete }) ? .incomplete : .invalid
    }

    private func cardHolderState() -> MPCardFormUserCancelledContext.FieldState.State {
        guard !_cardHolder.errors.isEmpty else { return .valid }
        if self.cardHolder.trimmingCharacters(in: .whitespaces).isEmpty { return .empty }
        if _cardHolder.errors.contains(where: { $0.type == .incomplete }) { return .incomplete }
        return .invalid
    }

    private func expirationDateState() -> MPCardFormUserCancelledContext.FieldState.State {
        guard !_expirationDate.errors.isEmpty else { return .valid }
        if self.expirationDate.filter(\.isNumber).isEmpty { return .empty }
        if _expirationDate.errors.contains(where: { $0.type == .incomplete }) { return .incomplete }
        return .invalid
    }

    private func securityCodeState() -> MPCardFormUserCancelledContext.FieldState.State {
        guard !_securityCode.errors.isEmpty else { return .valid }
        if self.securityCode.filter(\.isNumber).isEmpty { return .empty }
        return .incomplete
    }

    private func documentHolderState() -> MPCardFormUserCancelledContext.FieldState.State {
        guard !_documentHolder.errors.isEmpty else { return .valid }
        if self.documentHolder.filter({ $0.isLetter || $0.isNumber }).isEmpty { return .empty }
        if _documentHolder.errors.contains(where: { $0.type == .incomplete }) { return .incomplete }
        return .invalid
    }
}
