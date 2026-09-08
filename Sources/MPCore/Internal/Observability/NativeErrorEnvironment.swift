import Foundation

package struct NativeErrorEnvironmentSnapshot: Sendable, Equatable {
    package let sdkVersion: String
    package let siteID: String
    package let osVersion: String?
}

package final class NativeErrorEnvironment: @unchecked Sendable {
    private let lock = NSLock()
    private var current: NativeErrorEnvironmentSnapshot?
    private let osVersionProvider: @Sendable () -> String?

    package init(osVersionProvider: @escaping @Sendable () -> String? = systemNativeErrorOSVersion) {
        self.osVersionProvider = osVersionProvider
    }

    package func configure(sdkVersion: String, country: MercadoPagoSDK.Country) {
        let snapshot = NativeErrorEnvironmentSnapshot(
            sdkVersion: sdkVersion,
            siteID: NativeErrorSiteMapper.siteID(for: country),
            osVersion: osVersionProvider().flatMap(Self.safeOSVersion)
        )
        lock.withLock { current = snapshot }
    }

    package func snapshot() -> NativeErrorEnvironmentSnapshot? {
        lock.withLock { current }
    }

    private static func safeOSVersion(_ value: String) -> String? {
        guard (1...32).contains(value.utf8.count),
              value.unicodeScalars.allSatisfy({
                  CharacterSet(charactersIn: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz._+-")
                      .contains($0)
              }) else { return nil }
        return value
    }
}

private func systemNativeErrorOSVersion() -> String? {
    let version = ProcessInfo.processInfo.operatingSystemVersion
    return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
}

private extension NSLock {
    func withLock<T>(_ body: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try body()
    }
}
