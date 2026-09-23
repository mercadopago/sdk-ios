//
//  MPThumbnailCircleIconStyle.swift
//  MPComponents
//

import MPFoundation
import SwiftUI

package struct MPThumbnailCircleIconStyle: MPIconStyle {
    package var id: UUID = .init()

    @Environment(\.checkoutTheme) private var theme: MPTheme

    package init() {}

    @MainActor
    package func makeBody(configuration: MPIconStyleConfiguration) -> some View {
        self.iconContent(for: configuration)
            .aspectRatio(contentMode: .fit)
            .padding(self.theme.spacings.micro)
            .frame(width: self.theme.spacings.large, height: self.theme.spacings.large)
            .clipShape(Circle())
            .overlay(
                Circle().strokeBorder(self.theme.colors.border.primary, lineWidth: self.theme.borderWidth.medium)
            )
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
