//
//  BottomSheet+Configuration.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 11/09/25.
//
import UIKit
import CoreGraphics 

package extension BottomSheet {

    /// Defines the complete set of configurations for the appearance, behavior,
    /// and interaction of a bottom sheet.
    struct Configuration: Sendable {

        // MARK: - Nested Types for Specific Configurations

        /// Specifies the configuration for the pull bar displayed at the top of the bottom sheet.
        /// The pull bar typically indicates draggability.
        package enum PullBar: Sendable {
            /// Defines the visual appearance of the pull bar.
            package struct Appearance: Sendable {
                /// Defines the properties for a gradient background.
                /// If applied to the pull bar, this overrides any solid `backgroundColor`.
                package struct GradientBackground: Sendable {
                    /// An array of `CGColor` defining the gradient stops.
                    public let colors: [CGColor]
                    /// An array of `NSNumber` (values between 0 and 1) defining the location of each gradient stop.
                    /// If `nil`, the stops are spaced uniformly.
                    public let locations: [NSNumber]?
                    /// The start point of the gradient, in the unit coordinate space.
                    /// Defaults to `(x: 0.5, y: 0.0)` (top center).
                    public let startPoint: CGPoint
                    /// The end point of the gradient, in the unit coordinate space.
                    /// Defaults to `(x: 0.5, y: 1.0)` (bottom center).
                    public let endPoint: CGPoint

                    /// Initializes a new gradient background configuration.
                    /// - Parameters:
                    ///   - colors: An array of `CGColor` for the gradient.
                    ///   - locations: Optional array of `NSNumber` for gradient stop locations.
                    ///   - startPoint: The start point of the gradient.
                    ///   - endPoint: The end point of the gradient.
                    package init(
                        colors: [CGColor],
                        locations: [NSNumber]? = nil,
                        startPoint: CGPoint = CGPoint(x: 0.5, y: 0.0),
                        endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0)
                    ) {
                        self.colors = colors
                        self.locations = locations
                        self.startPoint = startPoint
                        self.endPoint = endPoint
                    }

                    /// A default gradient fading from opaque white at the top to transparent white at the bottom.
                    /// The opaque white portion extends for 70% of the height before fading.
                    package static let defaultWhiteToTransparent: GradientBackground = .init(
                        colors: [
                            UIColor.white.cgColor,
                            UIColor.white.cgColor,
                            UIColor.white.withAlphaComponent(0.0).cgColor
                        ],
                        locations: [0.0, 0.7, 1.0]
                    )
                }

                /// The total height of the pull bar view.
                package let height: CGFloat
                /// The color of the small, pill-shaped indicator line within the pull bar.
                package let indicatorColor: UIColor
                /// The background color of the pull bar area. This is ignored if `gradientBackground` is set.
                package let backgroundColor: UIColor
                /// The corner radius of the pull bar's indicator line.
                /// Defaults to `height / 2` of the indicator itself, creating a pill shape.
                package let indicatorLineCornerRadius: CGFloat // Renomeado de indicatorCornerRadius para clareza
                /// Optional configuration for a gradient background for the pull bar area.
                /// If `nil`, the solid `backgroundColor` is used.
                package let gradientBackground: GradientBackground?

                /// Initializes a new pull bar appearance configuration.
                /// - Parameters:
                ///   - height: The total height of the pull bar view.
                ///   - indicatorColor: The color of the drag indicator line. Defaults to `UIColor.gray.withAlphaComponent(0.6)`.
                ///   - backgroundColor: The solid background color for the pull bar area. Defaults to `.clear`.
                ///   - indicatorLineCornerRadius: The corner radius for the drag indicator line. If `nil`, defaults to half of the indicator's standard height (which is 4pt, so radius 2pt).
                ///   - gradientBackground: Optional configuration for a gradient background. Defaults to `nil`.
                package init(
                    height: CGFloat,
                    indicatorColor: UIColor = UIColor.gray.withAlphaComponent(0.6),
                    backgroundColor: UIColor = .clear,
                    indicatorLineCornerRadius: CGFloat? = nil, 
                    gradientBackground: GradientBackground? = nil
                ) {
                    self.height = height
                    self.indicatorColor = indicatorColor
                    self.backgroundColor = backgroundColor
                    self.indicatorLineCornerRadius = indicatorLineCornerRadius ?? 2.0
                    self.gradientBackground = gradientBackground
                }

                /// Default appearance for the pull bar: 20pt height, gray indicator, clear background, no gradient.
                public static let `default`: Appearance = Appearance(height: 20.0)
                
                /// An example appearance for the pull bar featuring a white-to-transparent gradient.
                public static let `defaultWithGradient`: Appearance = Appearance(
                    height: 30.0,
                    gradientBackground: .defaultWhiteToTransparent
                )
            }

            /// The pull bar is not visible.
            case hidden
            /// The pull bar is visible with the specified `Appearance`.
            case visible(Appearance)

            /// Default pull bar configuration: visible with default appearance (no gradient).
            public static let `default`: PullBar = .visible(.default)
        }

        /// Specifies the configuration for the shadow or dimming view displayed behind the bottom sheet.
        package struct Shadow: Sendable {
            /// The background color of the dimming view.
            package let backgroundColor: UIColor
            /// The blur effect style to apply to the dimming view. If `nil`, no blur effect is applied.
            package let blurEffect: UIBlurEffect.Style?

            /// Initializes a new shadow configuration.
            /// - Parameters:
            ///   - backgroundColor: The background color for the dimming view.
            ///   - blurEffect: The blur effect style. Default is `nil` (no blur).
            package init(backgroundColor: UIColor, blurEffect: UIBlurEffect.Style? = nil) {
                self.backgroundColor = backgroundColor
                self.blurEffect = blurEffect
            }

            /// Default shadow configuration: semi-transparent black background, no blur.
            package static let `default`: Shadow = Shadow(backgroundColor: UIColor.black.withAlphaComponent(0.6))
        }

        /// Defines how the primary view controller is presented within the bottom sheet.
        package enum ContentPresentationMode: Sendable {
            /// The view controller is presented directly, without any navigation controller wrapper.
            case singleView
            /// The view controller is embedded as the root of a `BottomSheet.NavigationController`,
            /// enabling push and pop navigation capabilities within the sheet.
            case navigationStack
        }

        /// Defines animation and interactive drag properties for the bottom sheet.
        package struct Animation: Sendable {
            /// The duration of the presentation and dismissal animations, in seconds.
            package let duration: TimeInterval
            /// The animation curve (timing function) to use for presentation and dismissal.
            package let curve: UIView.AnimationOptions
            /// The minimum downward velocity (in points per second) required to dismiss the sheet with a quick swipe.
            package let dragDismissVelocityThreshold: CGFloat
            /// The minimum vertical translation (as a percentage of the sheet's height, from 0.0 to 1.0)
            /// required to dismiss the sheet when dragging slowly.
            package let dragDismissTranslationThreshold: CGFloat

            /// Initializes a new animation configuration.
            /// - Parameters:
            ///   - duration: Animation duration in seconds. Default is `0.3`.
            ///   - curve: Animation curve. Default is `.curveEaseInOut`.
            ///   - dragDismissVelocityThreshold: Velocity threshold for swipe dismissal. Default is `300.0`.
            ///   - dragDismissTranslationThreshold: Translation threshold (0.0-1.0) for drag dismissal. Default is `0.3`.
            package init(
                duration: TimeInterval = 0.3,
                curve: UIView.AnimationOptions = .curveEaseInOut,
                dragDismissVelocityThreshold: CGFloat = 300.0,
                dragDismissTranslationThreshold: CGFloat = 0.3
            ) {
                self.duration = duration
                self.curve = curve
                self.dragDismissVelocityThreshold = dragDismissVelocityThreshold
                self.dragDismissTranslationThreshold = max(0.0, min(1.0, dragDismissTranslationThreshold)) // Clamp
            }

            /// Default animation configuration values.
            package static let `default`: Animation = Animation()
        }

        // MARK: - Main Configuration Properties

        /// The corner radius applied to the top corners of the bottom sheet.
        package let cornerRadius: CGFloat
        /// The configuration for the pull bar's appearance and visibility.
        package let pullBar: PullBar
        /// The configuration for the shadow/dimming view behind the sheet.
        package let shadow: Shadow
        /// The presentation mode for the content within the sheet (e.g., single view or navigation stack).
        package var contentPresentationMode: ContentPresentationMode
        /// Configuration for animation timings and interactive dismissal thresholds.
        package var animation: Animation
        
        var animationDuration: TimeInterval { 0.3 }
        var animationCurve: UIView.AnimationOptions { .curveEaseInOut }
        var dragDismissVelocityThreshold: CGFloat { 300 }
        var dragDismissTranslationThreshold: CGFloat { 0.3 }
        
        var maxHeightInitial: CGFloat { 400.0 }

        // MARK: - Initialization

        /// Initializes a new comprehensive configuration for a bottom sheet.
        /// - Parameters:
        ///   - cornerRadius: The radius for the top corners of the sheet. Defaults to `10.0`.
        ///   - pullBar: Configuration for the pull bar. Defaults to `BottomSheet.PullBar.default`.
        ///   - shadow: Configuration for the dimming view. Defaults to `BottomSheet.Shadow.default`.
        ///   - contentPresentationMode: How the content view controller is presented. Defaults to `.singleView`.
        ///   - animation: Configuration for animations and interactions. Defaults to `BottomSheet.Animation.default`.
        package init(
            cornerRadius: CGFloat = 10.0,
            pullBar: PullBar = .default,
            shadow: Shadow = .default,
            contentPresentationMode: ContentPresentationMode = .singleView,
            animation: Animation = .default
        ) {
            self.cornerRadius = cornerRadius
            self.pullBar = pullBar
            self.shadow = shadow
            self.contentPresentationMode = contentPresentationMode
            self.animation = animation
        }

        /// The default set of configurations for a bottom sheet.
        package static let `default`: Configuration = Configuration()
    }
}
