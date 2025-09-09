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
struct TooltipModifier<TooltipContent: View>: ViewModifier {
    
    // MARK: - Environment
    
    /// The current theme providing design system values.
    @Environment(\.checkoutTheme) var theme: MPTheme
    
    // MARK: - Configuration Properties
    
    /// Controls whether the tooltip is currently visible.
    @State var isTooltipEnabled: Bool = false
    
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
        config: TooltipConfig,
        @ViewBuilder content: @escaping () -> TooltipContent
    ) {
        self.tooltipConfiguration = config
        self.tooltipContent = content()
    }

    // MARK: - State Properties

    /// The calculated width of the tooltip content.
    @State private var tooltipContentWidth: CGFloat = 0
    
    /// The calculated height of the tooltip content.
    @State private var tooltipContentHeight: CGFloat = 0
    
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
            return 0
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
            return (geometry.size.width - tooltipContentWidth) / 2
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

        let backgroundColor = tooltipConfiguration.backgroundColor(from: theme)

        return AnyView(
            createArrowShape(angle: arrowAngle)
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
    private func createArrowShape(angle: Double) -> AnyView {
        switch tooltipConfiguration.arrowType {
        case .default:
            let shape = ArrowShape()
                .rotation(Angle(radians: angle))
            
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
        )
    }


    private var mainTooltipView: some View {
        let borderRadius = tooltipConfiguration.borderRadius(from: theme)
        let backgroundColor = tooltipConfiguration.backgroundColor(from: theme)
        let contentPadding = tooltipConfiguration.contentPadding(from: theme)
        
        return GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: borderRadius, style: .circular)
                    .frame(
                        width: tooltipContentWidth,
                        height: tooltipContentHeight
                    )
                    .mask(arrowCutoutMask)
                    .background(
                        RoundedRectangle(cornerRadius: borderRadius)
                            .foregroundColor(backgroundColor)
                    )
                
                ZStack {
                    HStack(alignment: .top) {
                        tooltipContent
                            .frame(
                                maxWidth: tooltipConfiguration.width,
                                maxHeight: tooltipConfiguration.height
                            )
                            .fixedSize(
                                horizontal: tooltipConfiguration.width == nil,
                                vertical: true
                            )
                        
                        Button(action: {
                            isTooltipEnabled.toggle()
                        }) {
                            Image(Logos.close, bundle: .bundleMP)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 20, height: 20)
                                .foregroundColor(theme.colors.textInverted)
                        }
                    }
                }
                .padding(contentPadding)
                .background(contentSizeMeasurer)
                .overlay(tooltipArrowView)
            }
            .offset(
                x: calculateHorizontalOffset(for: geometry),
                y: calculateVerticalOffset(for: geometry)
            )
            .zIndex(tooltipConfiguration.zIndex)
        }
    }


    func body(content: Content) -> some View {
        content
            .onTapGesture {
                isTooltipEnabled.toggle()
            }
            .overlay(isTooltipEnabled ? mainTooltipView.transition(.opacity) : nil)
    }
}


#if DEBUG
import SwiftUI

struct TooltipModifier_Previews: PreviewProvider {
    struct TooltipPreviewHost: View {
        
        // MARK: - State
        
        @State private var showBlueTooltip = true
        @State private var showDarkTooltip = false
        @State private var showAnimatedTooltip = false

        // MARK: - Initializer
        
        public init() {}

        // MARK: - View Body
        
        public var body: some View {
            ThemeProvider(light: MPLightTheme(), dark: MPLightTheme()) {
                VStack(spacing: 20) {
                    VStack {
                        Text("First text")
                            .fontWeight(.semibold)
                        
                        Image(systemName: "info.circle")
                        .font(.title)
                        .foregroundColor(.blue)
                        .tooltip(type: .dark) {
                            Text("É um número de 4 dígitos. Você o encontra na parte da frente do seu cartão ou no app do seu banco ou carteira digital.")
                                .textStyle(.bodySmallRegular(colorType: .inverted))
                        }
                    }
                    
                    VStack {
                        Text("TSecond text")
                            .padding()
                            .cornerRadius(8)
                            .tooltip(type: .dark) {
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
