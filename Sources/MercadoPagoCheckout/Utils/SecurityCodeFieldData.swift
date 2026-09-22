///
///  SecurityCodeFieldData.swift
///  MercadoPagoSDK
///
///  Created by Guilherme Prata Costa on 08/07/26.
///
struct SecurityCodeFieldData {
    @CardFormValidate var code: String

    init(field: SecurityCodeScreenOutput.Field, length: Int) {
        _code = CardFormValidate(
            wrappedValue: "",
            RequiredRule(field.error),
            SecurityCodeRule(
                validation: .init(
                    errorEmpty: field.error,
                    errorIncomplete: field.error,
                    errorInvalid: field.error
                ),
                length: length
            )
        )
    }
}
