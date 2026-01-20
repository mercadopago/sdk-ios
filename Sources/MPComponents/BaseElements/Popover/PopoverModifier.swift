//
//  PopoverModifier.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 08/09/25.
//

import SwiftUI
import MPFoundation

/// A view modifier that adds popover functionality to SwiftUI views.
///
/// `PopoverModifier` handles the positioning, styling, animation, and interaction
/// logic for popovers. It automatically calculates optimal positioning based on
/// the target view's geometry and the configured popover side.
///
struct PopoverModifier<PopoverContent: View>: ViewModifier {
    
    // MARK: - Environment
    
    @Environment(\.checkoutTheme) var theme: MPTheme
    
    // MARK: - Configuration Properties
    
    /// Controls whether the popover is currently visible.
    @State var isPopoverEnabled: Bool = false
    
    /// The configuration object defining popover behavior and appearance.
    var popoverConfiguration: PopoverConfig
    
    /// The content view displayed inside the popover.
    var popoverContent: PopoverContent

    // MARK: - Initializers

    init(
        isPopoverEnabled: Bool = false,
        config: PopoverConfig,
        @ViewBuilder content: @escaping () -> PopoverContent
    ) {
        self.isPopoverEnabled = isPopoverEnabled
        self.popoverConfiguration = config
        self.popoverContent = content()
    }

    // MARK: - State Properties

    /// The calculated width of the popover content.
    @State private var popoverContentWidth: CGFloat = 0
    
    /// The calculated height of the popover content.
    @State private var popoverContentHeight: CGFloat = 0
    
    /// The current animation offset for movement effects.
    @State private var currentAnimationOffset: CGFloat = 0

    // MARK: - Computed Properties

    /// Determines whether the arrow should be visible based on configuration and positioning.
    private var shouldDisplayArrow: Bool { 
        popoverConfiguration.showArrow && popoverConfiguration.side.shouldShowArrow() 
    }
    
    /// The effective arrow height, accounting for visibility settings.
    private var effectiveArrowHeight: CGFloat { 
        shouldDisplayArrow ? popoverConfiguration.arrowHeight : 0 
    }

    /// Calculates the horizontal arrow offset based on popover positioning.
    private var arrowHorizontalOffset: CGFloat {
        let borderRadius = popoverConfiguration.borderRadius(from: theme)
        let borderWidth = popoverConfiguration.borderWidth(from: theme)
        
        switch popoverConfiguration.side {
        case .bottom, .center, .top:
            return 0
        case .left:
            return (popoverContentWidth / 2 + popoverConfiguration.arrowHeight / 2)
        case .topLeft, .bottomLeft:
            return (popoverContentWidth / 2
                + popoverConfiguration.arrowHeight / 2
                - borderRadius / 2
                - borderWidth / 2)
        case .right:
            return -(popoverContentWidth / 2 + popoverConfiguration.arrowHeight / 2)
        case .topRight, .bottomRight:
            return -(popoverContentWidth / 2
                + popoverConfiguration.arrowHeight / 2
                - borderRadius / 2
                - borderWidth / 2)
        }
    }

    /// Calculates the vertical arrow offset based on popover positioning.
    private var arrowVerticalOffset: CGFloat {
        let borderRadius = popoverConfiguration.borderRadius(from: theme)
        let borderWidth = popoverConfiguration.borderWidth(from: theme)
        
        switch popoverConfiguration.side {
        case .left, .center, .right:
            return 0
        case .top:
            return (popoverContentHeight / 2 + popoverConfiguration.arrowHeight / 2)
        case .topRight, .topLeft:
            return (popoverContentHeight / 2
                + popoverConfiguration.arrowHeight / 2
                - borderRadius / 2
                - borderWidth / 2)
        case .bottom:
            return -(popoverContentHeight / 2 + popoverConfiguration.arrowHeight / 2)
        case .bottomLeft, .bottomRight:
            return -(popoverContentHeight / 2
                + popoverConfiguration.arrowHeight / 2
                - borderRadius / 2
                - borderWidth / 2)
        }
    }

    // MARK: - Positioning Helper Methods

    /// Calculates the horizontal offset for popover positioning.
    private func calculateHorizontalOffset(for geometry: GeometryProxy) -> CGFloat {
        switch popoverConfiguration.side {
        case .left, .topLeft, .bottomLeft:
            return -(popoverContentWidth + popoverConfiguration.margin + effectiveArrowHeight + currentAnimationOffset)
        case .right, .topRight, .bottomRight:
            return geometry.size.width + popoverConfiguration.margin + effectiveArrowHeight + currentAnimationOffset
        case .top, .center, .bottom:
            return (geometry.size.width - popoverContentWidth) / 2
        }
    }

    /// Calculates the vertical offset for popover positioning.
    private func calculateVerticalOffset(for geometry: GeometryProxy) -> CGFloat {
        switch popoverConfiguration.side {
        case .top, .topRight, .topLeft:
            return -(popoverContentHeight + popoverConfiguration.margin + effectiveArrowHeight + currentAnimationOffset)
        case .bottom, .bottomLeft, .bottomRight:
            return geometry.size.height + popoverConfiguration.margin + effectiveArrowHeight + currentAnimationOffset
        case .left, .center, .right:
            return (geometry.size.height - popoverContentHeight) / 2
        }
    }

    // MARK: - View Components

    /// A geometry reader that measures and stores the popover content dimensions.
    ///
    /// This view is used as an overlay to determine the actual size of the popover content,
    /// which is then used for precise positioning calculations.
    private var contentSizeMeasurer: some View {
        GeometryReader { geometry in
            Color.clear
                .onAppear {
                    self.popoverContentWidth = self.popoverConfiguration.width ?? geometry.size.width
                    self.popoverContentHeight = self.popoverConfiguration.height ?? geometry.size.height
                }
        }
    }

