//
//  BottomSheetPresentation+PullBar.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 11/09/25.
//
import UIKit

extension BottomSheetPresentationController {
    /// A view representing the pull bar, typically displayed at the top of the bottom sheet
    /// to indicate draggability.
    final class PullBar: UIView {
        /// Defines the standard visual style and size for the pull bar's indicator.
        private enum Style {
            static let indicatorSize = CGSize(width: 40, height: 5)
        }

        private var gradientLayer: CAGradientLayer?
        private let indicatorView: UIView = UIView()

        /// The appearance configuration for this pull bar instance.
        private let appearance: BottomSheet.Configuration.PullBar.Appearance

        /// Initializes a new `PullBar` view with a specific appearance.
        /// - Parameter appearance: The configuration defining the visual style of the pull bar.
        init(appearance: BottomSheet.Configuration.PullBar.Appearance) {
            self.appearance = appearance
            super.init(frame: .zero)

            indicatorView.frame.size = Style.indicatorSize
            indicatorView.backgroundColor = appearance.indicatorColor
            indicatorView.layer.cornerRadius = appearance.indicatorLineCornerRadius
            
            if let gradientConfig = appearance.gradientBackground {
                self.backgroundColor = .clear
                setupGradientBackground(with: gradientConfig)
            } else {
                self.backgroundColor = appearance.backgroundColor
            }
            
            setupSubviews()
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func setupSubviews() {
            addSubview(indicatorView)
        }

        /// Sets up a gradient background for the pull bar area based on the provided configuration.
        /// - Parameter configuration: The gradient configuration.
        private func setupGradientBackground(
            with configuration: BottomSheet.Configuration.PullBar.Appearance.GradientBackground
        ) {
            gradientLayer = CAGradientLayer()
            guard let gradientLayer = gradientLayer else { return }

            gradientLayer.colors = configuration.colors
            gradientLayer.locations = configuration.locations
            gradientLayer.startPoint = configuration.startPoint
            gradientLayer.endPoint = configuration.endPoint

            layer.insertSublayer(gradientLayer, at: 0)
        }

        public override func layoutSubviews() {
            super.layoutSubviews()

            if bounds.width > 0 && bounds.height > 0 {
                indicatorView.center = CGPoint(x: bounds.midX, y: bounds.midY)
                gradientLayer?.frame = self.bounds
            } else {
                gradientLayer?.frame = .zero
            }
        }
    }
}
