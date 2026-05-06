//
//  MPBottomSheet.swift
//  MPComponents
//

import SwiftUI

// MARK: - mpBottomSheet Modifier

/// Turns any view into a tap target that presents a bottom sheet with a selectable list.
///
/// ```swift
/// documentLabel()
///     .mpBottomSheet(
///         title: "Documento do titular",
///         options: viewModel.identificationTypes,
///         selected: $viewModel.selectTypeDocument
///     )
/// ```
private struct MPBottomSheetModifier<Option: MPBottomSheetListOption>: ViewModifier {
    let title: String
    let options: [Option]
    @Binding var selected: Option?
    @State private var isPresented = false

    func body(content: Content) -> some View {
        content
            .overlay(
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { self.isPresented = true }
            )
            .bottomSheet(isPresented: self.$isPresented, title: self.title, height: self.sheetHeight) {
                MPBottomSheetOptionsList(
                    options: self.options,
                    selected: self.$selected,
                    onDismiss: {
                        self.isPresented = false
                    }
                )
            }
    }

    private var sheetHeight: CGFloat {
        let dragIndicator: CGFloat = 20
        let header: CGFloat = 40
        let itemHeight: CGFloat = 52
        let bottomPadding: CGFloat = 60
        let calculated = dragIndicator + header + CGFloat(self.options.count) * itemHeight + bottomPadding
        return min(calculated, UIScreen.main.bounds.height * 0.6)
    }
}

package extension View {
    /// Presents a selectable bottom sheet when this view is tapped (internal state).
    func mpBottomSheet<Option: MPBottomSheetListOption>(
        title: String,
        options: [Option],
        selected: Binding<Option?>
    ) -> some View {
        modifier(MPBottomSheetModifier(title: title, options: options, selected: selected))
    }

    /// Presents a selectable bottom sheet controlled by an external binding.
    /// Apply this to the screen body and control presentation via `isPresented`.
    func mpBottomSheet<Option: MPBottomSheetListOption>(
        isPresented: Binding<Bool>,
        title: String,
        options: [Option],
        selected: Binding<Option?>
    ) -> some View {
        let calculated: CGFloat = 20 + 40 + CGFloat(options.count) * 52 + 60
        let height = min(calculated, UIScreen.main.bounds.height * 0.6)
        return bottomSheet(isPresented: isPresented, title: title, height: height) {
            MPBottomSheetOptionsList(
                options: options,
                selected: selected,
                onDismiss: { isPresented.wrappedValue = false }
            )
        }
    }
}

// MARK: - View Extension

package extension View {
    /// Presents an `MPBottomSheet` edge-to-edge via custom `UIPresentationController`.
    /// Compatible with iOS 13+.
    func bottomSheet(
        isPresented: Binding<Bool>,
        title: String,
        height: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        background(
            MPBottomSheetPresenter(
                isPresented: isPresented,
                title: title,
                height: height,
                content: content
            )
        )
    }
}