    /// Creates the arrow view with proper styling and positioning.
    private var popoverArrowView: some View {
        guard let arrowAngle = popoverConfiguration.side.getArrowAngleRadians() else {
            return AnyView(EmptyView())
        }

        let backgroundColor = popoverConfiguration.backgroundColor(from: theme)

        return AnyView(
            createArrowShape(angle: arrowAngle)
                .background(
                    createArrowShape(angle: arrowAngle)
                        .frame(width: popoverConfiguration.arrowWidth, height: popoverConfiguration.arrowHeight)
                        .foregroundColor(backgroundColor)
                )
                .frame(width: popoverConfiguration.arrowWidth, height: popoverConfiguration.arrowHeight)
                .offset(
                    x: CGFloat(Int(arrowHorizontalOffset)), 
                    y: CGFloat(Int(arrowVerticalOffset))
                )
                .accessibility(hidden: true)
        )
    }

    /// Creates an arrow shape with the specified angle and optional border color.
    private func createArrowShape(angle: Double) -> AnyView {
        
        switch popoverConfiguration.arrowType {
        case .default:
            let shape = ArrowShape()
                .rotation(Angle(radians: angle))
                .foregroundColor(popoverConfiguration.backgroundColor(from: theme))
            
            return AnyView(shape)
        }
    }

    /// Creates a mask that cuts out the arrow area from the popover border.
    private var arrowCutoutMask: some View {
        guard let arrowAngle = popoverConfiguration.side.getArrowAngleRadians() else {
            return AnyView(EmptyView())
        }
        
        let borderWidth = popoverConfiguration.borderWidth(from: theme)
        
        return AnyView(
            ZStack {
                Rectangle()
                    .frame(
                        width: popoverContentWidth + borderWidth * 2,
                        height: popoverContentHeight + borderWidth * 2
                    )
                    .foregroundColor(.white)
                
                Rectangle()
                    .frame(
                        width: popoverConfiguration.arrowWidth,
                        height: popoverConfiguration.arrowHeight + borderWidth
                    )
                    .rotationEffect(Angle(radians: arrowAngle))
                    .offset(x: arrowHorizontalOffset, y: arrowVerticalOffset)
                    .foregroundColor(.black)
            }
        )
    }
    
    var popoverView: some View {
        let borderRadius = popoverConfiguration.borderRadius(from: theme)
        let backgroundColor = popoverConfiguration.backgroundColor(from: theme)
        
        return ZStack {
            RoundedRectangle(
                cornerRadius: borderRadius, style: .circular
            )
            .stroke(lineWidth: 0)
            .frame(
                width: popoverContentWidth,
                height: popoverContentHeight
            )
            .mask(arrowCutoutMask)
            .background(
                RoundedRectangle(cornerRadius: borderRadius)
                    .foregroundColor(backgroundColor)
            )
            
            popoverArrowView
        }
        .compositingGroup()
        .shadow(color: Color.black.opacity(0.10), radius: 5, x: 0, y: 0)
    }

    private var mainPopoverView: some View {
        let contentPadding = popoverConfiguration.contentPadding(from: theme)
        
        return GeometryReader { geometry in
            ZStack {
                popoverView
                
                ZStack {
                    HStack(alignment: .top) {
                        popoverContent
                            .frame(
                                maxWidth: popoverConfiguration.width,
                                maxHeight: popoverConfiguration.height
                            )
                            .fixedSize(
                                horizontal: popoverConfiguration.width == nil,
                                vertical: true
                            )
                        
                        Button(action: {
                            isPopoverEnabled.toggle()
                        }) {
                            Image(Logos.close, bundle: .bundleMP)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 20, height: 20)
                                .foregroundColor(theme.colors.text.inverse)
                        }
                    }
                }
                .padding(contentPadding)
                .background(contentSizeMeasurer)
            }
            .offset(
                x: calculateHorizontalOffset(for: geometry),
                y: calculateVerticalOffset(for: geometry)
            )
            .zIndex(popoverConfiguration.zIndex)
        }
    }

    func body(content: Content) -> some View {
        content
            .onTapGesture {
                isPopoverEnabled.toggle()
            }
            .overlay(isPopoverEnabled ? mainPopoverView.transition(.opacity) : nil)
    }
}

#if DEBUG
import SwiftUI

struct PopoverModifier_Previews: PreviewProvider {
    struct PopoverPreviewHost: View {
        public init() {}
        
        public var body: some View {
            ThemeProvider(light: MPLightTheme(), dark: MPLightTheme()) {
                VStack(spacing: 20) {
                    VStack {
                        Text("First text")
                            .fontWeight(.semibold)
                        
                        Image(systemName: "info.circle")
                            .font(.title)
                            .foregroundColor(.blue)
                            .popover(type: .white) {
                                Text("É um número de 4 dígitos. Você o encontra na parte da frente do seu cartão.")
                                    .textStyle(.bodyMedium(colorType: .inverted))
                            }
                    }
                    
                    VStack {
                        Text("Second text")
                            .padding()
                            .cornerRadius(8)
                            .popover(type: .white) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Blue Theme")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    
                                    Text("This popover uses the Blue theme for better contrast.")
                                        .font(.body)
                                        .foregroundColor(.white)
                                }
                            }
                    }
                    
                }
                .padding(40)
            }
        }
    }
    
    static var previews: some View {
        Group {
            PopoverPreviewHost()
                .previewDisplayName("Popover Examples")
        }
    }
}

#endif
