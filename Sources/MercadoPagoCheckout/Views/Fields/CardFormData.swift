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
    var cardNumber: String = ""

    private var cardNumberApiError = false

    var cardNumberExternalError: String? {
        cardNumberApiError ? MPStrings.CardForm.CardNumber.errorInvalid : nil
    }

    mutating func setCardNumberApiError(_ hasError: Bool) {
        cardNumberApiError = hasError
    }
    
    @CardFormValidate(
        RequiredRule(MPStrings.CardForm.CardHolder.errorEmpty),
        CardHolderRule()
    )
    var cardHolder: String = ""
    
    @CardFormValidate(
        RequiredRule(MPStrings.CardForm.Expiration.errorEmpty),
        ExpirationDateRule()
    )
    var expirationDate: String = ""
    
    @CardFormValidate(
        RequiredRule(MPStrings.CardForm.CVV.errorEmpty),
        SecurityCodeRule()
    )
    var securityCode: String = ""
    
    @CardFormValidate(
        RequiredRule(MPStrings.CardForm.Document.errorEmpty),
        DocumentRule()
    )
    var documentHolder: String = ""
    
    mutating func setSecurityCodeLength(_ length: Int) {
        _securityCode.update(.securityCodeLength(length))
    }

    mutating func setDocumentLength(_ length: Int) {
        _documentHolder.update(.documentLength(length))
    }
    
    var isFormValid: Bool {
        return _cardNumber.errorMessages.isEmpty
        && !cardNumberApiError
        && _cardHolder.errorMessages.isEmpty
        && _expirationDate.errorMessages.isEmpty
        && _securityCode.errorMessages.isEmpty
        && _documentHolder.errorMessages.isEmpty
    }
}
