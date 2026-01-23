//
//  PopoverPortal.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 08/09/25.
//

import SwiftUI
import MPFoundation

// MARK: - Global Popover Window Manager

/// Singleton that manages a UIWindow for displaying popovers globally.
final class PopoverWindowManager {
    @MainActor static let shared = PopoverWindowManager()
    
    private var popoverWindow: UIWindow?
    private var hostingController: UIHostingController<AnyView>?
    
    private init() {}
    
    /// Shows a popover using a dedicated UIWindow
    @MainActor
    func show<Content: View>(
        triggerFrame: CGRect,
        config: PopoverConfig,
        theme: MPTheme,
        onDismiss: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        // Dismiss any existing popover first
        dismiss()
        
        // Create the popover content view
        let popoverView = PopoverWindowView(
            triggerFrame: triggerFrame,
            config: config,
            theme: theme,
            content: AnyView(content()),
            onDismiss: { [weak self] in
                self?.dismiss()
                onDismiss()
            }
        )
        
        // Create hosting controller
        let hostingController = UIHostingController(rootView: AnyView(popoverView))
        hostingController.view.backgroundColor = .clear
        self.hostingController = hostingController
        
        // Create window
        let window: UIWindow
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first {
            window = UIWindow(windowScene: windowScene)
        } else {
            window = UIWindow(frame: UIScreen.main.bounds)
        }
        
        window.rootViewController = hostingController
        window.windowLevel = .alert + 1
        window.backgroundColor = .clear
        window.makeKeyAndVisible()
        self.popoverWindow = window
    }
    
    /// Dismisses the current popover
    @MainActor
    func dismiss() {
        popoverWindow?.isHidden = true
        popoverWindow = nil
        hostingController = nil
    }
}

// MARK: - Popover Window View

/// View displayed in the popover window
private struct PopoverWindowView: View {
    let triggerFrame: CGRect
    let config: PopoverConfig
    let theme: MPTheme
    let content: AnyView
    let onDismiss: () -> Void
    
