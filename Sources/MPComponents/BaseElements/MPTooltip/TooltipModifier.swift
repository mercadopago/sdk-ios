//
//  TooltipModifier.swift
//  MPComponents
//

import MPFoundation
import SwiftUI

// MARK: - MPTooltipModifier

struct MPTooltipModifier<TooltipContent: View>: ViewModifier {
    // MARK: Environment

    @Environment(\.checkoutTheme) var theme: MPTheme

    // MARK: Configuration

    @Binding var isPresented: Bool
    var tooltipConfiguration: MPTooltipConfig
    var tooltipContent: TooltipContent

    // MARK: Init

    init(
        config: MPTooltipConfig,
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> TooltipContent
    ) {
        self.tooltipConfiguration = config
        self._isPresented = isPresented
        self.tooltipContent = content()
    }

    // MARK: Body

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo in
                    MPPopoverPresenter(isPresented: self.$isPresented) {
                        MPTooltipFloatingContent(
                            triggerFrame: geo.frame(in: .global),
                            config: self.tooltipConfiguration,
                            theme: self.theme,
                            content: AnyView(
                                self.tooltipContent
                                    .environment(\.mpTooltipVisibility, self.$isPresented)
                            ),
                            onDismiss: { self.isPresented = false }
                        )
                    }
                }
            )
    }
}

// MARK: - MPTooltipFloatingContent

/// Full-screen transparent container — positions the dark tooltip bubble absolutely.
/// No arrow is rendered; tooltip is a plain rounded dark pill.
struct MPTooltipFloatingContent: View {
    let triggerFrame: CGRect
    let config: MPTooltipConfig
    let theme: MPTheme
    let content: AnyView
    let onDismiss: () -> Void

    @State private var measuredSize: CGSize = .zero
    @State private var contentSize: CGSize = .zero

    private let maxWidth: CGFloat = 280

    private var effectiveContentWidth: CGFloat? {
        guard self.contentSize.width > 0 else { return nil }
        return self.contentSize.width > self.maxWidth ? self.maxWidth : self.contentSize.width
    }

    private var tooltipWidth: CGFloat {
        self.measuredSize.width > 0 ? self.measuredSize.width : self.maxWidth
    }

    private var tooltipHeight: CGFloat {
        self.measuredSize.height > 0 ? self.measuredSize.height : 36
    }

    private var safeAreaInsets: UIEdgeInsets {
        UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
    }

    var body: some View {
        let position = self.calculatePosition()

        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { self.onDismiss() }

            self.balloonView
                .position(x: position.x, y: position.y)
                .opacity(self.measuredSize == .zero ? 0 : 1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
        .onPreferenceChange(MPTooltipContentSizeKey.self) { size in
            guard size.width > 0, size.height > 0 else { return }
            DispatchQueue.main.async { self.contentSize = size }
        }
        .onPreferenceChange(MPTooltipBubbleSizeKey.self) { size in
            guard size.width > 0, size.height > 0 else { return }
            DispatchQueue.main.async { self.measuredSize = size }
        }
    }

    // MARK: - Balloon (no arrow, no close button)

    private var balloonView: some View {
        self.content
            .font(Font(self.theme.typography.body.small.default))
            .foregroundColor(self.theme.colors.text.inverse)
            .background(
                GeometryReader { geo in
                    Color.clear.preference(key: MPTooltipContentSizeKey.self, value: geo.size)
                }
            )
            .frame(width: self.effectiveContentWidth, alignment: .leading)
            .padding(EdgeInsets(
                top: self.theme.spacings.pico,
                leading: self.theme.spacings.xmicro,
                bottom: self.theme.spacings.pico,
                trailing: self.theme.spacings.xmicro
            ))
            .background(
                RoundedRectangle(cornerRadius: self.theme.borderRadius.tiny)
                    .foregroundColor(self.theme.colors.fill.inverse)
            )
            // shadow/low/bottom: blur 4, Y 2, X 0, spread 0
            .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.12), radius: 4, x: 0, y: 2)
            .overlay(
                GeometryReader { geo in
                    Color.clear.preference(key: MPTooltipBubbleSizeKey.self, value: geo.size)
                }
            )
    }

    // MARK: - Position Calculation

    private func calculatePosition() -> CGPoint {
        let gap: CGFloat = self.theme.spacings.xnano
        let screenPadding: CGFloat = 8
        let screenBounds = UIScreen.main.bounds
        let minX = self.safeAreaInsets.left + screenPadding + self.tooltipWidth / 2
        let maxX = screenBounds.width - self.safeAreaInsets.right - screenPadding - self.tooltipWidth / 2
        let minY = self.safeAreaInsets.top + screenPadding + self.tooltipHeight / 2
        let maxY = screenBounds.height - self.safeAreaInsets.bottom - screenPadding - self.tooltipHeight / 2

        var x = self.triggerFrame.midX
        var y = self.triggerFrame.midY

        switch self.config.side.toPopoverSide() {
        case .top, .topLeft, .topRight:
            y = self.triggerFrame.minY - gap - self.tooltipHeight / 2
        case .bottom, .bottomLeft, .bottomRight, .center:
            y = self.triggerFrame.maxY + gap + self.tooltipHeight / 2
        case .left:
            x = self.triggerFrame.minX - gap - self.tooltipWidth / 2
            y = self.triggerFrame.midY
        case .right:
            x = self.triggerFrame.maxX + gap + self.tooltipWidth / 2
            y = self.triggerFrame.midY
        }

        x = max(minX, min(maxX, x))
        y = max(minY, min(maxY, y))

        return CGPoint(x: x, y: y)
    }
}

// MARK: - Preference Keys

private struct MPTooltipBubbleSizeKey: PreferenceKey {
    static let defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

private struct MPTooltipContentSizeKey: PreferenceKey {
    static let defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

// MARK: - Environment support for tooltip visibility control

private struct MPTooltipVisibilityKey: EnvironmentKey {
    static let defaultValue: Binding<Bool>? = nil
}

extension EnvironmentValues {
    var mpTooltipVisibility: Binding<Bool>? {
        get { self[MPTooltipVisibilityKey.self] }
        set { self[MPTooltipVisibilityKey.self] = newValue }
    }
}

// MARK: - Preview

#if DEBUG

    private struct MPTooltipPreviewTrigger: View {
        let label: String
        let side: MPTooltipSide
        let content: String
        @State private var isPresented = false

        var body: some View {
            Button(self.label) { self.isPresented = true }
                .mpTooltip(config: MPDefaultTooltipConfig(side: self.side), isPresented: self.$isPresented) {
                    Text(self.content)
                }
        }
    }

    private struct MPTooltipSidesPreview: View {
        var body: some View {
            VStack(spacing: 0) {
                Spacer()
                HStack {
                    Spacer()
                    MPTooltipPreviewTrigger(label: "↑ Top", side: .top, content: "É um número de 3 digitos  que está atrás do seu cartão ou no app do seu banco.")
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    MPTooltipPreviewTrigger(label: "Left ←", side: .left, content: "Tooltip à esquerda.")
                        .padding(.trailing, 32)
                }
                Spacer()
                HStack {
                    MPTooltipPreviewTrigger(label: "→ Right", side: .right, content: "Tooltip à direita.")
                        .padding(.leading, 32)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    MPTooltipPreviewTrigger(label: "↓ Bottom", side: .bottom, content: "Tooltip abaixo do gatilho.")
                    Spacer()
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    #Preview("Tooltip - Lados cardinais") { MPTooltipSidesPreview() }

#endif
