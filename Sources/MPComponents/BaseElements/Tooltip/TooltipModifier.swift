//
//  TooltipModifier.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 08/09/25.
//


import SwiftUI
import MPFoundation

struct TooltipModifier<TooltipContent: View>: ViewModifier {
    // MARK: - Environment
    @Environment(\.checkoutTheme) var theme: MPTheme
    
    // MARK: - Uninitialised properties
    @Binding var enabled: Bool
    var config: TooltipConfig
    var content: TooltipContent


    // MARK: - Initialisers

    init(
        enabled: Binding<Bool>,
        config: TooltipConfig,
        @ViewBuilder content: @escaping () -> TooltipContent
    ){
        self._enabled = enabled
        self.config = config
        self.content = content()
    }

    // MARK: - Local state

    @State private var contentWidth: CGFloat = 10
    @State private var contentHeight: CGFloat = 10
    
    @State var animationOffset: CGFloat = 0
    @State var animation: Optional<Animation> = nil

    // MARK: - Computed properties

    var showArrow: Bool { config.showArrow && config.side.shouldShowArrow() }
    var actualArrowHeight: CGFloat { self.showArrow ? config.arrowHeight : 0 }

    var arrowOffsetX: CGFloat {
        let borderRadius = config.borderRadius(from: theme)
        let borderWidth = config.borderWidth(from: theme)
        
        switch config.side {
        case .bottom, .center, .top:
            return 40
        case .left:
            return (contentWidth / 2 + config.arrowHeight / 2)
        case .topLeft, .bottomLeft:
            return (contentWidth / 2
                + config.arrowHeight / 2
                - borderRadius / 2
                - borderWidth / 2)
        case .right:
            return -(contentWidth / 2 + config.arrowHeight / 2)
        case .topRight, .bottomRight:
            return -(contentWidth / 2
                + config.arrowHeight / 2
                - borderRadius / 2
                - borderWidth / 2)
        }
    }

    var arrowOffsetY: CGFloat {
        let borderRadius = config.borderRadius(from: theme)
        let borderWidth = config.borderWidth(from: theme)
        
        switch config.side {
        case .left, .center, .right:
            return 0
        case .top:
            return (contentHeight / 2 + config.arrowHeight / 2)
        case .topRight, .topLeft:
            return (contentHeight / 2
                + config.arrowHeight / 2
                - borderRadius / 2
                - borderWidth / 2)
        case .bottom:
            return -(contentHeight / 2 + config.arrowHeight / 2)
        case .bottomLeft, .bottomRight:
            return -(contentHeight / 2
                + config.arrowHeight / 2
                - borderRadius / 2
                - borderWidth / 2)
        }
    }

    // MARK: - Helper functions

    private func offsetHorizontal(_ g: GeometryProxy) -> CGFloat {
        switch config.side {
        case .left, .topLeft, .bottomLeft:
            return -(contentWidth + config.margin + actualArrowHeight + animationOffset)
        case .right, .topRight, .bottomRight:
            return g.size.width + config.margin + actualArrowHeight + animationOffset
        case .top, .center, .bottom:
            return (g.size.width - contentWidth) / 1.35
        }
    }

    private func offsetVertical(_ g: GeometryProxy) -> CGFloat {
        switch config.side {
        case .top, .topRight, .topLeft:
            return -(contentHeight + config.margin + actualArrowHeight + animationOffset)
        case .bottom, .bottomLeft, .bottomRight:
            return g.size.height + config.margin + actualArrowHeight + animationOffset
        case .left, .center, .right:
            return (g.size.height - contentHeight) / 2
        }
    }
    
    // MARK: - Animation stuff
    
    private func dispatchAnimation() {
        if (config.enableAnimation) {
            DispatchQueue.main.asyncAfter(deadline: .now() + config.animationTime) {
                self.animationOffset = config.animationOffset
                self.animation = config.animation
                DispatchQueue.main.asyncAfter(deadline: .now() + config.animationTime*0.1) {
                    self.animationOffset = 0
                    
                    self.dispatchAnimation()
                }
            }
        }
    }

    // MARK: - TooltipModifier Body Properties

    private var sizeMeasurer: some View {
        GeometryReader { g in
            Text("")
                .onAppear {
                    self.contentWidth = config.width ?? g.size.width
                    self.contentHeight = config.height ?? g.size.height
                }
        }
    }

    private var arrowView: some View {
        guard let arrowAngle = config.side.getArrowAngleRadians() else {
            return AnyView(EmptyView())
        }

        let borderColor = config.borderColor(from: theme)
        let backgroundColor = config.backgroundColor(from: theme)

        return AnyView(arrowShape(
            angle: arrowAngle, borderColor: borderColor
        )
        .background(arrowShape(angle: arrowAngle)
        .frame(width: config.arrowWidth, height: config.arrowHeight)
        .foregroundColor(backgroundColor)).frame(width: config.arrowWidth, height: config.arrowHeight)
        .offset(x: CGFloat(Int(self.arrowOffsetX)), y: CGFloat(Int(self.arrowOffsetY))))
    }

