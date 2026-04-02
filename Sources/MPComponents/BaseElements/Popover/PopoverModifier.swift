//
//  PopoverModifier.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 08/09/25.
//

import MPFoundation
import SwiftUI

/// A view modifier that presents a popover using UIPopoverPresentationController.
///
/// Always requires an external `isPresented` binding — the caller controls when the
/// popover opens.
struct PopoverModifier<PopoverContent: View>: ViewModifier {
    // MARK: - Environment

    @Environment(\.checkoutTheme) var theme: MPTheme

    // MARK: - Configuration

    @Binding var isPresented: Bool
    var popoverConfiguration: PopoverConfig
    var popoverContent: PopoverContent

    // MARK: - Init

    init(
        config: PopoverConfig,
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> PopoverContent
    ) {
        self.popoverConfiguration = config
        self._isPresented = isPresented
        self.popoverContent = content()
    }

    // MARK: - Body

    // The caller's button action (or tap gesture) controls isPresented — no tap here.

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo in
                    MPPopoverPresenter(isPresented: self.$isPresented) {
                        MPPopoverFloatingContent(
                            triggerFrame: geo.frame(in: .global),
                            config: self.popoverConfiguration,
                            theme: self.theme,
                            content: AnyView(
                                self.popoverContent
                                    .environment(\.popoverVisibility, self.$isPresented)
                            ),
                            onDismiss: { self.isPresented = false }
                        )
                    }
                }
            )
    }
}

// MARK: - MPPopoverFloatingContent

/// Full-screen transparent container — the bubble is positioned absolutely.
struct MPPopoverFloatingContent: View {
    let triggerFrame: CGRect
    let config: PopoverConfig
    let theme: MPTheme
    let content: AnyView
    let onDismiss: () -> Void

    @State private var measuredSize: CGSize = .zero
    @State private var contentSize: CGSize = .zero

    private var effectiveContentWidth: CGFloat? {
        guard self.contentSize.width > 0 else { return nil }
        if let maxWidth = config.maxWidth, contentSize.width > maxWidth { return maxWidth }
        return self.contentSize.width
    }

    private var popoverContentWidth: CGFloat {
        self.measuredSize.width > 0 ? self.measuredSize.width : (self.config.maxWidth ?? 246)
    }

    private var popoverContentHeight: CGFloat {
        self.measuredSize.height > 0 ? self.measuredSize.height : 50
    }

    private var safeAreaInsets: UIEdgeInsets {
        UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
    }

    var body: some View {
        let positionResult = self.calculateAdjustedPosition()

        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { self.onDismiss() }

            self.bubbleView(positionResult: positionResult)
                .position(x: positionResult.position.x, y: positionResult.position.y)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
        .onPreferenceChange(FloatingContentSizeKey.self) { size in
            guard size.width > 0, size.height > 0 else { return }
            DispatchQueue.main.async { self.contentSize = size }
        }
        .onPreferenceChange(FloatingPopoverSizeKey.self) { size in
            guard size.width > 0, size.height > 0 else { return }
            DispatchQueue.main.async { self.measuredSize = size }
        }
    }

    // MARK: - Bubble (arrow + balloon as a single composited unit)

    @ViewBuilder
    private func bubbleView(positionResult: PositionResult) -> some View {
        let showArrow = self.config.showArrow && self.config.side.shouldShowArrow()
        let bgColor = self.config.backgroundColor(from: self.theme)

        switch self.config.side {
        case .top, .topLeft, .topRight:
            VStack(spacing: 0) {
                self.balloonView
                if showArrow {
                    self.arrowDown(color: bgColor)
                        .offset(x: positionResult.arrowOffsetX)
                }
            }
            .compositingGroup()
            .shadow(color: Color.black.opacity(0.10), radius: 5, x: 0, y: 0)

        case .bottom, .bottomLeft, .bottomRight:
            VStack(spacing: 0) {
                if showArrow {
                    self.arrowUp(color: bgColor)
                        .offset(x: positionResult.arrowOffsetX)
                }
                self.balloonView
            }
            .compositingGroup()
            .shadow(color: Color.black.opacity(0.10), radius: 5, x: 0, y: 0)

        case .left:
            HStack(spacing: 0) {
                self.balloonView
                if showArrow {
                    self.arrowRight(color: bgColor)
                        .offset(y: positionResult.arrowOffsetY)
                }
            }
            .compositingGroup()
            .shadow(color: Color.black.opacity(0.10), radius: 5, x: 0, y: 0)

        case .right:
            HStack(spacing: 0) {
                if showArrow {
                    self.arrowLeft(color: bgColor)
                        .offset(y: positionResult.arrowOffsetY)
                }
                self.balloonView
            }
            .compositingGroup()
            .shadow(color: Color.black.opacity(0.10), radius: 5, x: 0, y: 0)

        case .center:
            self.balloonView
                .shadow(color: Color.black.opacity(0.10), radius: 5, x: 0, y: 0)
        }
    }

