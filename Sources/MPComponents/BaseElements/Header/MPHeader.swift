//
//  MPHeader.swift
//  MPComponents
//
//  A collapsible header component with navigation and scroll animations.
//

import SwiftUI
import UIKit
import MPFoundation

/// A collapsible header component that automatically handles back navigation and scroll animations.
///
/// The header consists of two parts:
/// - **Main Header**: A fixed top bar with back button, title (appears when collapsed), and trailing actions
/// - **Sub Header**: A large title that collapses as the user scrolls
///
/// ## Usage
///
/// ```swift
/// MPHeader(
///     title: "Product Details",
///     onBack: { dismiss() },
///     trailingActions: {
///         Button(action: {}) {
///             Image(systemName: "heart")
///         }
///     }
/// ) {
///     // Your scrollable content here
///     VStack {
///         ForEach(items) { item in
///             ItemView(item: item)
///         }
///     }
/// }
/// ```
///
package struct MPHeader<Content: View, TrailingActions: View, Footer: View>: View {

    // MARK: - Properties

    private let title: String
    private let onBack: () -> Void
    private let trailingActions: TrailingActions
    private let content: Content
    private let footer: Footer

    // MARK: - Environment

    @Environment(\.mpHeaderStyle) private var style: any MPHeaderStyle
    @Environment(\.checkoutTheme) var theme: MPTheme

    // MARK: - State

    @State private var scrollOffset: CGFloat = 0
    @State private var headerHeight: CGFloat = 30
    @State private var subHeaderHeight: CGFloat = 20
    @State private var contentHeight: CGFloat = 0
    @State private var footerHeight: CGFloat = 0

    // MARK: - Computed

    /// True when content + footer exceeds the screen height.
    /// contentHeight is measured from ScrollViewWithOffset and includes the header spacer inset.
    private var isScrollable: Bool {
        contentHeight + footerHeight > UIScreen.main.bounds.height
    }

    // MARK: - Initialization

    /// Creates a new header with the specified configuration.
    ///
    /// - Parameters:
    ///   - title: The title to display in both the main header and sub-header
    ///   - onBack: Action to perform when the back button is tapped
    ///   - trailingActions: Optional views to display on the trailing edge
    ///   - content: The scrollable content to display below the header
    package init(
        title: String,
        onBack: @escaping () -> Void = {},
        @ViewBuilder trailingActions: () -> TrailingActions = { EmptyView() },
        @ViewBuilder footer: () -> Footer = { EmptyView() },
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.onBack = onBack
        self.trailingActions = trailingActions()
        self.footer = footer()
        self.content = content()
    }

    // MARK: - Body

    package var body: some View {
        GeometryReader { _ in

            ZStack(alignment: .top) {
                // Scrollable content with offset tracking

                VStack(spacing: 0) {
                    ScrollViewWithOffset(offset: $scrollOffset, contentHeight: $contentHeight) {
                        VStack(spacing: 0) {
                            Color.clear
                                .frame(height: headerInset())
                                .padding(.bottom, theme.spacings.xsmall)

                            content
                        }
                    }

                    footer
                        .background(
                            GeometryReader { geo in
                                Color.clear.preference(
                                    key: FooterHeightKey.self,
                                    value: geo.size.height
                                )
                            }
                        )
                        .environment(\.mpHeaderIsScrollable, isScrollable)
                        .zIndex(2)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Header container
                headerContent
                    .frame(maxWidth: .infinity, alignment: .top)
                    .zIndex(1)
            }
            .onPreferenceChange(MainHeaderHeightKey.self) { headerHeight = $0 }
            .onPreferenceChange(SubHeaderHeightKey.self) { subHeaderHeight = $0 }
            .onPreferenceChange(FooterHeightKey.self) { footerHeight = $0 }
        }
        .navigationBarHidden(true)

    }

    // MARK: - Header Content

    private var headerContent: some View {
        let configuration = MPHeaderStyleConfiguration(
            title: title,
            onBack: onBack,
            trailingActions: trailingActionsConfiguration,
            collapseProgress: collapseProgress,
            subHeaderHeight: subHeaderHeight,
            subHeaderVisibleHeight: subHeaderVisibleHeight,
            scrollOffset: scrollOffset
        )

        return AnyView(
            style.resolve(configuration: configuration)
        )
    }

    // MARK: - Computed Properties

    /// Progress of the collapse animation (0 = fully expanded, 1 = fully collapsed)
    private var collapseProgress: CGFloat {
        guard subHeaderHeight > 0 else { return 0 }
        return max(0, min((0 - scrollOffset) / subHeaderHeight, 1))
    }

    /// Visible height of the sub-header (decreases as user scrolls)
    private var subHeaderVisibleHeight: CGFloat {
        subHeaderHeight * (1 - collapseProgress)
    }

    private func headerInset() -> CGFloat {
        let totalInset = headerHeight + subHeaderVisibleHeight
        return max(totalInset, 40)
    }

    private var trailingActionsConfiguration: MPHeaderStyleConfiguration.TrailingActions? {
        guard TrailingActions.self != EmptyView.self else { return nil }
        return MPHeaderStyleConfiguration.TrailingActions(body: AnyView(trailingActions))
    }
}

// MARK: - Convenience Initializers
extension MPHeader where TrailingActions == EmptyView {
    /// Creates a header without trailing actions
    package init(
        title: String,
        onBack: @escaping () -> Void = {},
        @ViewBuilder content: () -> Content,
        @ViewBuilder footer: () -> Footer
    ) {
        self.init(
            title: title,
            onBack: onBack,
            trailingActions: { EmptyView() },
            footer: footer,
            content: content
        )
    }
}

// MARK: - ScrollView with Offset Tracking
private struct ScrollViewWithOffset<Content: View>: View {
    @Binding var offset: CGFloat
    @Binding var contentHeight: CGFloat
    let content: Content

    init(offset: Binding<CGFloat>, contentHeight: Binding<CGFloat>, @ViewBuilder content: () -> Content) {
        self._offset = offset
        self._contentHeight = contentHeight
        self.content = content()
    }

    var body: some View {
        ScrollView {
            content
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .preference(
                                key: ScrollOffsetKey.self,
                                value: geo.frame(in: .named("MPScroll")).origin
                            )
                    }
                )
                .background(ScrollContentSizeReader(contentHeight: $contentHeight))
        }
        .coordinateSpace(name: "MPScroll")
        .onPreferenceChange(ScrollOffsetKey.self) { value in
            self.offset = value.y
        }
    }
}

