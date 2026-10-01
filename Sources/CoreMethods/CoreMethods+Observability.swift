import Foundation
#if SWIFT_PACKAGE
    import MPCore
#endif

extension CoreMethods {
    static func nativeErrorInput(from error: any Error) -> NativeErrorInput {
        if error is CancellationError {
            return .init(type: .requestCancellation, code: .cancelled)
        }
        if let urlError = error as? URLError {
            return .init(urlError: urlError)
        }
        if let coreError = error as? CoreMethodsError {
            switch coreError {
            case .binIsEmpty, .securityCodeInvalid, .cardNumberInvalid, .expirationDateInvalid:
                return .init(type: .validation)
            case .errorGettingEphemeralKey:
                return .init(type: .unknown, code: .unknownError)
            }
        }
        guard let apiError = error as? APIClientError else {
            return .init(type: .unknown, code: .exception)
        }
        return apiError.nativeErrorInput
    }
}
