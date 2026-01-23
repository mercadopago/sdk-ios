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
/// The popover is rendered using a dedicated UIWindow to avoid clipping issues.
///
struct PopoverModifier<PopoverContent: View>: ViewModifier {
    
    // MARK: - Environment
    
    @Environment(\.checkoutTheme) var theme: MPTheme
    
    // MARK: - Configuration Properties
    
    /// Controls whether the popover is currently visible.
    @State private var isPopoverVisible: Bool = false
    
    /// The configuration object defining popover behavior and appearance.
    var popoverConfiguration: PopoverConfig
    
    /// The content view displayed inside the popover.
    var popoverContent: PopoverContent

    // MARK: - Initializer

    init(
        config: PopoverConfig,
        @ViewBuilder content: @escaping () -> PopoverContent
    ) {
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
    private var contentSizeMeasurer: some View {
        GeometryReader { geometry in
            Color.clear
                .onAppear {
                    // Size is already constrained by frame(maxWidth:) applied to content
                    self.popoverContentWidth = geometry.size.width
                    self.popoverContentHeight = geometry.size.height
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
                        VStack(alignment: .leading, spacing: 0) {
                            popoverContent
                                .environment(\.popoverVisibility, $isPopoverVisible)
                        }
                        .frame(maxWidth: popoverConfiguration.maxWidth, alignment: .leading)
                        
                        Button(action: {
                            $isPopoverVisible.wrappedValue.toggle()
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
                .fixedSize()
                .padding(contentPadding)
                .background(contentSizeMeasurer)
            }
            .offset(
                x: calculateHorizontalOffset(for: geometry),
                y: calculateVerticalOffset(for: geometry)
            )
        }
    }
    
    // MARK: - Body
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            let currentFrame = geo.frame(in: .global)
                            
                            PopoverWindowManager.shared.show(
                                triggerFrame: currentFrame,
                                config: popoverConfiguration,
                                theme: theme,
                                onDismiss: { $isPopoverVisible.wrappedValue = false }
                            ) {
                                popoverContent
                                    .environment(\.popoverVisibility, $isPopoverVisible)
                            }
                            $isPopoverVisible.wrappedValue = true
                        }
                }
            )
    }
}


// MARK: - Environment support for popover visibility control
private struct PopoverVisibilityKey: EnvironmentKey {
    static let defaultValue: Binding<Bool>? = nil
}

extension EnvironmentValues {
    /// Binding that allows popover content to control its own visibility.
    var popoverVisibility: Binding<Bool>? {
        get { self[PopoverVisibilityKey.self] }
        set { self[PopoverVisibilityKey.self] = newValue }
    }
}

#if DEBUG
import SwiftUI

struct PopoverModifier_Previews: PreviewProvider {
    struct PopoverPreviewHost: View {
        public init() {}
        
        let config: PopoverConfig = DefaultPopoverConfig(side: .bottom, type: .white)
        
        let config2: PopoverConfig = DefaultPopoverConfig(side: .right, type: .white, maxWidth: 100)
        
        let topConfig: PopoverConfig = DefaultPopoverConfig(side: .top, type: .white)
        
        let topLeft: PopoverConfig = DefaultPopoverConfig(side: .topLeft, type: .white)
        
        let topRight: PopoverConfig = DefaultPopoverConfig(side: .topRight, type: .white)
        
        let bottomConfig: PopoverConfig = DefaultPopoverConfig(side: .bottom, type: .white)
        
        let bottomLeft: PopoverConfig = DefaultPopoverConfig(side: .bottomLeft, type: .white)
        
        let bottomRight: PopoverConfig = DefaultPopoverConfig(side: .bottomRight, type: .white)
        
        let leftConfig: PopoverConfig = DefaultPopoverConfig(side: .left, type: .white, maxWidth: 80)
        
        let rightConfig: PopoverConfig = DefaultPopoverConfig(side: .right, type: .white, maxWidth: 80)
        
        
        public var body: some View {
            ThemeProvider(light: MPLightTheme(), dark: MPLightTheme()) {
                VStack(spacing: 20) {
                    VStack {
                        MPTextField(
                            text: .constant("Security Code"),
                            label: MPStrings.CardForm.CVV.label,
                            placeholder: MPStrings.CardForm.CVV.placeholderDefault,
                            keyboard: .numberPad,
                            suffix: {
                                Image(systemName: "questionmark.circle")
                                    .renderingMode(.template)
                                    .foregroundColor(.black)
                                    .padding(.horizontal)
                                    .popover(type: .white) {
                                        Text("É um número de 4 dígitos. Você o encontra na parte da frente do seu cartão.")
                                            .textStyle(.bodyMedium(colorType: .secondary))
                                    }
                            }
                        )
                        Text("First text")
                            .fontWeight(.semibold)
                        
                        Image(systemName: "info.circle")
                            .font(.title)
                            .foregroundColor(.blue)
                            .popover(config: config) {
                                Text("Test")
                                    .textStyle(.bodyMedium(colorType: .secondary))
                            }
                    }
                    
                    VStack {
                        HStack {
                            Text("Second text")
                                .padding()
                                .cornerRadius(8)
                                .popover(config: config2) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Blue Theme")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .textStyle(.bodyMediumTitle(colorType: .secondary))
                                            .foregroundColor(.white)
                                        
                                        Text("This popover uses the Blue theme for better contrast.")
                                            .textStyle(.bodyMedium(colorType: .secondary))
                                            .foregroundColor(.primary)
                                    }
                                }
                            Spacer()
                            Text("Third text")
                                .padding()
                                .cornerRadius(8)
                            Image(systemName: "info.circle")
                                .font(.title)
                                .foregroundColor(.blue)
                                .popover(type: .white) {
                                    Text("É um número de 4 dígitos. Você o encontra na parte da frente do seu cartão.")
                                        .textStyle(.bodyMedium(colorType: .secondary))
                                }
                        }
                    }
                    Text("Top")
                        .fontWeight(.semibold)
                        .popover(config: topConfig) {
                            Text("É um número de 4 dígitos. Você o encontra na parte da frente do seu cartão.")
                        }
                    
                    Text("Top Left")
                        .fontWeight(.semibold)
                        .popover(config: topLeft) {
                            Text("É um número de 4 dígitos. Você o encontra na parte da frente do seu cartão.")
                        }
                    
                    Text("Top Right")
                        .fontWeight(.semibold)
                        .popover(config: topRight) {
                            Text("É um número de 4 dígitos. Você o encontra na parte da frente do seu cartão.")
                        }
                    
                    Text("Bottom")
                        .fontWeight(.semibold)
                        .popover(config: bottomConfig) {
                            Text("É um número de 4 dígitos. Você o encontra na parte da frente do seu cartão.")
                        }
                    
                    Text("Bottom Left")
                        .fontWeight(.semibold)
                        .popover(config: bottomLeft) {
                            Text("É um número de 4 dígitos. Você o encontra na parte da frente do seu cartão.")
                        }
                    
                    Text("Bottom Right")
                        .fontWeight(.semibold)
                        .popover(config: bottomRight) {
                            Text("É um número de 4 dígitos. Você o encontra na parte da frente do seu cartão.")
                        }
                    
                    Text("Left")
                        .fontWeight(.semibold)
                        .popover(config: leftConfig) {
                            Text("É um número de 4 dígitos. Você o encontra na parte da frente do seu cartão.")
                        }
                    
                    Text("Right")
                        .fontWeight(.semibold)
                        .popover(config: rightConfig) {
                            Text("É um número de 4 dígitos. Você o encontra na parte da frente do seu cartão.")
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
