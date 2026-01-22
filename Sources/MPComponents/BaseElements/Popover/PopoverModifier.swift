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
    private var externalPopoverEnabled: Binding<Bool>?
    @State private var internalPopoverEnabled: Bool
    
    @State private var triggerFrame: CGRect = .zero
    
    /// The configuration object defining popover behavior and appearance.
    var popoverConfiguration: PopoverConfig
    
    /// The content view displayed inside the popover.
    var popoverContent: PopoverContent

    // MARK: - Initializers

    init(
        isPopoverEnabled: Binding<Bool>,
        config: PopoverConfig,
        @ViewBuilder content: @escaping () -> PopoverContent
    ) {
        self.externalPopoverEnabled = isPopoverEnabled
        self._internalPopoverEnabled = State(initialValue: false)
        self.popoverConfiguration = config
        self.popoverContent = content()
    }

    /// Initializes a popover using internal state (no external binding required).
    init(
        config: PopoverConfig,
        isPopoverEnabled: Bool = false,
        @ViewBuilder content: @escaping () -> PopoverContent
    ) {
        self.externalPopoverEnabled = nil
        self._internalPopoverEnabled = State(initialValue: isPopoverEnabled)
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
                            .environment(\.popoverVisibility, resolvedPopoverBinding)
                            .frame(
                                maxWidth: popoverConfiguration.width,
                                maxHeight: popoverConfiguration.height
                            )
                            .fixedSize(
                                horizontal: popoverConfiguration.width == nil,
                                vertical: true
                            )
                        
                        Button(action: {
                            resolvedPopoverBinding.wrappedValue.toggle()
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
        let screen = UIScreen.main.bounds
        
        // Offset para mover o overlay do trigger até o canto (0,0) da tela
        let offsetX = -triggerFrame.minX + screen.width / 2
        let offsetY = -triggerFrame.minY + screen.height / 2

        return content
            .captureTriggerFrame { triggerFrame = $0 }
            .onTapGesture { resolvedPopoverBinding.wrappedValue.toggle() }
            .overlay(
                Group {
                    if resolvedPopoverBinding.wrappedValue {
                        Color.red.opacity(0.1)
                            .contentShape(Rectangle())
                            .frame(width: screen.width, height: screen.height)
                            .position(x: offsetX, y: offsetY)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture { resolvedPopoverBinding.wrappedValue = false }

                        mainPopoverView.transition(.opacity)
                            .zIndex(1000)
                    }
                }
            )
    }
}

private struct TriggerFrameKey: PreferenceKey {
    static let defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) { value = nextValue() }
}

private extension View {
    func captureTriggerFrame(_ onChange: @escaping (CGRect) -> Void) -> some View {
        background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: TriggerFrameKey.self, value: geo.frame(in: .global))
            }
        )
        .onPreferenceChange(TriggerFrameKey.self, perform: onChange)
    }
}

// MARK: - Private helpers
private extension PopoverModifier {
    var resolvedPopoverBinding: Binding<Bool> {
        externalPopoverEnabled ?? $internalPopoverEnabled
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
        @State private var isTexfieldEnable: Bool = false
        @State private var isThirdEnable: Bool = false
        public init() {}
        
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
                                    .onTapGesture {
                                        isTexfieldEnable.toggle()
                                    }
                                    .popover(isPopoverEnabled: $isTexfieldEnable) {
                                        Text("test")
                                    }
                            }
                        )
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
                        HStack {
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
                            Spacer()
                            Text("Third text")
                                .padding()
                                .cornerRadius(8)
                            Image(systemName: "info.circle")
                                .font(.title)
                                .foregroundColor(.blue)
                                .onTapGesture {
                                    isThirdEnable.toggle()
                                }
                                .popover(isPopoverEnabled: $isThirdEnable, type: .white) {
                                    Text("É um número de 4 dígitos. Você o encontra na parte da frente do seu cartão.")
                                        .textStyle(.bodyMedium(colorType: .inverted))
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
