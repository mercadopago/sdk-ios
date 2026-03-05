//
//  MPProgressViewStyle.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 04/03/26.
//
import SwiftUI
import MPFoundation

// MARK: - Size

package enum MPProgressIndicatorSize: Sendable {
    case xsmall
    case small
    case medium
    case large
    case xlarge

    var diameter: CGFloat {
        switch self {
        case .xsmall: return 16
        case .small: return 24
        case .medium: return 32
        case .large: return 48
        case .xlarge: return 64
        }
    }

    var lineWidth: CGFloat {
        switch self {
        case .xsmall: return 2
        case .small: return 2
        case .medium: return 3
        case .large: return 4
        case .xlarge: return 4
        }
    }
}

// MARK: - Size Environment

private struct MPProgressViewIndicatorKey: EnvironmentKey {
    static let defaultValue: MPProgressIndicatorSize = .medium
}

extension EnvironmentValues {
    var mpProgressIndicatorSize: MPProgressIndicatorSize {
        get { self[MPProgressViewIndicatorKey.self] }
        set { self[MPProgressViewIndicatorKey.self] = newValue }
    }
}

package extension View {
    func size(_ size: MPProgressIndicatorSize) -> some View {
        environment(\.mpProgressIndicatorSize, size)
    }
}

// MARK: - Style Protocol

package protocol MPProgressIndicatorStyle: StyleProtocol, Identifiable where Configuration == MPProgressIndicatorStyleConfiguration {}

// MARK: - Indeterminate Style

package struct MPIndeterminateProgressViewStyle: MPProgressIndicatorStyle {
    package var id: UUID = .init()

    @Environment(\.checkoutTheme) var theme: MPTheme
    @State private var pathStart: Double = 0
    @State private var pathEnd: Double = 0.01
    @State private var spinRotation: Double = 0
    @State private var rotationTask: Task<Void, Never>?
    @State private var pathTask: Task<Void, Never>?

    package init() {}

    @MainActor
    package func makeBody(configuration: MPProgressIndicatorStyleConfiguration) -> some View {
        Circle()
            .trim(from: pathStart, to: pathEnd)
            .stroke(
                theme.colors.border.accent,
                style: StrokeStyle(lineWidth: configuration.size.lineWidth, lineCap: .round)
            )
            .rotationEffect(.degrees(spinRotation - 90))
            .frame(width: configuration.size.diameter, height: configuration.size.diameter)
        .onAppear {
            rotationTask = Task { await runRotationLoop() }
            pathTask = Task { await runPathLoop() }
        }
        .onDisappear {
            rotationTask?.cancel()
            pathTask?.cancel()
        }
    }

    @MainActor
    private func runRotationLoop() async {
        while !Task.isCancelled {
            spinRotation = 0
            withAnimation(.linear(duration: 2)) {
                spinRotation = 360
            }
            try? await Task.sleep(nanoseconds: 2_000_000_000)
        }
    }

    @MainActor
    private func runPathLoop() async {
        while !Task.isCancelled {
            pathStart = 0
            pathEnd = 0.01
            withAnimation(.easeInOut(duration: 0.75)) {
                pathStart = 0.25
                pathEnd = 1.0
            }
            try? await Task.sleep(nanoseconds: 750_000_000)
            withAnimation(.easeInOut(duration: 0.75)) {
                pathStart = 1.0
            }
            try? await Task.sleep(nanoseconds: 750_000_000)
        }
    }
}

// MARK: - Style Resolution

package extension MPProgressIndicatorStyle {
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedMPProgressViewStyle(style: self, configuration: configuration)
    }
}

private struct ResolvedMPProgressViewStyle<Style: MPProgressIndicatorStyle>: View {
    let style: Style
    let configuration: Style.Configuration

    var body: some View {
        style.makeBody(configuration: configuration)
    }
}

// MARK: - Style Environment

private struct MPProgressViewStyleKey: @preconcurrency EnvironmentKey {
    @MainActor
    static var defaultValue: any MPProgressIndicatorStyle = MPIndeterminateProgressViewStyle()
}

extension EnvironmentValues {
    var mpProgressViewStyle: any MPProgressIndicatorStyle {
        get { self[MPProgressViewStyleKey.self] }
        set { self[MPProgressViewStyleKey.self] = newValue }
    }
}

package extension View {
    func mpProgressViewStyle<S: MPProgressIndicatorStyle>(_ style: S) -> some View {
        environment(\.mpProgressViewStyle, style)
    }
}
