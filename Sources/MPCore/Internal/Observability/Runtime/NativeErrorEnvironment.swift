import Foundation
import UIKit

package struct NativeErrorEnvironmentSnapshot: Sendable, Equatable {
    package let sdkVersion: String
    package let siteID: String
    package let osVersion: String?
}

package actor NativeErrorEnvironment {
    private var configuration: NativeObservabilityConfiguration?
    private let osVersionProvider: @Sendable () async -> String?

    package init(
        osVersionProvider: @escaping @Sendable () async -> String? = sharedNativeErrorOSVersion
    ) {
        self.osVersionProvider = osVersionProvider
    }

    package func configure(_ configuration: NativeObservabilityConfiguration) {
        self.configuration = configuration
    }

    package func snapshot() async -> NativeErrorEnvironmentSnapshot? {
        guard let configuration else { return nil }
        let osVersion = await osVersionProvider()
        return NativeErrorEnvironmentSnapshot(
            sdkVersion: configuration.sdkVersion,
            siteID: configuration.siteID,
            osVersion: osVersion.flatMap(Self.safeOSVersion)
        )
    }

    private static func safeOSVersion(_ value: String) -> String? {
        guard (1 ... 32).contains(value.utf8.count),
              value.unicodeScalars.allSatisfy({
                  CharacterSet(charactersIn: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz._+-")
                      .contains($0)
              }) else { return nil }
        return value
    }
}

private func sharedNativeErrorOSVersion() async -> String? {
    await MainActor.run { UIDevice.current.systemVersion }
}
