//
//  MPBottomSheetContent.swift
//  MPComponents
//

import MPFoundation
import SwiftUI

/// Visual container: drag indicator + header + scrollable content.
/// Used internally by `MPBottomSheetPresenter`.
package struct MPBottomSheetContent<Content: View>: View {
    let title: String
    let onDismiss: () -> Void
    @ViewBuilder let content: () -> Content

    @Environment(\.checkoutTheme) private var theme: MPTheme

    package var body: some View {
        VStack(spacing: 0) {
            self.dragIndicator
            self.header
            ScrollView { self.content() }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(self.theme.colors.background.primary.edgesIgnoringSafeArea(.all))
    }

    private var dragIndicator: some View {
        RoundedRectangle(cornerRadius: self.theme.borderRadius.full)
            .fill(self.theme.colors.interactive.iconIdle)
            .frame(width: 32, height: 4)
            .frame(height: 20)
            .frame(maxWidth: .infinity)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 0) {
            Text(self.title).textStyle(.headingMedium())
            Spacer()
            Button(action: self.onDismiss) {
                Image(Logos.close, bundle: .bundleMP)
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
