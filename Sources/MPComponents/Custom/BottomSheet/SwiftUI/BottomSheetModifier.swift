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
    /// Presents a bottom sheet with custom content when a binding to a Boolean value is true.
    ///
    /// Use this modifier to present a modal view that rises from the bottom of the screen.
    /// The bottom sheet supports internal navigation when paired with a `BottomSheet.Router`
    /// available in the environment.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// struct ExampleView: View {
    ///     @State private var isPresented: Bool = false
    ///     @EnvironmentObject var router: BottomSheet.Router
    ///
    ///     var body: some View {
    ///         VStack {
    ///             Button("Show Bottom Sheet") {
    ///                 isPresented = true
    ///             }
    ///         }
    ///         .bottomSheet($isPresented) {
    ///             VStack(spacing: 20) {
    ///                 Text("Initial Page")
    ///
    ///                 Button("Navigate") {
    ///                     router.push {
    ///                         Text("Next Page")
    ///                     }
    ///                 }
    ///             }
    ///             .padding()
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - isPresented: A binding to a Boolean value that determines whether
    ///     to present the bottom sheet.
    ///   - content: A view builder that creates the content to display
    ///     inside the bottom sheet.
    package func bottomSheet<Screen: View>(
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
