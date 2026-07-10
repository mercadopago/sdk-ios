//
//  MPSkeletonStyle.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 27/05/26.
//

import MPFoundation
import SwiftUI

// MARK: - Protocol

package protocol MPSkeletonStyle: StyleProtocol, Identifiable where Configuration == MPSkeletonStyleConfiguration {}

// MARK: - Default Style

package struct MPShimmerSkeletonStyle: MPSkeletonStyle {
    package var id: UUID = .init()

    @Environment(\.checkoutTheme) var theme: MPTheme
    @State private var phase: CGFloat = -1

    private var shimmerStops: [Gradient.Stop] {
        let color = self.theme.colors.background.primary
        return [
            .init(color: color.opacity(0), location: 0.000),
            .init(color: color.opacity(0.2), location: 0.239),
            .init(color: color.opacity(0.8), location: 0.499),
            .init(color: color.opacity(0.2), location: 0.739),
            .init(color: color.opacity(0), location: 0.999)
        ]
    }

    @MainActor
    package func makeBody(configuration: MPSkeletonStyleConfiguration) -> some View {
        GeometryReader { geo in
            self.theme.colors.background.secondary
                .overlay(
                    LinearGradient(stops: self.shimmerStops, startPoint: .leading, endPoint: .trailing)
                        .frame(width: geo.size.width * 3)
                        .offset(x: self.phase * geo.size.width * 2)
                        .blur(radius: 17)
                )
                .clipped()
        }
        .clipShape(self.clipShape(for: configuration.type))
        .accessibility(hidden: true)
        .mpTask {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                self.phase = 1
            }
        }
    }

    private func clipShape(for type: MPSkeletonView.SkeletonType) -> RoundedRectangle {
        switch type {
        case .row: RoundedRectangle(cornerRadius: self.theme.borderRadius.small)
        case .rounded: RoundedRectangle(cornerRadius: self.theme.borderRadius.full)
        case .squared: RoundedRectangle(cornerRadius: self.theme.borderRadius.medium)
        }
    }
}

// MARK: - Environment

struct MPSkeletonStyleKey: EnvironmentKey {
    static let defaultValue: any MPSkeletonStyle = MPShimmerSkeletonStyle()
}

extension EnvironmentValues {
    var mpSkeletonStyle: any MPSkeletonStyle {
        get { self[MPSkeletonStyleKey.self] }
        set { self[MPSkeletonStyleKey.self] = newValue }
    }
}

extension View {
    func skeletonStyle(_ style: some MPSkeletonStyle) -> some View {
        environment(\.mpSkeletonStyle, style)
    }
}

// MARK: - Style Resolution

package extension MPSkeletonStyle {
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedMPSkeletonStyle(style: self, configuration: configuration)
    }
}

private struct ResolvedMPSkeletonStyle<Style: MPSkeletonStyle>: View {
    let style: Style
    let configuration: Style.Configuration

    var body: some View {
        self.style.makeBody(configuration: self.configuration)
    }
}
