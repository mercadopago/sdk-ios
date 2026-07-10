//
//  SecurityCodeScreenOutput.swift
//  MercadoPagoSDK
//

struct SecurityCodeScreenOutput: Equatable {
    let length: Int
    let headerTitle: String
    let field: Field
    let buttonLabel: String

    struct Field: Equatable {
        let label: String
        let placeholder: String
        let helper: String
        let error: String
    }
}