// MARK: - UIScrollView Content Size Reader

private struct ScrollContentSizeReader: UIViewRepresentable {
    @Binding var contentHeight: CGFloat

    func makeUIView(context: Context) -> InnerView {
        let view = InnerView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        return view
    }

    func updateUIView(_ uiView: InnerView, context: Context) {
        uiView.onHeightChange = { height in
            if height > 0, abs(height - contentHeight) > 0.5 {
                contentHeight = height
            }
        }
    }

    final class InnerView: UIView {
        var onHeightChange: ((CGFloat) -> Void)?

        override func layoutSubviews() {
            super.layoutSubviews()
            var current: UIView? = self
            while let parent = current?.superview {
                if let scrollView = parent as? UIScrollView {
                    onHeightChange?(scrollView.contentSize.height)
                    return
                }
                current = parent
            }
        }
    }
}

// MARK: - Preference Keys

private struct ScrollOffsetKey: PreferenceKey {
    static let defaultValue: CGPoint = .zero
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}

private struct FooterHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = max(value, nextValue()) }
}

// MARK: - Environment Key

private struct MPHeaderIsScrollableKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

package extension EnvironmentValues {
    var mpHeaderIsScrollable: Bool {
        get { self[MPHeaderIsScrollableKey.self] }
        set { self[MPHeaderIsScrollableKey.self] = newValue }
    }
}
