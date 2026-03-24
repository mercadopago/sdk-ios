//
//  MPHeader.swift
//  MPComponents
//
//  A collapsible header component with navigation and scroll animations.
//

import MPFoundation
import SwiftUI
import UIKit

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
    @State private var scrollViewHeight: CGFloat = 0
    /// Natural footer height — always measured via invisible overlay regardless of enabled state.
    @State private var footerMeasuredHeight: CGFloat = 0
    /// Actual rendered footer height — 0 when footer is disabled.
    @State private var actualFooterHeight: CGFloat = 0

    // MARK: - Computed

    private var isScrollable: Bool {
        self.scrollViewHeight > 0 && self.contentHeight > self.scrollViewHeight
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
        ZStack(alignment: .top) {
            self.scrollViewContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            self.headerContent
                .frame(maxWidth: .infinity, alignment: .top)
                .zIndex(1)
        }
        // Invisible overlay always renders footer at full height to measure it
        .overlay(
            self.footer
                .disabled(false)
                .opacity(0)
                .allowsHitTesting(false)
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(key: FooterMeasurementKey.self, value: geo.size.height)
                    }
                ),
            alignment: .bottom
        )
        .onPreferenceChange(MainHeaderHeightKey.self) { self.headerHeight = $0 }
        .onPreferenceChange(SubHeaderHeightKey.self) { self.subHeaderHeight = $0 }
        .onPreferenceChange(ScrollViewHeightKey.self) { self.scrollViewHeight = $0 }
        .onPreferenceChange(FooterMeasurementKey.self) { self.footerMeasuredHeight = $0 }
        .onPreferenceChange(FooterHeightKey.self) { self.actualFooterHeight = $0 }
        .navigationBarHidden(true)
    }

    // MARK: - Scroll View Content

    private var scrollViewContent: some View {
        if #available(iOS 14.0, *) {
            return AnyView(self.scrollViewContentWithAutoScroll)
        }
        return AnyView(self.scrollViewContentBase)
    }

    @available(iOS 14.0, *)
    private var scrollViewContentWithAutoScroll: some View {
        ScrollViewReader { proxy in
            ScrollViewWithOffset(
                offset: self.$scrollOffset,
                contentHeight: self.$contentHeight
            ) {
                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: self.headerInset())
                        .padding(.bottom, self.theme.spacings.xsmall)
                    self.content
                    // Reserves footer height + bottom spacing so last field is always
                    // scrollable above the footer overlay with breathing room.
                    Color.clear.frame(height: self.footerMeasuredHeight + self.theme.spacings.xsmall).id("footerPadding")
                }
            }
            .background(
                GeometryReader { geo in
                    Color.clear.preference(key: ScrollViewHeightKey.self, value: geo.size.height)
                }
            )
            .overlay(
                self.footer
                    .environment(\.mpHeaderIsScrollable, self.isScrollable)
                    .background(
                        GeometryReader { geo in
                            Color.clear.preference(key: FooterHeightKey.self, value: geo.size.height)
                        }
                    ),
                alignment: .bottom
            )
            .onChange(of: self.actualFooterHeight) { newHeight in
                guard newHeight > 0 else { return }
                withAnimation(.easeOut(duration: 0.25)) {
                    proxy.scrollTo("footerPadding", anchor: .bottom)
                }
            }
        }
    }

    private var scrollViewContentBase: some View {
        ScrollViewWithOffset(
            offset: self.$scrollOffset,
            contentHeight: self.$contentHeight
        ) {
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: self.headerInset())
                    .padding(.bottom, self.theme.spacings.xsmall)
                self.content
                Color.clear.frame(height: self.footerMeasuredHeight + self.theme.spacings.xsmall)
            }
        }
        .background(
            GeometryReader { geo in
                Color.clear.preference(key: ScrollViewHeightKey.self, value: geo.size.height)
            }
        )
        .overlay(
            self.footer.environment(\.mpHeaderIsScrollable, self.isScrollable),
            alignment: .bottom
        )
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
            self.style.resolve(configuration: configuration)
        )
    }

    // MARK: - Computed Properties

    /// Progress of the collapse animation (0 = fully expanded, 1 = fully collapsed)
    private var collapseProgress: CGFloat {
        guard self.subHeaderHeight > 0 else { return 0 }
        return max(0, min((0 - self.scrollOffset) / self.subHeaderHeight, 1))
    }

    /// Visible height of the sub-header (decreases as user scrolls)
    private var subHeaderVisibleHeight: CGFloat {
        self.subHeaderHeight * (1 - self.collapseProgress)
    }

    private func headerInset() -> CGFloat {
        let totalInset = self.headerHeight + self.subHeaderVisibleHeight
        return max(totalInset, 40)
    }

    private var trailingActionsConfiguration: MPHeaderStyleConfiguration.TrailingActions? {
        guard TrailingActions.self != EmptyView.self else { return nil }
        return MPHeaderStyleConfiguration.TrailingActions(body: AnyView(self.trailingActions))
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
            self.content
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .preference(
                                key: ScrollOffsetKey.self,
                                value: geo.frame(in: .named("MPScroll")).origin
                            )
                    }
                )
                .background(ScrollContentSizeReader(contentHeight: self.$contentHeight))
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

    func makeUIView(context _: Context) -> InnerView {
        let view = InnerView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        return view
    }

    func updateUIView(_ uiView: InnerView, context _: Context) {
        uiView.onHeightChange = { height in
            if height > 0, abs(height - self.contentHeight) > 0.5 {
                self.contentHeight = height
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
                    self.onHeightChange?(scrollView.contentSize.height)
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
    static func reduce(value _: inout CGPoint, nextValue _: () -> CGPoint) {}
}

private struct FooterHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private struct FooterMeasurementKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private struct ScrollViewHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// MARK: - Environment Key

private struct MPHeaderIsScrollableKey: EnvironmentKey {
    static let defaultValue = false
}

package extension EnvironmentValues {
    var mpHeaderIsScrollable: Bool {
        get { self[MPHeaderIsScrollableKey.self] }
        set { self[MPHeaderIsScrollableKey.self] = newValue }
    }
}
