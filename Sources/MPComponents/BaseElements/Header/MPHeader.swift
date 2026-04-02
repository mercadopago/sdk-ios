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
/// - **Main Header**: A fixed top bar with back button and trailing actions
/// - **Animated Title**: A large title that physically moves from below the bar to inline as the user scrolls
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
    @State private var headerHeight: CGFloat = 0
    @State private var subHeaderHeight: CGFloat = 0
    @State private var contentHeight: CGFloat = 0
    @State private var scrollViewHeight: CGFloat = 0
    @State private var footerMeasuredHeight: CGFloat = 0
    @State private var actualFooterHeight: CGFloat = 0

    // MARK: - Computed

    /// 0 when large title fully visible, 1 when fully scrolled off.
    private var collapseProgress: CGFloat {
        guard self.subHeaderHeight > 0 else { return 0 }
        return max(0, min(-self.scrollOffset / self.subHeaderHeight, 1))
    }

    /// Opacity for the inline title: fades in only after the large title has nearly scrolled off.
    private var inlineTitleOpacity: CGFloat {
        let threshold: CGFloat = 0.75
        return max(0, min((self.collapseProgress - threshold) / (1 - threshold), 1))
    }

    private var isScrollable: Bool {
        self.scrollViewHeight > 0 && self.contentHeight > self.scrollViewHeight
    }

    // MARK: - Initialization

    /// Creates a new header with the specified configuration.
    ///
    /// - Parameters:
    ///   - title: The title to display in the header
    ///   - onBack: Action to perform when the back button is tapped
    ///   - trailingActions: Optional views to display on the trailing edge
    ///   - footer: Optional footer view pinned to the bottom
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
            self.scrollArea
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            self.mainHeaderBar
                .frame(maxWidth: .infinity, alignment: .top)
                .background(self.theme.colors.background.primary.edgesIgnoringSafeArea(.top))
                .zIndex(1)

            // Measures sub-header height OUTSIDE the ScrollView so preference propagation
            // is direct and reliable. Zero-height in layout; overlay extends downward.
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: 0)
                .overlay(
                    Text(self.title)
                        .textStyle(.headingHuge())
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, self.theme.spacings.paddings.xtiny)
                        .padding(.vertical, self.theme.spacings.paddings.xmicro)
                        .fixedSize(horizontal: false, vertical: true)
                        .background(
                            GeometryReader { geo in
                                Color.clear.preference(
                                    key: SubHeaderHeightKey.self,
                                    value: geo.size.height
                                )
                            }
                        )
                        .allowsHitTesting(false)
                        .opacity(0),
                    alignment: .topLeading
                )
        }
        // Invisible overlay measures footer at full height
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
        .background(self.theme.colors.background.primary.edgesIgnoringSafeArea(.all))
        .onPreferenceChange(MainHeaderHeightKey.self) { self.headerHeight = $0 }
        .onPreferenceChange(SubHeaderHeightKey.self) { self.subHeaderHeight = $0 }
        .onPreferenceChange(ScrollViewHeightKey.self) { self.scrollViewHeight = $0 }
        .onPreferenceChange(FooterMeasurementKey.self) { self.footerMeasuredHeight = $0 }
        .onPreferenceChange(FooterHeightKey.self) { self.actualFooterHeight = $0 }
        .navigationBarHidden(true)
    }

    // MARK: - Main Header Bar

    /// Renders the main header bar via the injected style (back button + trailing actions).
    /// Uses fixedSize to ensure it takes only its natural height regardless of proposed size.
    private var mainHeaderBar: some View {
        let configuration = MPHeaderStyleConfiguration(
            title: self.title,
            onBack: self.onBack,
            trailingActions: self.trailingActionsConfiguration,
            scrollOffset: self.scrollOffset,
            inlineTitleOpacity: self.inlineTitleOpacity
        )
        return AnyView(self.style.resolve(configuration: configuration))
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Overlay Title

    // MARK: - Scroll Area

    @ViewBuilder
    private var scrollArea: some View {
        if #available(iOS 14.0, *) {
            self.scrollAreaWithAutoScroll
        } else {
            self.scrollAreaBase
        }
    }

    @available(iOS 14.0, *)
    private var scrollAreaWithAutoScroll: some View {
        ScrollViewReader { proxy in
            ScrollViewWithOffset(
                offset: self.$scrollOffset,
                contentHeight: self.$contentHeight
            ) {
                VStack(spacing: 0) {
                    // Space reserved for the floating header bar
                    Color.clear.frame(height: self.headerHeight)
                    // Invisible spacer that measures sub-header height for animation math
                    self.subHeaderSpacer
                    Color.clear.frame(height: self.theme.spacings.paddings.xsmall)
                    self.content
                    // Reserves space so last item scrolls above the footer with breathing room
                    Color.clear
                        .frame(height: self.footerMeasuredHeight + self.theme.spacings.paddings.xsmall)
                        .id("footerPadding")
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

    private var scrollAreaBase: some View {
        ScrollViewWithOffset(
            offset: self.$scrollOffset,
            contentHeight: self.$contentHeight
        ) {
            VStack(spacing: 0) {
                Color.clear.frame(height: self.headerHeight)
                self.subHeaderSpacer
                Color.clear.frame(height: self.theme.spacings.paddings.xsmall)
                self.content
                Color.clear.frame(height: self.footerMeasuredHeight + self.theme.spacings.paddings.xsmall)
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

    // MARK: - Sub-header Spacer

    /// Large title that scrolls with the content. When it scrolls off, the inline
    /// title in the header bar fades in.
    private var subHeaderSpacer: some View {
        Text(self.title)
            .textStyle(.headingHuge())
            .lineLimit(2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, self.theme.spacings.paddings.xtiny)
            .padding(.vertical, self.theme.spacings.paddings.xmicro)
    }

    // MARK: - Computed Properties

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
                    ScrollMetricsReader(
                        contentHeight: self.$contentHeight,
                        scrollOffset: self.$offset
                    )
                )
        }
    }
}

// MARK: - UIScrollView Metrics Reader (KVO-based, reliable on all iOS versions)

/// Walks up the UIView hierarchy to find the parent UIScrollView, then uses KVO to
/// observe contentOffset and layoutSubviews to observe contentSize. This is more
/// reliable than the GeometryReader+PreferenceKey approach for scroll tracking.
private struct ScrollMetricsReader: UIViewRepresentable {
    @Binding var contentHeight: CGFloat
    @Binding var scrollOffset: CGFloat

    func makeUIView(context _: Context) -> InnerView {
        let view = InnerView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        return view
    }

    func updateUIView(_ uiView: InnerView, context _: Context) {
        uiView.onHeightChange = { [weak uiView] height in
            guard let uiView else { return }
            if height > 0, abs(height - uiView.lastReportedHeight) > 0.5 {
                uiView.lastReportedHeight = height
                self.contentHeight = height
            }
        }
        uiView.onOffsetChange = { offset in
            self.scrollOffset = offset
        }
    }

    final class InnerView: UIView {
        var onHeightChange: ((CGFloat) -> Void)?
        var onOffsetChange: ((CGFloat) -> Void)?
        var lastReportedHeight: CGFloat = 0
        private var observation: NSKeyValueObservation?

        override func layoutSubviews() {
            super.layoutSubviews()
            guard self.observation == nil else { return }
            var current: UIView? = self
            while let parent = current?.superview {
                if let scrollView = parent as? UIScrollView {
                    // Report initial content size
                    self.onHeightChange?(scrollView.contentSize.height)
                    // Observe contentOffset via KVO — fires on every scroll frame
                    self.observation = scrollView.observe(
                        \.contentOffset,
                        options: [.new]
                    ) { [weak self] sv, _ in
                        DispatchQueue.main.async {
                            self?.onHeightChange?(sv.contentSize.height)
                            // Negate so scrolling down → negative offset (matching convention)
                            self?.onOffsetChange?(-sv.contentOffset.y)
                        }
                    }
                    return
                }
                current = parent
            }
        }
    }
}

// MARK: - Preference Keys

private struct SubHeaderHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
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
