//
//  MPHeaderStyle.swift
//  MPComponents
//
//  Style protocol for MPHeader.
//

import SwiftUI
import MPFoundation

/// A style protocol for `MPHeader` enabling custom skins.
package protocol MPHeaderStyle: StyleProtocol, Identifiable where Configuration == MPHeaderStyleConfiguration {}

/// Default visual style for `MPHeader` using theme tokens.
package struct MPDefaultHeaderStyle: MPHeaderStyle {
    package var id: UUID = .init()
    
    @Environment(\.checkoutTheme) var theme: MPTheme
    
    package init() {}
    
    @MainActor
    package func makeBody(configuration: MPHeaderStyleConfiguration) -> some View {
        VStack(spacing: 0) {
            // Main Header with blur effect and height measurement
            configuration.mainHeader
                .padding(.horizontal, theme.spacings.m)
                .padding(.vertical, theme.spacings.xs)
                .background(headerBackgroundView(configuration))
                .animation(.easeInOut(duration: 0.2))
            
            // Sub Header with collapse animations
            configuration.subHeader
                .padding(.horizontal, theme.spacings.m)
                .padding(.vertical,
                         configuration.subHeaderVisibleHeight > 24 ? theme.spacings.xs : 0
                )
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(
                            key: SubHeaderHeightKey.self,
                            value: geo.size.height
                        )
                    }
                )
                .frame(height: configuration.subHeaderVisibleHeight, alignment: .top)
                .opacity(1 - configuration.collapseProgress)
                .offset(y: -(configuration.subHeaderHeight - configuration.subHeaderVisibleHeight))
                .clipped()
        }
    }
    
    // MARK: - Background with Blur
    
    @ViewBuilder
    private func headerBackgroundView(
        _ configuration: MPHeaderStyleConfiguration
    ) -> some View {
        let epsilon: CGFloat = 0.00001
        
        ZStack {
            if configuration.scrollOffset < -epsilon {
                theme.colors.backgroundPrimary.opacity(0.98)
            } else {
                Color.clear
            }
        }
    }
}

// MARK: - Visual Effect Blur

private struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}

// MARK: - PreferenceKey for Sub-Header Height

private struct SubHeaderHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Style Resolution
package extension MPHeaderStyle {
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedMPHeaderStyle(style: self, configuration: configuration)
    }
}

private struct ResolvedMPHeaderStyle<Style: MPHeaderStyle>: View {
    let style: Style
    let configuration: Style.Configuration
    
    var body: some View {
        style.makeBody(configuration: configuration)
    }
}

// MARK: - Environment
private struct MPHeaderStyleKey: @preconcurrency EnvironmentKey {
    @MainActor static var defaultValue: any MPHeaderStyle = MPDefaultHeaderStyle()
}

extension EnvironmentValues {
    var mpHeaderStyle: any MPHeaderStyle {
        get { self[MPHeaderStyleKey.self] }
        set { self[MPHeaderStyleKey.self] = newValue }
    }
}

package extension View {
    /// Sets the style for `MPHeader` within this view hierarchy.
    ///
    /// - Parameter style: The `MPHeaderStyle` to apply.
    func mpHeaderStyle<S: MPHeaderStyle>(_ style: S) -> some View {
        environment(\.mpHeaderStyle, style)
    }
}


// MARK: - Preview

#if DEBUG
struct MPHeader_Previews: PreviewProvider {
    struct ExampleUsage: View {
        @Environment(\.presentationMode) var presentationMode
        
        var body: some View {
            MPHeader(
                title: "Product Details",
                onBack: {
                    self.presentationMode.wrappedValue.dismiss()
                }
            ) {
                VStack(spacing: 0) {
                    ForEach(0..<30) { i in
                        Text("Line \(i)")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.red))
                            .cornerRadius(8)
                        
                    }
                }
                .padding()
            }
        }
    }
    
    
    static var previews: some View {
        NavigationView {
            MPHeader(
                title: "Product",
                onBack: {
                    print("Back tapped")
                }
            ) {
                VStack(spacing: 20) {
                    ForEach(0..<30) { i in
                        Text("Line \(i)")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.red))
                            .cornerRadius(8)
                        
                        NavigationLink(destination: ExampleUsage()) {
                            Text("Ir para o destino")
                        }
                        
                    }
                }
                .padding()
            }
        }
        .loadMPFonts()
    }
}
#endif
