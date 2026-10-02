//
//  FetchMethodSelectionScreenUseCase.swift
//  MercadoPagoSDK
//

struct FetchMethodSelectionScreenUseCase {
    func execute(item: PaymentInitializationOutput.Item) -> MethodSelectionOutput? {
        item.screen
    }
}
