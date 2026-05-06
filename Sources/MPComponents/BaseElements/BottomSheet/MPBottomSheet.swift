//
//  MPBottomSheet.swift
//  MPComponents
//

import SwiftUI

// MARK: - MPBottomSheet

/// A bottom sheet component with two presentation modes.
///
/// **Options picker** — built-in trigger and list of selectable items:
/// ```swift
/// MPBottomSheet(
///     title: "Documento do titular",
///     options: viewModel.identificationTypes,
///     selected: $viewModel.selectTypeDocument
/// ) { documentLabel() }
/// ```
///
/// **Custom content** — caller-provided trigger and sheet body:
/// ```swift
/// MPBottomSheet(title: "Filtros") {
///     Image(systemName: "slider.horizontal.3")
/// } content: {
///     FilterView()
/// }
/// ```
package struct MPBottomSheet: View {
    private let title: String
    private let height: CGFloat?
    @State private var isPresented = false

    private let makeTrigger: () -> AnyView
    private let makeContent: (@escaping () -> Void) -> AnyView

    // MARK: - Init: options picker

    package init<Option: MPBottomSheetListOption>(
        title: String,
        options: [Option],
        selected: Binding<Option?>,
        @ViewBuilder label: @escaping () -> some View
    ) {
        self.title = title
        self.height = Self.optionsHeight(count: options.count)
        self.makeTrigger = { AnyView(label()) }
        self.makeContent = { dismiss in
            AnyView(MPBottomSheetOptionsList(options: options, selected: selected, onDismiss: dismiss))
        }
    }

    // MARK: - Init: custom content

    package init(
        title: String,
        height: CGFloat? = nil,
        @ViewBuilder label: @escaping () -> some View,
        @ViewBuilder content: @escaping () -> some View
    ) {
        self.title = title
        self.height = height
        self.makeTrigger = { AnyView(label()) }
        self.makeContent = { _ in AnyView(content()) }
    }

    // MARK: - Body

    package var body: some View {
        Button { self.isPresented = true } label: {
            self.makeTrigger()
        }
        .buttonStyle(.plain)
        .bottomSheet(isPresented: self.$isPresented, title: self.title, height: self.height) {
            self.makeContent { self.isPresented = false }
        }
    }

    // MARK: - Height

    private enum Layout {
        static let dragIndicator: CGFloat = 20
        static let header: CGFloat = 40
        static let itemHeight: CGFloat = 52
        static let bottomPadding: CGFloat = 60
        static let maxHeightRatio: CGFloat = 0.6
    }

    private static func optionsHeight(count: Int) -> CGFloat {
        let calculated = Layout.dragIndicator + Layout.header + CGFloat(count) * Layout.itemHeight + Layout.bottomPadding
        let maxHeight = UIScreen.main.bounds.height * Layout.maxHeightRatio
        return min(calculated, maxHeight)
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
