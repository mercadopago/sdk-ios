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
    private let onCopy: @MainActor @Sendable () -> Void
    private let onUnavailable: @MainActor @Sendable () -> Void

    @Environment(\.checkoutTheme) private var theme: MPTheme

    init(
        viewModel: StatusScreenViewModel,
        onBack: @escaping @MainActor @Sendable () -> Void,
        onCopy: @escaping @MainActor @Sendable () -> Void,
        onUnavailable: @escaping @MainActor @Sendable () -> Void
    ) {
        self.viewModel = viewModel
        self.onBack = onBack
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
                    isPreparingReceipt: self.viewModel.isPreparingReceipt,
                    onBack: self.onBack,
                    onOpenPDF: self.viewModel.prepareReceipt,
                    onCopy: self.onCopy
                )
            case .unavailable:
                Color.clear
                    .onAppear(perform: self.onUnavailable)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(self.theme.colors.background.primary.edgesIgnoringSafeArea(.all))
        .sheet(item: self.sharedReceipt) { receipt in
            ShareSheet(activityItems: [receipt.url], onCompletion: self.viewModel.finishSharing)
                .mpMediumPresentationDetent()
        }
        .mpTask { await self.viewModel.load() }
        .onDisappear(perform: self.viewModel.cancelReceipt)
    }

    /// Swipe-to-dismiss writes `nil` back; route it through the view model so the temporary PDF is deleted.
    private var sharedReceipt: Binding<StatusScreenViewModel.SharedReceipt?> {
        Binding(
            get: { self.viewModel.sharedReceipt },
            set: { if $0 == nil { self.viewModel.finishSharing() } }
        )
    }
}