    private func arrowUp(color: Color) -> some View {
        ArrowShape()
            .foregroundColor(color)
            .frame(width: self.config.arrowWidth, height: self.config.arrowHeight)
    }

    private func arrowDown(color: Color) -> some View {
        ArrowShape()
            .rotation(Angle(radians: .pi))
            .foregroundColor(color)
            .frame(width: self.config.arrowWidth, height: self.config.arrowHeight)
    }

    private func arrowRight(color: Color) -> some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: self.config.arrowHeight, y: self.config.arrowWidth / 2))
            path.addLine(to: CGPoint(x: 0, y: self.config.arrowWidth))
            path.closeSubpath()
        }
        .fill(color)
        .frame(width: self.config.arrowHeight, height: self.config.arrowWidth)
    }

    private func arrowLeft(color: Color) -> some View {
        Path { path in
            path.move(to: CGPoint(x: self.config.arrowHeight, y: 0))
            path.addLine(to: CGPoint(x: 0, y: self.config.arrowWidth / 2))
            path.addLine(to: CGPoint(x: self.config.arrowHeight, y: self.config.arrowWidth))
            path.closeSubpath()
        }
        .fill(color)
        .frame(width: self.config.arrowHeight, height: self.config.arrowWidth)
    }

    // MARK: - Balloon

    private var balloonView: some View {
        HStack(alignment: .top, spacing: self.theme.spacings.gap.micro) {
            self.content
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(key: FloatingContentSizeKey.self, value: geo.size)
                    }
                )
                .frame(width: self.effectiveContentWidth, alignment: .leading)

            Button(action: self.onDismiss) {
                Image(Logos.close, bundle: .bundleMP)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 20, height: 20)
                    .foregroundColor(self.theme.colors.icon.secondary)
            }
        }
        .padding(self.config.contentPadding(from: self.theme))
        .background(
            RoundedRectangle(cornerRadius: self.config.borderRadius(from: self.theme))
                .foregroundColor(self.config.backgroundColor(from: self.theme))
        )
        .overlay(self.contentSizeMeasurer)
    }

    private var contentSizeMeasurer: some View {
        GeometryReader { geo in
            Color.clear.preference(key: FloatingPopoverSizeKey.self, value: geo.size)
        }
    }

    // MARK: - Position Calculation

    private struct PositionResult {
        let position: CGPoint
        let arrowOffsetX: CGFloat
        let arrowOffsetY: CGFloat
    }

    private func calculateAdjustedPosition() -> PositionResult {
        let margin = self.config.margin
        let arrowDepth = self.config.showArrow && self.config.side.shouldShowArrow() ? self.config.arrowHeight : 0
        let screenPadding: CGFloat = 8
        let screenBounds = UIScreen.main.bounds
        let minX = self.safeAreaInsets.left + screenPadding
        let maxX = screenBounds.width - self.safeAreaInsets.right - screenPadding
        let minY = self.safeAreaInsets.top + screenPadding
        let maxY = screenBounds.height - self.safeAreaInsets.bottom - screenPadding

        // Total bubble size = balloon + arrow depth
        let bubbleW: CGFloat
        let bubbleH: CGFloat
        switch self.config.side {
        case .left, .right:
            bubbleW = self.popoverContentWidth + arrowDepth
            bubbleH = self.popoverContentHeight
        default:
            bubbleW = self.popoverContentWidth
            bubbleH = self.popoverContentHeight + arrowDepth
        }

        var globalX = self.triggerFrame.midX
        var globalY = self.triggerFrame.midY

        // Arrow tip position (where the arrow touches the trigger area)
        let arrowTipX: CGFloat
        let arrowTipY: CGFloat
        switch self.config.side {
        case .top, .topLeft, .topRight:
            arrowTipX = self.triggerFrame.midX
            arrowTipY = self.triggerFrame.minY - margin
            globalY = arrowTipY - bubbleH / 2
        case .bottom, .bottomLeft, .bottomRight:
            arrowTipX = self.triggerFrame.midX
            arrowTipY = self.triggerFrame.maxY + margin
            globalY = arrowTipY + bubbleH / 2
        case .left:
            arrowTipX = self.triggerFrame.minX - margin
            arrowTipY = self.triggerFrame.midY
            globalX = arrowTipX - bubbleW / 2
            globalY = arrowTipY
        case .right:
            arrowTipX = self.triggerFrame.maxX + margin
            arrowTipY = self.triggerFrame.midY
            globalX = arrowTipX + bubbleW / 2
            globalY = arrowTipY
        case .center:
            arrowTipX = self.triggerFrame.midX
            arrowTipY = self.triggerFrame.maxY + margin
            globalY = arrowTipY + bubbleH / 2
        }

        // Horizontal alignment for top/bottom/center (arrow X = trigger midX, with corner adjustments)
        let arrowInset = self.config.borderRadius(from: self.theme) + self.config.arrowWidth
        switch self.config.side {
        case .top, .bottom, .center:
            globalX = arrowTipX
        case .topLeft, .bottomLeft:
            globalX = arrowTipX + self.popoverContentWidth / 2 - arrowInset
        case .topRight, .bottomRight:
            globalX = arrowTipX - self.popoverContentWidth / 2 + arrowInset
        case .left, .right:
            break
        }

        globalX = max(minX + bubbleW / 2, min(maxX - bubbleW / 2, globalX))
        globalY = max(minY + bubbleH / 2, min(maxY - bubbleH / 2, globalY))

        return PositionResult(
            position: CGPoint(x: globalX, y: globalY),
            arrowOffsetX: arrowTipX - globalX,
            arrowOffsetY: arrowTipY - globalY
        )
    }
}

