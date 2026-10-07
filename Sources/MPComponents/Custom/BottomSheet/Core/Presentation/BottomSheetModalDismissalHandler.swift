//
//  BottomSheetModalDismissalHandler.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 11/09/25.
//

protocol BottomSheetModalDismissalHandler {
    var canBeDismissed: Bool { get }

    func performDismissal(animated: Bool)

    func didEndDismissal()
}
