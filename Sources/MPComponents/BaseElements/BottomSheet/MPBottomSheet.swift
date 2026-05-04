//
//  MPBottomSheet.swift
//  MPComponents
//

import MPFoundation
import SwiftUI

// MARK: - Content

/// Visual container for a bottom sheet: drag indicator + header + scrollable content.
/// Presented via the `.bottomSheet(isPresented:title:)` modifier (iOS 16+).
@available(iOS 16.0, *)
package struct MPBottomSheetContent<Content: View>: View {
    let title: String
    let onDismiss: () -> Void
    @ViewBuilder let content: () -> Content

    @Environment(\.checkoutTheme) private var theme: MPTheme

    package var body: some View {
        VStack(spacing: 0) {
            self.dragIndicator
            self.header
            ScrollView {
                self.content()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(self.theme.colors.background.primary.ignoresSafeArea())
    }

    // MARK: - Subviews

    private var dragIndicator: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: self.theme.borderRadius.full)
                .fill(self.theme.colors.icon.primary)
                .frame(width: 32, height: 4)
        }
        .frame(height: 20)
        .frame(maxWidth: .infinity)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 0) {
            Text(self.title)
                .textStyle(.headingLarge())

            Spacer()

            Button(action: self.onDismiss) {
                Image(systemName: "xmark")
                    .renderingMode(.template)
                    .foregroundColor(self.theme.colors.icon.primary)
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal, self.theme.spacings.micro)
        .padding(.vertical, self.theme.spacings.xmicro)
        .background(self.theme.colors.background.primary)
    }
}

// MARK: - Modifier (iOS 16+)

@available(iOS 16.0, *)
private struct MPBottomSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let height: CGFloat?
    let content: () -> SheetContent

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: self.$isPresented) {
                MPBottomSheetContent(
                    title: self.title,
                    onDismiss: { self.isPresented = false },
                    content: self.content
                )
                .presentationDetents(self.detents)
                .presentationDragIndicator(.hidden)
            }
    }

    private var detents: Set<PresentationDetent> {
        if let height { return [.height(height)] }
        return [.medium, .large]
    }
}

// MARK: - View Extension

package extension View {
    /// Presents an `MPBottomSheet` over the current view (iOS 16+).
    ///
    /// - Parameters:
    ///   - height: Fixed sheet height. When `nil`, the sheet uses `.medium` / `.large` detents.
    @available(iOS 16.0, *)
    func bottomSheet(
        isPresented: Binding<Bool>,
        title: String,
        height: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        modifier(MPBottomSheetModifier(isPresented: isPresented, title: title, height: height, content: content))
    }
}