// MARK: - Preference Keys

private struct FloatingPopoverSizeKey: PreferenceKey {
    static let defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

private struct FloatingContentSizeKey: PreferenceKey {
    static let defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

// MARK: - Environment support for popover visibility control

private struct PopoverVisibilityKey: EnvironmentKey {
    static let defaultValue: Binding<Bool>? = nil
}

extension EnvironmentValues {
    var popoverVisibility: Binding<Bool>? {
        get { self[PopoverVisibilityKey.self] }
        set { self[PopoverVisibilityKey.self] = newValue }
    }
}

// MARK: - Preview

#if DEBUG

    private struct PopoverPreviewTrigger: View {
        let label: String
        let config: PopoverConfig
        let content: String
        @State private var isPresented = false

        var body: some View {
            Button(self.label) { self.isPresented = true }
                .popover(config: self.config, isPresented: self.$isPresented) {
                    Text(self.content)
                }
        }
    }

    private struct PopoverSidesPreview: View {
        var body: some View {
            VStack(spacing: 0) {
                // Top — botão no centro inferior da metade superior
                Spacer()
                HStack {
                    Spacer()
                    PopoverPreviewTrigger(
                        label: "↑ Top",
                        config: DefaultPopoverConfig(side: .top, type: .white),
                        content: "Popover acima do gatilho."
                    )
                    Spacer()
                }
                Spacer()

                // Left — botão ancorado à direita para ter espaço à esquerda
                HStack {
                    Spacer()
                    PopoverPreviewTrigger(
                        label: "Left ←",
                        config: DefaultPopoverConfig(side: .left, type: .white),
                        content: "Popover à esquerda."
                    )
                    .padding(.trailing, 32)
                }

                Spacer()

                // Right — botão ancorado à esquerda para ter espaço à direita
                HStack {
                    PopoverPreviewTrigger(
                        label: "→ Right",
                        config: DefaultPopoverConfig(side: .right, type: .white),
                        content: "Popover à direita."
                    )
                    .padding(.leading, 32)
                    Spacer()
                }

                Spacer()

                // Bottom — botão no centro superior da metade inferior
                HStack {
                    Spacer()
                    PopoverPreviewTrigger(
                        label: "↓ Bottom",
                        config: DefaultPopoverConfig(side: .bottom, type: .white),
                        content: "Popover abaixo do gatilho."
                    )
                    Spacer()
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private struct PopoverCornersPreview: View {
        var body: some View {
            VStack(spacing: 40) {
                HStack(spacing: 40) {
                    PopoverPreviewTrigger(
                        label: "Top Left",
                        config: DefaultPopoverConfig(side: .topLeft, type: .white),
                        content: "Canto superior esquerdo."
                    )
                    PopoverPreviewTrigger(
                        label: "Top Right",
                        config: DefaultPopoverConfig(side: .topRight, type: .white),
                        content: "Canto superior direito."
                    )
                }
                HStack(spacing: 40) {
                    PopoverPreviewTrigger(
                        label: "Bottom Left",
                        config: DefaultPopoverConfig(side: .bottomLeft, type: .white),
                        content: "Canto inferior esquerdo."
                    )
                    PopoverPreviewTrigger(
                        label: "Bottom Right",
                        config: DefaultPopoverConfig(side: .bottomRight, type: .white),
                        content: "Canto inferior direito."
                    )
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private struct PopoverNoArrowPreview: View {
        @State private var isPresented = false

        var body: some View {
            Button("No Arrow (center)") { self.isPresented = true }
                .popover(
                    config: {
                        var config = DefaultPopoverConfig(side: .center, type: .white)
                        config.showArrow = false
                        return config
                    }(),
                    isPresented: self.$isPresented
                ) {
                    Text("Sem seta, posicionado ao centro.")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private struct PopoverTapTriggerPreview: View {
        var body: some View {
            Text("Tap me")
                .padding()
                .background(Color.blue.opacity(0.15))
                .cornerRadius(8)
                .popover {
                    Text("Dismisses ao tocar fora.")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    #Preview("Popover - Lados cardinais") { PopoverSidesPreview() }
    #Preview("Popover - Cantos") { PopoverCornersPreview() }
    #Preview("Popover - Sem seta") { PopoverNoArrowPreview() }
    #Preview("Popover - Tap trigger (sem binding)") { PopoverTapTriggerPreview() }
#endif
