//
//  MPOptionPicker.swift
//  MPComponents
//

import SwiftUI

/// Generic single-selection picker that adapts its presentation to the iOS version.
///
/// - iOS 16+: presents a bottom sheet with `MPListItem` list (pick style)
/// - iOS 13–15: presents a native `Menu/Picker` inline
///
/// ## Usage
/// ```swift
/// MPOptionPicker(
///     title: "Documento do titular",
///     options: viewModel.identificationTypes,
///     selected: $viewModel.selectTypeDocument
/// )
/// ```
package struct MPOptionPicker<Option: MPPickerOption>: View {
    let title: String
    let options: [Option]
    @Binding var selected: Option?

    package init(title: String, options: [Option], selected: Binding<Option?>) {
        self.title = title
        self.options = options
        self._selected = selected
    }

    package var body: some View {
        if #available(iOS 16.0, *) {
            MPOptionPickerBottomSheet(title: title, options: options, selected: $selected)
        } else {
            MPOptionPickerFallback(options: self.options, selected: self.$selected)
        }
    }
}
