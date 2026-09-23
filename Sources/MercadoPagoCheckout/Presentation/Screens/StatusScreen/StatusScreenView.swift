//
//  StatusScreenView.swift
//  MercadoPagoSDK
//

import MPComponents
import MPFoundation
import SwiftUI

struct StatusScreenView: View {
    @ObservedObject private var viewModel: StatusScreenViewModel
    private let onBack: @MainActor @Sendable () -> Void
    private let onOpenPDF: @MainActor @Sendable (URL) -> Void
    private let onCopy: @MainActor @Sendable () -> Void
    private let onUnavailable: @MainActor @Sendable () -> Void

    @Environment(\.checkoutTheme) private var theme: MPTheme

    init(
        viewModel: StatusScreenViewModel,
        onBack: @escaping @MainActor @Sendable () -> Void,
        onOpenPDF: @escaping @MainActor @Sendable (URL) -> Void,
        onCopy: @escaping @MainActor @Sendable () -> Void,
        onUnavailable: @escaping @MainActor @Sendable () -> Void
    ) {
        self.viewModel = viewModel
        self.onBack = onBack
        self.onOpenPDF = onOpenPDF
        self.onCopy = onCopy
        self.onUnavailable = onUnavailable
    }

    var body: some View {
        ZStack {
            switch self.viewModel.state {
            case .idle, .loading:
                MPProgressIndicator()
                    .size(.xlarge)
            case let .ready(output):
                StatusScreenContent(
                    output: output,
                    onBack: self.onBack,
                    onOpenPDF: self.onOpenPDF,
                    onCopy: self.onCopy
                )
            case .unavailable:
                Color.clear
                    .onAppear(perform: self.onUnavailable)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(self.theme.colors.background.primary.edgesIgnoringSafeArea(.all))
        .mpTask { await self.viewModel.load() }
    }
}
