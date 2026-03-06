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

    mutating func setSecurityCodeLength(_ length: Int) {
        _securityCode.update(.securityCodeLength(length))
    }

    mutating func setDocumentLength(_ min: Int, _ max: Int) {
        _documentHolder.update(.documentLength(min: min, max: max))
    }

    mutating func setCardNumberLength(_ minLength: Int = 13, _ maxLength: Int = 19) {
        _cardNumber.update(.cardNumberRange(min: minLength, max: maxLength))
    }

    mutating func setCardNumberExternalError(_ error: BinFetchError?) {
        _cardNumber.update(.cardNumberExternalError(error))
    }

    var cardNumberLiveErrors: [String] {
        _cardNumber.liveErrorMessages
    }

    func isFormValid(isSecurityCodeOptional: Bool) -> Bool {
        return _cardNumber.errorMessages.isEmpty
            && _cardHolder.errorMessages.isEmpty
            && _expirationDate.errorMessages.isEmpty
            && (isSecurityCodeOptional || _securityCode.errorMessages.isEmpty)
            && _documentHolder.errorMessages.isEmpty
    }
}
