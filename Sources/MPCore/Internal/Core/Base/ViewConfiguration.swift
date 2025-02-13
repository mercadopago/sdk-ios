//
//  ViewConfiguration.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 14/01/25.
//

/// Protocol that defines the view configuration for Bricks components
@MainActor
package protocol ViewConfiguration: Sendable {
    /// Builds the view hierarchy.
    func buildViewHierarchy()

    /// Configures layout constraints.
    func setupConstraints()

    /// Configures view properties.
    func configureViews()

    /// Configures view styles.
    func configureStyles()

    /// Configures view accessibility.
    func configureAccessibility()

    /// Builds the complete view layout.
    func buildLayout()

    /// Updates the view with property and style configurations.
    func updateView()
}

package extension ViewConfiguration {
    /// Updates the view with property and style configurations.
    func updateView() {
        self.configureViews()
        self.configureStyles()
    }

    /// Builds the complete view layout, including hierarchy, constraints, properties, styles, and accessibility.
    func buildLayout() {
        buildViewHierarchy()
        setupConstraints()
        self.configureViews()
        self.configureStyles()
        self.configureAccessibility()
    }

    /// Configures view properties. Default implementation does nothing.
    func configureViews() {}

    /// Configures view styles. Default implementation does nothing.
    func configureStyles() {}

    /// Configures view accessibility. Default implementation does nothing.
    func configureAccessibility() {}
}
