//
//  MPIconStyle.swift
//  MercadoPagoSDK
//
//  Created by Codex on 05/02/25.
//

import MPFoundation
import SwiftUI

package protocol MPIconStyle: StyleProtocol, Identifiable where Configuration == MPIconStyleConfiguration {}

package struct MPDefaultIconStyle: MPIconStyle {
    public var id: UUID = .init()
    @Environment(\.checkoutTheme) var theme: MPTheme

    public init() {}

    @MainActor
    public func makeBody(configuration: MPIconStyleConfiguration) -> some View {
        self.iconContent(for: configuration)
            .frame(width: configuration.size.dimension, height: configuration.size.dimension)
            .foregroundColor(configuration.color.color(from: self.theme))
            .accessibility(hidden: true)
    }

    @ViewBuilder
    private func iconContent(for configuration: MPIconStyleConfiguration) -> some View {
        switch configuration.source {
        case let .system(name):
            Image(systemName: name)
                .renderingMode(.template)
                .font(.system(size: configuration.size.dimension, weight: configuration.weight.fontWeight))
        case let .asset(name):
            Image(name, bundle: .bundleMP)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
        case .remote:
            if case let .success(image) = configuration.remoteImagePhase {
                image.resizable().aspectRatio(contentMode: .fit)
            } else {
                Color.gray.opacity(0.1)
            }
        }
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
        self.style.makeBody(configuration: self.configuration)
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
    func mpIconStyle(_ style: some MPIconStyle) -> some View {
        environment(\.mpIconStyle, style)
    }
}

package extension MPIconStyle where Self == MPThumbnailFlagIconStyle {
    static var thumbnailFlag: MPThumbnailFlagIconStyle { .init() }
}

package extension MPIconStyle where Self == MPThumbnailCircleIconStyle {
    static var thumbnailCircle: MPThumbnailCircleIconStyle { .init() }
}

// MARK: - Thumbnail style (composable via the view hierarchy)

/// Icon style applied to `MPListItem`'s `.thumbnail` leading. Set it up the hierarchy with
/// `.mpThumbnailStyle(_:)`; defaults to `.thumbnailFlag`, so existing consumers are unaffected.
private struct MPThumbnailStyleKey: @preconcurrency EnvironmentKey {
    @MainActor
    static var defaultValue: any MPIconStyle = MPThumbnailFlagIconStyle()
}

extension EnvironmentValues {
    var mpThumbnailStyle: any MPIconStyle {
        get { self[MPThumbnailStyleKey.self] }
        set { self[MPThumbnailStyleKey.self] = newValue }
    }
}

package extension View {
    /// Sets the thumbnail icon style for `MPListItem`s below in the hierarchy (e.g. `.thumbnailCircle`).
    func mpThumbnailStyle(_ style: some MPIconStyle) -> some View {
        environment(\.mpThumbnailStyle, style)
    }
}
