//
//  MPIconStyle.swift
//  MercadoPagoSDK
//
//  Created by Codex on 05/02/25.
//

import SwiftUI
import MPFoundation

package protocol MPIconStyle: StyleProtocol, Identifiable where Configuration == MPIconStyleConfiguration {}

package struct MPDefaultIconStyle: MPIconStyle {
    public var id: UUID = .init()
    @Environment(\.checkoutTheme) var theme: MPTheme
    
    public init() {}
    
    @MainActor
    public func makeBody(configuration: MPIconStyleConfiguration) -> some View {
        iconView(for: configuration.source, size: configuration.size, weight: configuration.weight)
            .foregroundColor(configuration.color.color(from: theme))
    }
    
    private func iconView(for source: MPIconSource, size: MPIconSize, weight: MPIconWeight) -> some View {
        let baseView: AnyView
        
        switch source {
        case let .system(name):
            baseView = AnyView(
                Image(systemName: name)
                    .renderingMode(.template)
                    .font(.system(size: size.dimension, weight: weight.fontWeight))
            )
        case let .asset(name):
            baseView = AnyView(
                Image(name, bundle: .bundleMP)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            )
        }
        
        return baseView
            .frame(width: size.dimension, height: size.dimension)
            .accessibility(hidden: true)
    }
}

package extension MPIconStyle {
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedMPIconStyle(style: self, configuration: configuration)
    }
}

private struct ResolvedMPIconStyle<Style: MPIconStyle>: View {
    let style: Style
    let configuration: Style.Configuration
    
    var body: some View {
        style.makeBody(configuration: configuration)
    }
}

private struct MPIconStyleKey: @preconcurrency EnvironmentKey {
    @MainActor
    static var defaultValue: any MPIconStyle = MPDefaultIconStyle()
}

extension EnvironmentValues {
    var mpIconStyle: any MPIconStyle {
        get { self[MPIconStyleKey.self] }
        set { self[MPIconStyleKey.self] = newValue }
    }
}

package extension View {
    func mpIconStyle<S: MPIconStyle>(_ style: S) -> some View {
        environment(\.mpIconStyle, style)
    }
}
