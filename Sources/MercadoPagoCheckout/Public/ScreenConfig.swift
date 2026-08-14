//
//  ScreenConfig.swift
//  MercadoPagoSDK
//

/// An optional screen the integrator opted into, along with the configuration it carries.
///
/// The builder appends one case per `withXxx` call and the resulting list is both the source of
/// truth for in-flow navigation decisions and the origin of the `screens` query parameter sent to
/// the backend.
enum ScreenConfig: Sendable {
    case reviewAndConfirm(seller: MPSellerInfo?, onEmailChangeRequested: (@MainActor @Sendable () -> Void)?)
}

extension ScreenConfig {
    func toScreen() -> MPScreen {
        switch self {
        case .reviewAndConfirm: return .reviewAndConfirm
        }
    }
}