    var body: some View {
        let screen = UIScreen.main.bounds
        
        ZStack {
            // Tap-outside to dismiss
            Color.clear
                .contentShape(Rectangle())
                .frame(width: screen.width, height: screen.height)
                .onTapGesture { onDismiss() }
            
            // Popover content
            PopoverWindowContentView(
                triggerFrame: triggerFrame,
                config: config,
                theme: theme,
                content: content,
                onDismiss: onDismiss
            )
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - Popover Size Preference Key

private struct PopoverSizeKey: PreferenceKey {
    static let defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

// MARK: - Content Size Preference Key

private struct ContentSizeKey: PreferenceKey {
    static let defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

// MARK: - Popover Window Content View

/// The actual popover content rendered in the window
private struct PopoverWindowContentView: View {
    let triggerFrame: CGRect
    let config: PopoverConfig
    let theme: MPTheme
    let content: AnyView
    let onDismiss: () -> Void
    
    @State private var measuredSize: CGSize = .zero
    @State private var contentSize: CGSize = .zero
    
    /// Width efetivo: se contentSize > maxWidth usa maxWidth, senão usa contentSize
    private var effectiveContentWidth: CGFloat? {
        guard contentSize.width > 0 else { return nil }
        if let maxWidth = config.maxWidth, contentSize.width > maxWidth {
            return maxWidth
        }
        return contentSize.width
    }
    
    /// Width for positioning calculations
    private var popoverContentWidth: CGFloat {
        measuredSize.width > 0 ? measuredSize.width : 100 // Fallback until measured
    }
    
    /// Height is the measured content height (adapts to content)
    private var popoverContentHeight: CGFloat {
        measuredSize.height > 0 ? measuredSize.height : 50 // Fallback until measured
    }
    
    private var safeAreaInsets: UIEdgeInsets {
        UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
    }
    
    var body: some View {
        let positionResult = calculateAdjustedPosition()
        
        ZStack {
            popoverBackgroundView
            arrowView(arrowOffsetX: positionResult.arrowOffsetX, arrowOffsetY: positionResult.arrowOffsetY)
            
            HStack(alignment: .top, spacing: theme.spacings.micro) {
                content
                    .background(
                        GeometryReader { geo in
                            Color.clear.preference(key: ContentSizeKey.self, value: geo.size)
                        }
                    )
                    .frame(width: effectiveContentWidth, alignment: .leading)
                
                Button(action: onDismiss) {
                    Image(Logos.close, bundle: .bundleMP)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 20, height: 20)
                        .foregroundColor(theme.colors.icon.secondary)
                }
            }
            .padding(config.contentPadding(from: theme))
            .overlay(contentSizeMeasurer)
        }
        .compositingGroup()
        .shadow(color: Color.black.opacity(0.10), radius: 5, x: 0, y: 0)
        .position(x: positionResult.position.x, y: positionResult.position.y)
        .onPreferenceChange(ContentSizeKey.self) { size in
            if size.width > 0 && size.height > 0 {
                contentSize = size
            }
        }
        .onPreferenceChange(PopoverSizeKey.self) { size in
            if size.width > 0 && size.height > 0 {
                measuredSize = size
            }
        }
    }
    
    // MARK: - Private Views
    
    private var contentSizeMeasurer: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(
                    key: PopoverSizeKey.self,
                    value: geometry.size
                )
        }
    }
    
    private var popoverBackgroundView: some View {
        let borderRadius = config.borderRadius(from: theme)
        let backgroundColor = config.backgroundColor(from: theme)
        
        return RoundedRectangle(cornerRadius: borderRadius)
            .foregroundColor(backgroundColor)
            .frame(
                width: popoverContentWidth,
                height: popoverContentHeight
            )
    }
    
    private func arrowView(arrowOffsetX: CGFloat, arrowOffsetY: CGFloat) -> some View {
        guard config.showArrow,
              config.side.shouldShowArrow() else {
            return AnyView(EmptyView())
        }
        
        let backgroundColor = config.backgroundColor(from: theme)
        let baseArrowOffset = calculateBaseArrowOffset()
        let arrowAngle = getArrowRotationAngle()
        
        let finalOffset = CGPoint(
            x: baseArrowOffset.x + arrowOffsetX,
            y: baseArrowOffset.y + arrowOffsetY
        )
        
        return AnyView(
            ArrowShape()
                .rotation(Angle(radians: arrowAngle))
                .foregroundColor(backgroundColor)
                .frame(width: config.arrowWidth, height: config.arrowHeight)
                .offset(x: finalOffset.x, y: finalOffset.y)
        )
    }
    
    /// Returns the correct rotation angle for the arrow based on popover side.
    /// ArrowShape points UP by default, so we rotate it to point toward the trigger.
    private func getArrowRotationAngle() -> Double {
        switch config.side {
        case .bottom, .bottomLeft, .bottomRight:
            // Popover is below trigger, arrow points UP (no rotation)
            return 0
            
        case .top, .topLeft, .topRight:
            // Popover is above trigger, arrow points DOWN (180°)
            return .pi
            
        case .left:
            // Popover is left of trigger, arrow points RIGHT (90°)
            return .pi / 2
            
        case .right:
            // Popover is right of trigger, arrow points LEFT (270° or -90°)
            return -.pi / 2
            
        case .center:
            return 0
        }
    }
    
    // MARK: - Position Calculations
    
    private struct PositionResult {
        let position: CGPoint
        let arrowOffsetX: CGFloat
        let arrowOffsetY: CGFloat
    }
    
    private func calculateAdjustedPosition() -> PositionResult {
        let margin = config.margin
        let arrowHeight = config.showArrow && config.side.shouldShowArrow() ? config.arrowHeight : 0
        let screenPadding: CGFloat = 8
        
        let screenBounds = UIScreen.main.bounds
        let minX = safeAreaInsets.left + screenPadding
        let maxX = screenBounds.width - safeAreaInsets.right - screenPadding
        let minY = safeAreaInsets.top + screenPadding
        let maxY = screenBounds.height - safeAreaInsets.bottom - screenPadding
        
        var globalX: CGFloat = triggerFrame.midX
        var globalY: CGFloat = triggerFrame.midY
        
        // Define where ARROW TIP should be
        var arrowTipX: CGFloat = triggerFrame.midX  // Always centered on trigger
        var arrowTipY: CGFloat = triggerFrame.midY
        
        switch config.side {
        case .top, .topLeft, .topRight:
            // Arrow tip is `margin` points ABOVE trigger top edge
            arrowTipY = triggerFrame.minY - margin
            
        case .bottom, .bottomLeft, .bottomRight:
            // Arrow tip is `margin` points BELOW trigger bottom edge
            arrowTipY = triggerFrame.maxY + margin
            
        case .left:
            // Arrow tip is `margin` points LEFT of trigger left edge
            arrowTipX = triggerFrame.minX - margin
            arrowTipY = triggerFrame.midY
            
        case .right:
            // Arrow tip is `margin` points RIGHT of trigger right edge
            arrowTipX = triggerFrame.maxX + margin
            arrowTipY = triggerFrame.midY
            
        case .center:
            // No arrow, popover top edge is `margin` points below trigger
            arrowTipY = triggerFrame.maxY + margin
        }

        // Calculate POPOVER CENTER from arrow tip
        switch config.side {
        case .top, .topLeft, .topRight:
            // Arrow at BOTTOM of popover pointing DOWN
            // Arrow tip is BELOW popover center by: height/2 + arrowHeight
            globalY = arrowTipY - popoverContentHeight / 2 - arrowHeight
            
        case .bottom, .bottomLeft, .bottomRight:
            // Arrow at TOP of popover pointing UP
            // Arrow tip is ABOVE popover center by: height/2 + arrowHeight
            globalY = arrowTipY + popoverContentHeight / 2 + arrowHeight
            
        case .left:
            // Arrow at RIGHT of popover pointing RIGHT
            globalX = arrowTipX - popoverContentWidth / 2 - arrowHeight
            globalY = arrowTipY
            
        case .right:
            // Arrow at LEFT of popover pointing LEFT
            globalX = arrowTipX + popoverContentWidth / 2 + arrowHeight
            globalY = arrowTipY
            
        case .center:
            globalY = arrowTipY + popoverContentHeight / 2
        }
     
        //Calculate X position for vertical popovers
        
        // Arrow inset = distance from popover edge to arrow center
        let arrowInset = config.borderRadius(from: theme) + config.arrowWidth
        
        switch config.side {
        case .top, .bottom, .center:
            // Popover centered on trigger - arrow is at center of popover
            globalX = arrowTipX
            
        case .topLeft, .bottomLeft:
            // Arrow near LEFT edge of popover
            // Arrow X offset from popover center = -(popoverWidth/2 - arrowInset)
            // So: popoverCenter = arrowTipX - arrowOffset = arrowTipX + (popoverWidth/2 - arrowInset)
            globalX = arrowTipX + popoverContentWidth / 2 - arrowInset
            
        case .topRight, .bottomRight:
            // Arrow near RIGHT edge of popover
            // Arrow X offset from popover center = +(popoverWidth/2 - arrowInset)
            // So: popoverCenter = arrowTipX - arrowOffset = arrowTipX - (popoverWidth/2 - arrowInset)
            globalX = arrowTipX - popoverContentWidth / 2 + arrowInset
            
        case .left, .right:
            break // Already calculated in STEP 2
        }
        
        let originalGlobalX = globalX
        let originalGlobalY = globalY
        
        let halfWidth = popoverContentWidth / 2
        globalX = max(minX + halfWidth, min(maxX - halfWidth, globalX))
        
        let halfHeight = popoverContentHeight / 2
        globalY = max(minY + halfHeight, min(maxY - halfHeight, globalY))
        
        let arrowOffsetX = originalGlobalX - globalX
        let arrowOffsetY = originalGlobalY - globalY
        
        // Position is in screen coordinates (UIWindow uses screen coords)
        return PositionResult(position: CGPoint(x: globalX, y: globalY), arrowOffsetX: arrowOffsetX, arrowOffsetY: arrowOffsetY)
    }
    
    private func calculateBaseArrowOffset() -> CGPoint {
        let arrowInset = config.borderRadius(from: theme) + config.arrowWidth
        
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0
        
        // X offset - where the arrow sits horizontally on the popover
        switch config.side {
        case .top, .bottom, .center:
            xOffset = 0
            
        case .left:
            xOffset = popoverContentWidth / 2 + config.arrowHeight / 2
            
        case .right:
            xOffset = -(popoverContentWidth / 2 + config.arrowHeight / 2)
            
        case .topLeft, .bottomLeft:
            xOffset = -(popoverContentWidth / 2 - arrowInset)
            
        case .topRight, .bottomRight:
            xOffset = popoverContentWidth / 2 - arrowInset
        }
        
        // Y offset - where the arrow sits vertically on the popover
        switch config.side {
        case .left, .right, .center:
            yOffset = 0
            
        case .top, .topLeft, .topRight:
            yOffset = popoverContentHeight / 2 + config.arrowHeight / 2
            
        case .bottom, .bottomLeft, .bottomRight:
            yOffset = -(popoverContentHeight / 2 + config.arrowHeight / 2)
        }
        
        return CGPoint(x: xOffset, y: yOffset)
    }
}
