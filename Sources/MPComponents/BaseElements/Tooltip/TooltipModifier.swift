//
//  TooltipModifier.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 08/09/25.
//

import SwiftUI
import MPFoundation

/// A view modifier that adds tooltip functionality to SwiftUI views.
///
/// `TooltipModifier` handles the positioning, styling, animation, and interaction
/// logic for tooltips. It automatically calculates optimal positioning based on
/// the target view's geometry and the configured tooltip side.
///
/// ## Usage
///
/// This modifier is typically used through the `View.tooltip()` extension methods
/// rather than directly. However, it can be applied manually when needed:
///
/// ```swift
/// Text("Target view")
///     .modifier(TooltipModifier(
///         enabled: $showTooltip,
///         config: DefaultTooltipConfig(),
///         content: { Text("Tooltip content") }
///     ))
/// ```
///
/// ## Implementation Details
///
/// The modifier uses geometry readers to calculate precise positioning and employs
/// overlays to render tooltips above the target view. Arrow positioning is mathematically
/// calculated based on the tooltip side and content dimensions.
struct TooltipModifier<TooltipContent: View>: ViewModifier {
    
    // MARK: - Environment
    
    /// The current theme providing design system values.
    @Environment(\.checkoutTheme) var theme: MPTheme
    
    // MARK: - Configuration Properties
    
    /// Controls whether the tooltip is currently visible.
    @Binding var isTooltipEnabled: Bool
    
    /// The configuration object defining tooltip behavior and appearance.
    var tooltipConfiguration: TooltipConfig
    
    /// The content view displayed inside the tooltip.
    var tooltipContent: TooltipContent

    // MARK: - Initializers

    /// Creates a new tooltip modifier with the specified configuration.
    ///
    /// - Parameters:
    ///   - enabled: A binding that controls tooltip visibility.
    ///   - config: The configuration object defining tooltip behavior.
    ///   - content: A closure that creates the tooltip's content view.
    init(
        enabled: Binding<Bool>,
        config: TooltipConfig,
        @ViewBuilder content: @escaping () -> TooltipContent
    ) {
        self._isTooltipEnabled = enabled
        self.tooltipConfiguration = config
        self.tooltipContent = content()
    }

    // MARK: - State Properties

    /// The calculated width of the tooltip content.
    @State private var tooltipContentWidth: CGFloat = 10
    
    /// The calculated height of the tooltip content.
    @State private var tooltipContentHeight: CGFloat = 10
    
    /// The current animation offset for movement effects.
    @State private var currentAnimationOffset: CGFloat = 0
    
    /// The current animation configuration being applied.
    @State private var currentAnimation: Optional<Animation> = nil

    // MARK: - Computed Properties

    /// Determines whether the arrow should be visible based on configuration and positioning.
    private var shouldDisplayArrow: Bool { 
        tooltipConfiguration.showArrow && tooltipConfiguration.side.shouldShowArrow() 
    }
    
    /// The effective arrow height, accounting for visibility settings.
    private var effectiveArrowHeight: CGFloat { 
        shouldDisplayArrow ? tooltipConfiguration.arrowHeight : 0 
    }

    /// Calculates the horizontal arrow offset based on tooltip positioning.
    ///
    /// This computed property determines the arrow's horizontal position relative to the tooltip
    /// center, taking into account border radius and width for corner positioning adjustments.
    private var arrowHorizontalOffset: CGFloat {
        let borderRadius = tooltipConfiguration.borderRadius(from: theme)
        let borderWidth = tooltipConfiguration.borderWidth(from: theme)
        
        switch tooltipConfiguration.side {
        case .bottom, .center, .top:
            return 40
        case .left:
            return (tooltipContentWidth / 2 + tooltipConfiguration.arrowHeight / 2)
        case .topLeft, .bottomLeft:
            return (tooltipContentWidth / 2
                + tooltipConfiguration.arrowHeight / 2
                - borderRadius / 2
                - borderWidth / 2)
        case .right:
            return -(tooltipContentWidth / 2 + tooltipConfiguration.arrowHeight / 2)
        case .topRight, .bottomRight:
            return -(tooltipContentWidth / 2
                + tooltipConfiguration.arrowHeight / 2
                - borderRadius / 2
                - borderWidth / 2)
        }
    }