    private func arrowShape(angle: Double, borderColor: Color? = nil) -> AnyView {
        switch config.arrowType {
        case .default:
            let shape = ArrowShape()
                .rotation(Angle(radians: angle))
            if let borderColor {
                return AnyView(shape.stroke(borderColor))
            }
            return AnyView(shape)
        }
    }

    private var arrowCutoutMask: some View {
        guard let arrowAngle = config.side.getArrowAngleRadians() else {
            return AnyView(EmptyView())
        }
        
        let borderWidth = config.borderWidth(from: theme)
        
        return AnyView(
            ZStack {
                Rectangle()
                    .frame(
                        width: self.contentWidth + borderWidth * 2,
                        height: self.contentHeight + borderWidth * 2)
                    .foregroundColor(.white)
                Rectangle()
                    .frame(
                        width: config.arrowWidth,
                        height: config.arrowHeight + borderWidth)
                    .rotationEffect(Angle(radians: arrowAngle))
                    .offset(
                        x: self.arrowOffsetX,
                        y: self.arrowOffsetY)
                    .foregroundColor(.black)
            }
            .compositingGroup()
            .luminanceToAlpha()
        )
    }

    var tooltipBody: some View {
        let borderRadius = config.borderRadius(from: theme)
        let borderWidth = config.borderWidth(from: theme)
        let borderColor = config.borderColor(from: theme)
        let backgroundColor = config.backgroundColor(from: theme)
        let shadowColor = config.shadowColor(from: theme)
        let shadowRadius = config.shadowRadius(from: theme)
        let shadowOffset = config.shadowOffset(from: theme)
        let contentPadding = config.contentPadding(from: theme)
        
        return GeometryReader { g in
            ZStack {
                RoundedRectangle(cornerRadius: borderRadius, style: .circular)
                    .stroke(borderWidth == 0 ? Color.clear : borderColor, lineWidth: borderWidth)
                    .frame(width: contentWidth, height: contentHeight)
                    .mask(self.arrowCutoutMask)
                    .background(
                        RoundedRectangle(cornerRadius: borderRadius)
                            .foregroundColor(backgroundColor)
                    )
                    .shadow(color: shadowColor,
                            radius: shadowRadius,
                            x: shadowOffset.x,
                            y: shadowOffset.y)
                
                ZStack {
                    HStack(alignment: .top, spacing: 0) {
                        content
                            .frame(
                                maxWidth: config.width,
                                maxHeight: config.height
                            )
                            .fixedSize(horizontal: config.width == nil, vertical: true)
                            .multilineTextAlignment(.leading)
                            .padding(.trailing, theme.spacings.xs)
                        
                        Button(action: {
                            enabled = false
                        }) {
                            Image(Logos.close, bundle: .bundleMP)
                                .frame(width: 16, height: 16)
                                .foregroundColor(.white)
                        }
                        .padding(.top, -4)
                    }
                    .padding(contentPadding)
                }
                .background(self.sizeMeasurer)
                .overlay(self.arrowView)
            }
            .offset(x: self.offsetHorizontal(g), y: self.offsetVertical(g))
            .animation(self.animation)
            .zIndex(config.zIndex)
            .onAppear {
                self.dispatchAnimation()
            }
        }
    }

    // MARK: - ViewModifier properties

    func body(content: Content) -> some View {
        content
            .overlay(enabled ? tooltipBody.transition(.opacity) : nil)
    }
}


#if DEBUG
import SwiftUI

struct Tooltip_Previews: PreviewProvider {
    struct PreviewHost: View {
        let config1 = DefaultTooltipConfig(side: .top, type: .blue)
        let config2 = DefaultTooltipConfig(side: .top, type: .dark)
        
        @State var enabled1 = true
        @State var enabled2 = false

        public init() {}

        public var body: some View {
            ThemeProvider(light: MPLightTheme(), dark: MPLightTheme()) {
                VStack {
                    HStack {
                        Button(action: {
                            enabled1 = !enabled1
                        }) {
                            Image(systemName: "info.circle")
                                .frame(height: 30)
                        }
                        .tooltip($enabled1, config: config1) {
                            VStack(alignment: .leading) {
                                Text("Title")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Text("Text description.")
                                    .font(.body)
                                    .foregroundColor(.white)
                            }
                        }

                    }
                    .padding(80)
                    
                    HStack {
                        Text("Text 123")
                            .tooltip($enabled2, config: config2) {
                                VStack(alignment: .leading) {
                                    Text("Title")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    
                                    Text("Text description.")
                                        .font(.body)
                                        .foregroundColor(.white)
                                }
                            }
                            .onTapGesture {
                                enabled2 = !enabled2
                            }

                    }
                    .padding(80)
                    
                    
                }
            }
        }
    }
    static var previews: some View {
        Group {
            PreviewHost()
                .previewDisplayName("Light")
        }
    }
}

#endif
