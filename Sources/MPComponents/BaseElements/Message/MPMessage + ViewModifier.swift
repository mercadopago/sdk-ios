//
//  MPMessage + ViewModifier.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 15/01/26.
//
import SwiftUI
import MPFoundation

struct MPMessageSnackbarModifier: ViewModifier {
    @Binding var isPresented: Bool
    let text: String
    let state: MPMessageState
    let duration: MPMessageDuration

    @State private var hideWorkItem: DispatchWorkItem?
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(messageView)
            .animation(.easeInOut(duration: 0.25), value: isPresented)
    }

    @ViewBuilder
    var messageView: some View {
        if isPresented {
            VStack {
                Spacer()
                MPMessage(
                    message: text,
                    state: state,
                    isPresenting: $isPresented
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .onAppear { scheduleHide() }
                .onDisappear { hideWorkItem?.cancel() }
            }
        }
    }
    private func scheduleHide() {
        hideWorkItem?.cancel()
        guard duration != .indefinite else { return }
        let work = DispatchWorkItem { self.isPresented = false }
        hideWorkItem = work
        let delay: DispatchTime = .now() + .nanoseconds(Int(duration.nanoseconds))
        DispatchQueue.main.asyncAfter(deadline: delay, execute: work)
    }
}

/// Presents a message snackbar over the current view (bottom overlay with animation).
package extension View {

/// - Parameters:
///   - isPresented: Binding for visibility control.
///   - text: Text to display.
///   - state: Visual state (default: `.informative`).
///   - duration: Display duration (default: `.normal`; use `.indefinite`
    func mpMessageSnackbar(
        isPresented: Binding<Bool>,
        text: String,
        state: MPMessageState = .informative,
        duration: MPMessageDuration = .normal
    ) -> some View {
        modifier(
            MPMessageSnackbarModifier(
                isPresented: isPresented,
                text: text,
                state: state,
                duration: duration
            )
        )
    }
}

/// Visual state for `MPMessage`.
/// - informative: Neutral/informational feedback.
/// - posetive: Positive/success feedback.
/// - negative: Error/failure feedback.
/// - caution: Warning/attention feedback.
package enum MPMessageState {
    case informative, positive, negative, caution
}

/// Display duration for `MPMessage`.
/// - short: 3 seconds.
/// - normal: 6 seconds.
/// - long: 10 seconds.
/// - indefinite: Stays visible until the user dismisses.
package enum MPMessageDuration {
    case short, normal, long, indefinite
    var nanoseconds: UInt64 {
        switch self {
        case .short:      return 3_000_000_000
        case .normal:     return 6_000_000_000
        case .long:       return 10_000_000_000
        case .indefinite: return .max
        }
    }
}