    /// Calculates the vertical arrow offset based on tooltip positioning.
    ///
    /// This computed property determines the arrow's vertical position relative to the tooltip
    /// center, taking into account border radius and width for corner positioning adjustments.
    private var arrowVerticalOffset: CGFloat {
        let borderRadius = tooltipConfiguration.borderRadius(from: theme)
        let borderWidth = tooltipConfiguration.borderWidth(from: theme)
        
        switch tooltipConfiguration.side {
        case .left, .center, .right:
            return 0
        case .top:
            return (tooltipContentHeight / 2 + tooltipConfiguration.arrowHeight / 2)
        case .topRight, .topLeft:
            return (tooltipContentHeight / 2
                + tooltipConfiguration.arrowHeight / 2
                - borderRadius / 2
                - borderWidth / 2)
        case .bottom:
            return -(tooltipContentHeight / 2 + tooltipConfiguration.arrowHeight / 2)
        case .bottomLeft, .bottomRight:
            return -(tooltipContentHeight / 2
                + tooltipConfiguration.arrowHeight / 2
                - borderRadius / 2
                - borderWidth / 2)
        }
    }

    // MARK: - Positioning Helper Methods

    /// Calculates the horizontal offset for tooltip positioning.
    ///
    /// This method determines where to horizontally position the tooltip relative to its target view,
    /// taking into account the tooltip side, margins, arrow height, and current animation offset.
    ///
    /// - Parameter geometry: The geometry of the target view.
    /// - Returns: The horizontal offset in points.
    private func calculateHorizontalOffset(for geometry: GeometryProxy) -> CGFloat {
        switch tooltipConfiguration.side {
        case .left, .topLeft, .bottomLeft:
            return -(tooltipContentWidth + tooltipConfiguration.margin + effectiveArrowHeight + currentAnimationOffset)
        case .right, .topRight, .bottomRight:
            return geometry.size.width + tooltipConfiguration.margin + effectiveArrowHeight + currentAnimationOffset
        case .top, .center, .bottom:
            return (geometry.size.width - tooltipContentWidth) / 1.35
        }
    }

    /// Calculates the vertical offset for tooltip positioning.
    ///
    /// This method determines where to vertically position the tooltip relative to its target view,
    /// taking into account the tooltip side, margins, arrow height, and current animation offset.
    ///
    /// - Parameter geometry: The geometry of the target view.
    /// - Returns: The vertical offset in points.
    private func calculateVerticalOffset(for geometry: GeometryProxy) -> CGFloat {
        switch tooltipConfiguration.side {
        case .top, .topRight, .topLeft:
            return -(tooltipContentHeight + tooltipConfiguration.margin + effectiveArrowHeight + currentAnimationOffset)
        case .bottom, .bottomLeft, .bottomRight:
            return geometry.size.height + tooltipConfiguration.margin + effectiveArrowHeight + currentAnimationOffset
        case .left, .center, .right:
            return (geometry.size.height - tooltipContentHeight) / 2
        }
    }
    
    // MARK: - Animation Management
    
