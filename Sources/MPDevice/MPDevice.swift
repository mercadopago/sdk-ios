//
//  MPDevice.swift
//  MercadoPagoSDK
//

import Foundation
#if SWIFT_PACKAGE
    @_exported import MPCore
#endif

/// Primary entry point for device session management with Mercado Pago.
///
/// Use this type to obtain a device session identifier that can be used
/// to improve payment approval rates by identifying the device.
///
/// Example:
/// ```swift
/// let device = MPDevice()
/// let session = try await device.deviceSession()
/// print(session)
/// ```
public final class MPDevice: Sendable {
    private let useCase: DeviceSessionUseCaseProtocol

    public init() {
        let container = CoreDependencyContainer.shared
        let repository = MPDeviceRepository(dependencies: container)
        self.useCase = DeviceSessionUseCase(dependencies: container, repository: repository)
    }

    init(useCase: DeviceSessionUseCaseProtocol) {
        self.useCase = useCase
    }
}

public extension MPDevice {
    // MARK: - Public Functions

    /// Returns a device session for the current device.
    ///
    /// The session can be used alongside payment operations to improve
    /// payment approval rates through device recognition.
    ///
    /// - Returns: An `MPDeviceSession` containing the session identifier.
    /// - Throws: Errors originating from the underlying network request or response decoding.
    func deviceSession() async throws -> MPDeviceSession {
        return try await self.useCase.deviceSession()
    }
}
