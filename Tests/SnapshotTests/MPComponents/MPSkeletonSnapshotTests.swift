//
//  MPSkeletonSnapshotTests.swift
//  MercadoPagoSDK
//

@testable import MPComponents
@testable import MPFoundation
import SnapshotTesting
import SwiftUI
import XCTest

@MainActor
final class MPSkeletonSnapshotTests: XCTestCase {
    // MARK: - Type Variants

    func test_rowType() {
        let view = self.makeTestView {
            MPSkeletonView(type: .row)
                .frame(width: 200, height: 16)
        }
        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(precision: 0.98, size: CGSize(width: 280, height: 80))
        )
    }

    func test_roundedType() {
        let view = self.makeTestView {
            MPSkeletonView(type: .rounded)
                .frame(width: 64, height: 64)
        }
        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(precision: 0.98, size: CGSize(width: 160, height: 160))
        )
    }

    func test_squaredType() {
        let view = self.makeTestView {
            MPSkeletonView(type: .squared)
                .frame(width: 40, height: 40)
        }
        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(precision: 0.98, size: CGSize(width: 120, height: 120))
        )
    }

    // MARK: - Composite Layout

    func test_cardLoadingLayout() {
        let view = self.makeTestView {
            HStack(spacing: 12) {
                MPSkeletonView(type: .rounded)
                    .frame(width: 64, height: 64)
                VStack(alignment: .leading, spacing: 8) {
                    MPSkeletonView(type: .row)
                        .frame(width: 120, height: 14)
                    MPSkeletonView(type: .row)
                        .frame(width: 200, height: 14)
                    MPSkeletonView(type: .row)
                        .frame(width: 80, height: 14)
                }
            }
        }
        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(precision: 0.98, size: CGSize(width: 360, height: 140))
        )
    }

    // MARK: - Animation Moments

    /// Renders fixed shimmer phases instead of sampling the running animation
    /// with wall-clock sleeps, which made the captured frame depend on CI speed.
    func test_shimmerMoments() {
        let moments: [(name: String, phase: CGFloat)] = [
            ("moment_1_start", -1),
            ("moment_2_mid", -0.5),
            ("moment_3_peak", 0)
        ]

        for moment in moments {
            let view = self.makeTestView {
                MPSkeletonView(type: .row)
                    .frame(width: 280, height: 24)
                    .skeletonStyle(MPShimmerSkeletonStyle(fixedPhase: moment.phase))
            }
            assertSnapshot(
                of: UIHostingController(rootView: view),
                as: .image(precision: 0.85, size: CGSize(width: 360, height: 80)),
                named: moment.name
            )
        }
    }

    // MARK: - Helpers

    private func makeTestView(@ViewBuilder content: @escaping () -> some View) -> some View {
        ThemeProvider(light: MPLightTheme(), dark: MPLightTheme()) {
            content()
                .padding(24)
                .background(Color.white)
        }
    }
}