    /// Initiates the continuous animation cycle for the tooltip.
    ///
    /// This method creates a repeating animation sequence that provides subtle movement
    /// to draw attention to the tooltip. The animation alternates between the configured
    /// offset and zero, creating a gentle "breathing" or "floating" effect.
    ///
    /// The animation only runs when enabled in the configuration and continues until
    /// the tooltip is dismissed or animations are disabled.
    private func startAnimationCycle() {
        guard tooltipConfiguration.enableAnimation else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + tooltipConfiguration.animationTime) {
            self.currentAnimationOffset = self.tooltipConfiguration.animationOffset
            self.currentAnimation = self.tooltipConfiguration.animation
            
            DispatchQueue.main.asyncAfter(deadline: .now() + self.tooltipConfiguration.animationTime * 0.1) {
                self.currentAnimationOffset = 0
                self.startAnimationCycle()
            }
        }
    }

    // MARK: - View Components

    /// A geometry reader that measures and stores the tooltip content dimensions.
    ///
    /// This view is used as an overlay to determine the actual size of the tooltip content,
    /// which is then used for precise positioning calculations.
    private var contentSizeMeasurer: some View {
        GeometryReader { geometry in
            Text("")
                .onAppear {
                    self.tooltipContentWidth = self.tooltipConfiguration.width ?? geometry.size.width
                    self.tooltipContentHeight = self.tooltipConfiguration.height ?? geometry.size.height
                }
        }
    }

    /// Creates the arrow view with proper styling and positioning.
    ///
    /// This computed property generates the tooltip's pointing arrow, including both
    /// the stroke (border) and fill layers. The arrow is positioned and rotated based
    /// on the tooltip's side configuration.
    ///
    /// - Returns: A view containing the styled arrow, or an empty view if no arrow is needed.
    private var tooltipArrowView: some View {
        guard let arrowAngle = tooltipConfiguration.side.getArrowAngleRadians() else {
            return AnyView(EmptyView())
        }

        let borderColor = tooltipConfiguration.borderColor(from: theme)
        let backgroundColor = tooltipConfiguration.backgroundColor(from: theme)

        return AnyView(
            createArrowShape(angle: arrowAngle, borderColor: borderColor)
                .background(
                    createArrowShape(angle: arrowAngle)
                        .frame(width: tooltipConfiguration.arrowWidth, height: tooltipConfiguration.arrowHeight)
                        .foregroundColor(backgroundColor)
                )
                .frame(width: tooltipConfiguration.arrowWidth, height: tooltipConfiguration.arrowHeight)
                .offset(
                    x: CGFloat(Int(arrowHorizontalOffset)), 
                    y: CGFloat(Int(arrowVerticalOffset))
                )
        )
    }

    /// Creates an arrow shape with the specified angle and optional border color.
    ///
    /// This method generates the appropriate arrow shape based on the configuration's
    /// arrow type and applies the necessary rotation and styling.
    ///
    /// - Parameters:
    ///   - angle: The rotation angle for the arrow in radians.
    ///   - borderColor: Optional border color for the arrow stroke.
    /// - Returns: A view containing the styled arrow shape.
    private func createArrowShape(angle: Double, borderColor: Color? = nil) -> AnyView {
        switch tooltipConfiguration.arrowType {
        case .default:
            let shape = ArrowShape()
                .rotation(Angle(radians: angle))
            
            if let borderColor = borderColor {
                return AnyView(shape.stroke(borderColor))
            }
            return AnyView(shape)
        }
    }

    /// Creates a mask that cuts out the arrow area from the tooltip border.
    ///
    /// This computed property generates a composited mask that allows the arrow to appear
    /// as if it's seamlessly connected to the tooltip body by removing the border where
    /// the arrow connects.
    ///
    /// - Returns: A view used as a mask to create the arrow cutout effect.
    private var arrowCutoutMask: some View {
        guard let arrowAngle = tooltipConfiguration.side.getArrowAngleRadians() else {
            return AnyView(EmptyView())
        }
        
        let borderWidth = tooltipConfiguration.borderWidth(from: theme)
        
        return AnyView(
            ZStack {
                Rectangle()
                    .frame(
                        width: tooltipContentWidth + borderWidth * 2,
                        height: tooltipContentHeight + borderWidth * 2
                    )
                    .foregroundColor(.white)
                
                Rectangle()
                    .frame(
                        width: tooltipConfiguration.arrowWidth,
                        height: tooltipConfiguration.arrowHeight + borderWidth
                    )
                    .rotationEffect(Angle(radians: arrowAngle))
                    .offset(x: arrowHorizontalOffset, y: arrowVerticalOffset)
                    .foregroundColor(.black)
            }
            .compositingGroup()
            .luminanceToAlpha()
        )
    }

    /// The main tooltip view containing content, styling, and positioning logic.
    ///
    /// This computed property creates the complete tooltip view including:
    /// - Background with border and shadow
    /// - Content layout with close button
    /// - Arrow attachment
    /// - Precise positioning relative to target view
    ///
    /// The view uses geometry readers for dynamic positioning and applies all
    /// configured styling from the theme system.
    private var mainTooltipView: some View {
        let borderRadius = tooltipConfiguration.borderRadius(from: theme)
        let borderWidth = tooltipConfiguration.borderWidth(from: theme)
        let borderColor = tooltipConfiguration.borderColor(from: theme)
        let backgroundColor = tooltipConfiguration.backgroundColor(from: theme)
        let shadowColor = tooltipConfiguration.shadowColor(from: theme)
        let shadowRadius = tooltipConfiguration.shadowRadius(from: theme)
        let shadowOffset = tooltipConfiguration.shadowOffset(from: theme)
        let contentPadding = tooltipConfiguration.contentPadding(from: theme)
        
        return GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: borderRadius, style: .circular)
                    .stroke(borderWidth == 0 ? Color.clear : borderColor, lineWidth: borderWidth)
                    .frame(width: tooltipContentWidth, height: tooltipContentHeight)
                    .mask(arrowCutoutMask)
                    .background(
                        RoundedRectangle(cornerRadius: borderRadius)
                            .foregroundColor(backgroundColor)
                    )
                    .shadow(
                        color: shadowColor,
                        radius: shadowRadius,
                        x: shadowOffset.x,
                        y: shadowOffset.y
                    )
                
                ZStack {
                    HStack(alignment: .top, spacing: 0) {
                        tooltipContent
                            .frame(
                                maxWidth: tooltipConfiguration.width,
                                maxHeight: tooltipConfiguration.height
                            )
                            .fixedSize(horizontal: tooltipConfiguration.width == nil, vertical: true)
                            .multilineTextAlignment(.leading)
                            .padding(.trailing, theme.spacings.xs)
                        
                        Button(action: {
                            isTooltipEnabled = false
                        }) {
                            Image(Logos.close, bundle: .bundleMP)
                                .frame(width: 16, height: 16)
                                .foregroundColor(.white)
                        }
                        .padding(.top, -4)
                    }
                    .padding(contentPadding)
                }
                .background(contentSizeMeasurer)
                .overlay(tooltipArrowView)
            }
            .offset(
                x: calculateHorizontalOffset(for: geometry),
                y: calculateVerticalOffset(for: geometry)
            )
            .animation(currentAnimation)
            .zIndex(tooltipConfiguration.zIndex)
            .onAppear {
                startAnimationCycle()
            }
        }
    }

    // MARK: - ViewModifier Implementation

    /// The main body method required by the `ViewModifier` protocol.
    ///
    /// This method applies the tooltip overlay to the target view when enabled.
    /// The tooltip appears with a fade transition for smooth user experience.
    ///
    /// - Parameter content: The target view that will display the tooltip.
    /// - Returns: The content view with tooltip overlay applied when enabled.
    func body(content: Content) -> some View {
        content
            .overlay(isTooltipEnabled ? mainTooltipView.transition(.opacity) : nil)
    }
}


