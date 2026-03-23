//
//  Focused+Compatible13.swift
//  MercadoPagoSDK
//
//  Created by MercadoPago on 23/03/26.
//

import SwiftUI

extension View {
    /// Backwards-compatible version of `.focused(_:)`.
    /// - iOS 15+: bridges to SwiftUI's native `@FocusState` / `.focused()`.
    /// - iOS 13–14: finds the nearest `UITextField` in the UIKit hierarchy and calls `becomeFirstResponder()`.
    func mpFocused(_ isFocused: Binding<Bool>) -> some View {
        modifier(FocusedModifier(isFocused: isFocused))
    }
}

// MARK: - ViewModifier

private struct FocusedModifier: ViewModifier {
    @Binding var isFocused: Bool

    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            FocusedWrappedView(isFocused: self.$isFocused, content: content)
        } else {
            content.background(FocusHelperRepresentable(isFocused: self.$isFocused))
        }
    }
}

// MARK: - iOS 15+ wrapper

@available(iOS 15.0, *)
private struct FocusedWrappedView<Content: View>: View {
    @Binding var isFocused: Bool
    @FocusState private var internalFocus: Bool
    let content: Content

    var body: some View {
        self.content
            .focused(self.$internalFocus)
            .onChange(of: self.isFocused) { newValue in self.internalFocus = newValue }
            .onChange(of: self.internalFocus) { newValue in self.isFocused = newValue }
    }
}

// MARK: - iOS 13/14 UIKit fallback

private struct FocusHelperRepresentable: UIViewRepresentable {
    @Binding var isFocused: Bool

    func makeUIView(context _: Context) -> UIView {
        let view = UIView()
        view.isHidden = true
        return view
    }

    func updateUIView(_ uiView: UIView, context _: Context) {
        guard self.isFocused else { return }
        DispatchQueue.main.async {
            guard let parent = uiView.superview else { return }
            Self.findTextField(in: parent)?.becomeFirstResponder()
        }
    }

    /// Depth-first search for the first `UITextField` within the given view's subtree.
    private static func findTextField(in view: UIView) -> UITextField? {
        if let textField = view as? UITextField { return textField }
        for subview in view.subviews {
            if let found = findTextField(in: subview) { return found }
        }
        return nil
    }
}
