//
//  MPOptionPickerBottomSheet.swift
//  MPComponents
//

import MPFoundation
import SwiftUI

/// iOS 16+ presentation of `MPOptionPicker` — bottom sheet with `MPListItem` pick style.
@available(iOS 16.0, *)
package struct MPOptionPickerBottomSheet<Option: MPPickerOption>: View {
    let title: String
    let options: [Option]
    @Binding var selected: Option?
    @State private var isPresented = false

    @Environment(\.checkoutTheme) private var theme: MPTheme

    package var body: some View {
        self.triggerButton
            .bottomSheet(isPresented: self.$isPresented, title: self.title, height: self.sheetHeight) {
                self.optionsList
                    .padding(.horizontal, self.theme.spacings.xnano)
                    .padding(.bottom, self.theme.spacings.micro)
            }
    }

    /// Pre-calculated height so the sheet fits its content exactly without resizing.
    ///
    /// Breakdown (theme values: xtiny=16, xmicro=8, micro=12):
    ///   drag indicator = 20, header = 40, each item = 52, bottom (padding + safe area) = 46
    private var sheetHeight: CGFloat {
        let dragIndicator: CGFloat = 20
        let header: CGFloat = 40
        let itemHeight: CGFloat = 52
        let bottomPadding: CGFloat = 46
        return dragIndicator + header + CGFloat(self.options.count) * itemHeight + bottomPadding
    }

    // MARK: - Trigger

    private var triggerButton: some View {
        Button {
            self.isPresented = true
        } label: {
            self.pickerLabel
        }
    }

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

    // MARK: - List

    private var optionsList: some View {
        VStack(spacing: 0) {
            ForEach(self.options) { option in
                MPListItem(
                    isSelected: Binding(
                        get: { self.selected?.id == option.id },
                        set: { isSelected in
                            if isSelected {
                                self.selected = option
                                self.isPresented = false
                            }
                        }
                    ),
                    contentInfo: MPListItemContentInfo(title: option.displayName)
                )
            }
        }
        .listItemStyle(.pick)
    }
}
