//
//  MPThumbnailFlagIconStyle.swift
//  MPComponents
//

import MPFoundation
import SwiftUI

package struct MPThumbnailFlagIconStyle: MPIconStyle {
    package var id: UUID = .init()

    @Environment(\.checkoutTheme) private var theme: MPTheme
    private let backgroundColor: Color?

    package init(backgroundColor: Color? = nil) {
        self.backgroundColor = backgroundColor
    }

    @MainActor
    package func makeBody(configuration: MPIconStyleConfiguration) -> some View {
        self.iconContent(for: configuration)
            .aspectRatio(contentMode: .fill)
            .frame(width: 44, height: 32)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    @ViewBuilder
    private func iconContent(for config: MPIconStyleConfiguration) -> some View {
        switch config.source {
        case .remote:
            switch config.remoteImagePhase {
            case let .success(image):
                image
                    .resizable()
                    .scaledToFit()
            default:
                self.theme.colors.icon.primary.opacity(0.1)
            }

        case let .system(name):
            Image(systemName: name)
                .resizable()
                .scaledToFit()

        case let .asset(name):
            Image(name, bundle: .bundleMP)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
        }
    }
}
