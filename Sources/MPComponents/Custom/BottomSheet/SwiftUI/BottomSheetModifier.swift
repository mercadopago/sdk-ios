//
//  BottomSheetModifier.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 11/09/25.
//
import SwiftUI

struct BottomSheetModifier<Screen: View>: ViewModifier {
    @Binding var isPresented: Bool
    let screen: () -> Screen
    
    var configurationBottomSheet: BottomSheet.Configuration = {
        var config = BottomSheet.Configuration.default
        config.contentPresentationMode = .singleView
        return config
    }()
    
    init(isPresented: Binding<Bool>, @ViewBuilder screen: @escaping () -> Screen) {
        self._isPresented = isPresented
        self.screen = screen
    }

    func body(content: Content) -> some View {
        content.background(
            BottomSheetPresenter(
                isPresented: $isPresented,
                contentView: self.screen,
                bottomSheetConfiguration: self.configurationBottomSheet
            )
        )
    }
}

extension View {
    public func bottomSheet<Screen: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Screen
    ) -> some View {
        self.modifier(
            BottomSheetModifier(
                isPresented: isPresented,
                screen: content
            )
        )
    }
}
