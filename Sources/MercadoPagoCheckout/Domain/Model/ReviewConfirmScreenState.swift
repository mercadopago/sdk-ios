//
//  ReviewConfirmScreenState.swift
//  MercadoPagoSDK
//

/// The review and confirm screen's loading state.
///
/// A standalone type rather than nested in a view model — `ReviewConfirmScreen` and
/// `ReviewConfirmViewModel` are shared between the `Payment` and `CardTransaction` flows, unlike
/// each brick's own `ScreenState`.
enum ReviewConfirmScreenState {
    case loading
    case success(ReviewConfirmOutput)
    case error(MercadoPagoCheckoutError)
}
