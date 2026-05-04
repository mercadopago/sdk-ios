//
//  MPOptionPickerFallback.swift
//  MPComponents
//

import MPFoundation
import SwiftUI

/// iOS 13–15 fallback for `MPOptionPicker`.
/// - iOS 14–15: `Menu { Picker }` — native context menu
/// - iOS 13: inline `Picker` with fixed size
package struct MPOptionPickerFallback<Option: MPPickerOption>: View {
    let options: [Option]
    @Binding var selected: Option?

    @Environment(\.checkoutTheme) private var theme: MPTheme

    package var body: some View {
        if #available(iOS 14.0, *) {
            menuPicker
        } else {
            self.inlinePicker
        }
    }

    // MARK: - iOS 14–15

    @available(iOS 14.0, *)
    private var menuPicker: some View {
        Menu {
            Picker(selection: self.$selected, label: EmptyView()) {
                ForEach(self.options) { option in
                    Text(option.displayName).tag(Optional(option))
                }
            }
        } label: {
            self.pickerLabel
        }
    }

    // MARK: - iOS 13

    private var inlinePicker: some View {
        Picker(selection: self.$selected, label: self.pickerLabel) {
            ForEach(self.options) { option in
                Text(option.displayName).tag(Optional(option))
            }
        }
        .fixedSize(horizontal: true, vertical: false)
        .accentColor(self.theme.textFields.standard.idle.textColor)
    }

    // MARK: - Shared label

    private var pickerLabel: some View {
        HStack(spacing: 0) {
            Text(self.selected?.displayName ?? "")
                .textStyle(.bodyMedium(colorType: .secondary))
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)

            Image(systemName: "chevron.down")
                .renderingMode(.template)
                .foregroundColor(self.theme.textFields.standard.idle.borderColor)
                .padding(.horizontal, self.theme.spacings.xmicro)
        }
        .padding(.leading, self.theme.spacings.micro)
        .animation(nil)
    }
}