#if DEBUG
import SwiftUI

/// Preview provider for tooltip functionality testing and demonstration.
struct TooltipModifier_Previews: PreviewProvider {
    /// Host view containing multiple tooltip examples for testing different configurations.
    struct TooltipPreviewHost: View {
        // MARK: - Configuration Examples
        
        let blueTopTooltipConfig = DefaultTooltipConfig(side: .bottom, type: .blue)
        let darkBottomTooltipConfig = DefaultTooltipConfig(side: .bottom, type: .dark)
        
        var animatedTooltipConfig: DefaultTooltipConfig {
            var config = DefaultTooltipConfig(side: .right, type: .blue)
            config.enableAnimation = true
            return config
        }
        
        // MARK: - State
        
        @State private var showBlueTooltip = true
        @State private var showDarkTooltip = false
        @State private var showAnimatedTooltip = false

        // MARK: - Initializer
        
        public init() {}

        // MARK: - View Body
        
        public var body: some View {
            ThemeProvider(light: MPLightTheme(), dark: MPLightTheme()) {
                VStack(spacing: 60) {
                    // Basic blue tooltip example
                    VStack {
                        Text("Blue Tooltip Example")
                            .fontWeight(.semibold)
                        
                        Button(action: {
                            showBlueTooltip.toggle()
                        }) {
                            Image(systemName: "info.circle")
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                        .tooltip($showBlueTooltip, config: blueTopTooltipConfig) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Informational Tooltip")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Text("This tooltip")
                                    .font(.body)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    
                    // Dark tooltip example
                    VStack {
                        Text("Dark Tooltip Example")
                            .fontWeight(.semibold)
                        
                        Text("Tap to show tooltip")
                            .padding()
                            .cornerRadius(8)
                            .tooltip($showDarkTooltip, config: darkBottomTooltipConfig) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Dark Theme")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    
                                    Text("This tooltip uses the dark theme for better contrast.")
                                        .font(.body)
                                        .foregroundColor(.white)
                                }
                            }
                            .onTapGesture {
                                showDarkTooltip.toggle()
                            }
                    }
                    
                    // Animated tooltip example
                    VStack {
                        Text("Animated Tooltip Example")
                            .fontWeight(.semibold)
                        
                        Button(action: {
                            showAnimatedTooltip.toggle()
                        }) {
                            Text("Toggle Animated Tooltip")
                                .padding()
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(8)
                        }
                        .tooltip($showAnimatedTooltip, config: animatedTooltipConfig) {
                            Text("This tooltip has animation enabled!")
                                .font(.body)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(40)
            }
        }
    }
    
    static var previews: some View {
        Group {
            TooltipPreviewHost()
                .previewDisplayName("Tooltip Examples")
        }
    }
}

#endif
