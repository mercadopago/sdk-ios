//
//  SnackbarWindowPresenter.swift
//  MercadoPagoSDK
//
import MPComponents
import SwiftUI
import UIKit

@MainActor
enum SnackbarWindowPresenter {
    private static var overlayWindow: UIWindow?
    private static var cleanupTask: DispatchWorkItem?

    static func show(
        message: String,
        state: MPMessageState = .negative,
        lightTheme: MPTheme,
        darkTheme: MPTheme
    ) {
        // Waits for the brick's modal dismiss animation to complete (~0.35s default)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.present(message: message, state: state, lightTheme: lightTheme, darkTheme: darkTheme)
        }
    }

    private static func present(
        message: String,
        state: MPMessageState,
        lightTheme: MPTheme,
        darkTheme: MPTheme
    ) {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) else { return }

        let window = PassthroughWindow(windowScene: windowScene)
        window.windowLevel = .alert + 1
        window.backgroundColor = .clear
        self.overlayWindow = window

        let view = SnackbarOverlayView(
            message: message,
            state: state,
            lightTheme: lightTheme,
            darkTheme: darkTheme,
            onDismiss: { self.dismiss() }
        )

        let hostingController = UIHostingController(rootView: view)
        hostingController.view.backgroundColor = .clear
        window.rootViewController = hostingController
        window.makeKeyAndVisible()

        // Safety cleanup after snackbar duration + buffer
        let cleanup = DispatchWorkItem { self.dismiss() }
        self.cleanupTask = cleanup
        DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: cleanup)
    }

    private static func dismiss() {
        self.cleanupTask?.cancel()
        self.cleanupTask = nil
        // Waits for the snackbar fade-out animation (0.25s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.overlayWindow?.isHidden = true
            self.overlayWindow = nil
        }
    }
}

// MARK: - PassthroughWindow

private final class PassthroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event) else { return nil }
        // If only the transparent background was hit, pass touch through to the seller's app
        // If a snackbar subview was hit, consume the touch
        return hitView === rootViewController?.view ? nil : hitView
    }
}

// MARK: - SnackbarOverlayView

private struct SnackbarOverlayView: View {
    let message: String
    let state: MPMessageState
    let lightTheme: MPTheme
    let darkTheme: MPTheme
    let onDismiss: () -> Void

    @State private var isPresented = true

    var body: some View {
        ThemeProvider(light: self.lightTheme, dark: self.darkTheme) {
            Color.clear
                .allowsHitTesting(false)
                .messageSnackbar(
                    isPresented: self.$isPresented,
                    text: self.message,
                    state: self.state,
                    duration: .short
                )
        }
        .mpOnChange(of: self.isPresented) { presented in
            if !presented { self.onDismiss() }
        }
    }
}
