//
//  MPIcon.swift
//  MercadoPagoSDK
//
//  Created by Codex on 05/02/25.
//

import SwiftUI
import UIKit

package enum MPRemoteImagePhase {
    case loading
    case success(Image)
    case failure
}

package struct MPIcon: View {
    private let source: MPIconSource
    private let size: MPIconSize
    private let color: MPIconColor
    private let weight: MPIconWeight
    private let isDecorative: Bool

    @Environment(\.mpIconStyle) private var style: any MPIconStyle
    @State private var remotePhase: MPRemoteImagePhase = .loading
    @State private var loadTask: Task<Void, Never>?

    private static let cache = NSCache<NSURL, UIImage>()

    package init(
        source: MPIconSource,
        size: MPIconSize = .medium,
        color: MPIconColor = .primary,
        weight: MPIconWeight = .regular,
        isDecorative: Bool = false
    ) {
        self.source = source
        self.size = size
        self.color = color
        self.weight = weight
        self.isDecorative = isDecorative
    }

    package init(
        systemName: String,
        size: MPIconSize = .medium,
        color: MPIconColor = .primary,
        weight: MPIconWeight = .regular,
        isDecorative: Bool = false
    ) {
        self.init(
            source: .system(name: systemName),
            size: size,
            color: color,
            weight: weight,
            isDecorative: isDecorative
        )
    }

    package init(
        assetName: String,
        size: MPIconSize = .medium,
        color: MPIconColor = .primary,
        weight: MPIconWeight = .regular,
        isDecorative: Bool = false
    ) {
        self.init(
            source: .asset(name: assetName),
            size: size,
            color: color,
            weight: weight,
            isDecorative: isDecorative
        )
    }

    package var body: some View {
        let configuration = MPIconStyleConfiguration(
            source: source,
            size: size,
            color: color,
            weight: weight,
            remoteImagePhase: source.isRemote ? self.remotePhase : nil
        )

        AnyView(
            self.style.resolve(configuration: configuration)
        )
        .onAppear {
            guard case let .remote(url) = source else { return }
            self.loadTask = Task { await self.loadRemoteImage(url: url) }
        }
        .onDisappear {
            self.loadTask?.cancel()
            self.loadTask = nil
        }
    }

    @MainActor
    private func loadRemoteImage(url: URL?) async {
        guard let url else {
            self.remotePhase = .failure
            return
        }
        let nsURL = url as NSURL
        if let cached = Self.cache.object(forKey: nsURL) {
            self.remotePhase = .success(Image(uiImage: cached))
            return
        }
        self.remotePhase = .loading
        do {
            let data = try await fetchData(from: url)
            guard !Task.isCancelled else { return }
            if let uiImage = UIImage(data: data) {
                Self.cache.setObject(uiImage, forKey: nsURL)
                self.remotePhase = .success(Image(uiImage: uiImage))
            } else {
                self.remotePhase = .failure
            }
        } catch {
            guard !Task.isCancelled else { return }
            self.remotePhase = .failure
        }
    }

    private func fetchData(from url: URL) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let data {
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                }
            }.resume()
        }
    }
}

#if DEBUG
    private let visaURL = URL(string: "https://http2.mlstatic.com/storage/mobile-on-demand-resources//image/brick-payment-method-visa_3X")

    #Preview("Remote — thumbnailFlag") {
        HStack(spacing: 16) {
            MPIcon(source: .remote(url: visaURL))
                .mpIconStyle(.thumbnailFlag)

            MPIcon(source: .remote(url: nil))
                .mpIconStyle(.thumbnailFlag)

            MPIcon(source: .system(name: "creditcard"))
                .mpIconStyle(.thumbnailFlag)
        }
        .padding()
    }

    #Preview("Remote — default style") {
        HStack(spacing: 16) {
            MPIcon(source: .remote(url: visaURL))
            MPIcon(source: .system(name: "creditcard"))
        }
        .padding()
    }
#endif
