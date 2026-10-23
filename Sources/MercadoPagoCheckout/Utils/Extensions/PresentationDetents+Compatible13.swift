//
//  PresentationDetents+Compatible13.swift
//  MercadoPagoSDK
//

import SwiftUI

extension View {
    /// Presents the sheet at medium height on iOS 16+; falls back to the full-height sheet on earlier versions.
    func mpMediumPresentationDetent() -> some View {
        modifier(MediumPresentationDetentModifier())
    }
}

private struct MediumPresentationDetentModifier: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.presentationDetents([.medium])
        } else {
            content
        }
    }
}
