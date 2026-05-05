//
//  MPBottomSheetOptionsList.swift
//  MPComponents
//

import MPFoundation
import SwiftUI

struct MPBottomSheetOptionsList<Option: MPBottomSheetListOption>: View {
    let options: [Option]
    @Binding var selected: Option?
    let onDismiss: () -> Void
    @Environment(\.checkoutTheme) private var theme: MPTheme

    var body: some View {
        VStack(spacing: 0) {
            ForEach(self.options) { option in
                MPListItem(
                    isSelected: Binding(
                        get: { self.selected?.id == option.id },
                        set: {
                            if $0 {
                                self.selected = option
                                self.onDismiss()
                            }
                        }
                    ),
                    contentInfo: MPListItemContentInfo(title: option.displayName)
                )
            }
        }
        .listItemStyle(.pick)
        .padding(.horizontal, self.theme.spacings.xnano)
        .padding(.bottom, self.theme.spacings.micro)
    }
}
