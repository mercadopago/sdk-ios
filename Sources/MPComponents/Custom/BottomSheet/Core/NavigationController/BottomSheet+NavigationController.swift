//
//  BottomSheet+NavigationController.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 11/09/25.
//
import UIKit

extension BottomSheet {

    /// A custom `UINavigationController` subclass designed to be presented within a
    /// `BottomSheet.PresentationController`.
    ///
    /// This navigation controller automatically updates its `preferredContentSize` to match
    /// its `topViewController`'s `preferredContentSize`. This allows the bottom sheet
    /// to dynamically resize as view controllers are pushed onto or popped from the navigation stack.
    ///
    /// It also provides custom transition animations for push and pop operations,
    /// suitable for a bottom sheet context, via `BottomSheet.NavigationAnimatedTransitioning`.
    final class NavigationController: UINavigationController {

        // MARK: - Private Properties

        /// A flag to indicate if the navigation stack is currently being updated (e.g., push, pop).
        /// Used to prevent redundant or conflicting updates to `preferredContentSize`.
        private var isUpdatingNavigationStack = false

        /// A flag to control whether `preferredContentSize` updates should be animated.
        /// Typically, the first update after the sheet is presented might not be animated,
        /// while subsequent changes (e.g., due to content loading) can be.
        private var canAnimatePreferredContentSizeUpdates = false

        /// Stores a reference to the 'from' view controller during a transition,
        /// used by the delegate to provide the correct interactive pop transition controller.
        private weak var lastTransitionFromViewController: UIViewController?

        /// The configuration for the bottom sheet presentation, passed down to transition animators.
        private let sheetConfiguration: BottomSheet.Configuration

        // MARK: - Initialization

        /// Initializes a `BottomSheet.NavigationController` with a root view controller and configuration.
        /// - Parameters:
        ///   - rootViewController: The root view controller of the navigation stack.
        ///   - configuration: The `BottomSheet.Configuration` to be used for this navigation controller
        ///                    and its transitions.
        public init(rootViewController: UIViewController, configuration: BottomSheet.Configuration) {
            self.sheetConfiguration = configuration
            super.init(rootViewController: rootViewController)
        }

        /// Standard non-bottom-sheet initializer.
        /// Uses a default configuration if initialized this way, though usage within a bottom sheet
        /// typically involves the specific initializer above.
        override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
            self.sheetConfiguration = .default
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        }

        @available(*, unavailable)
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented. Use init(rootViewController:configuration:)")
        }

        // MARK: - UIViewController Lifecycle

        public override func viewDidLoad() {
            super.viewDidLoad()

            delegate = self

            view.clipsToBounds = true
            
            modalPresentationStyle = .custom
        }

        // MARK: - UINavigationController Overrides

        override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
            performNavigationStackUpdate(animated: animated) {
                super.setViewControllers(viewControllers, animated: animated)
            }
        }

        override func pushViewController(_ viewController: UIViewController, animated: Bool) {
            performNavigationStackUpdate(animated: animated) {
                super.pushViewController(viewController, animated: animated)
            }
        }

        override func popViewController(animated: Bool) -> UIViewController? {
            var poppedViewController: UIViewController?
            performNavigationStackUpdate(animated: animated) {
                poppedViewController = super.popViewController(animated: animated)
            }
            return poppedViewController
        }

        override func popToRootViewController(animated: Bool) -> [UIViewController]? {
            var poppedViewControllers: [UIViewController]?
            performNavigationStackUpdate(animated: animated) {
                poppedViewControllers = super.popToRootViewController(animated: animated)
            }
            return poppedViewControllers
        }

        override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
            var poppedViewControllers: [UIViewController]?
            performNavigationStackUpdate(animated: animated) {
                poppedViewControllers = super.popToViewController(viewController, animated: animated)
            }
            return poppedViewControllers
        }


        /// Called when the `preferredContentSize` of a child view controller changes.
        /// This navigation controller updates its own `preferredContentSize` to reflect the change,
        /// which in turn can cause the presenting `BottomSheet.PresentationController` to resize the sheet.
        override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
            super.preferredContentSizeDidChange(forChildContentContainer: container)

            guard
                let viewController = container as? UIViewController,
                viewController === topViewController, // Only react to top VC changes
                !isUpdatingNavigationStack // Don't update if a push/pop is already in progress
            else { return }

            let updateAction = { [weak self] in
                self?.updateSelfPreferredContentSize()
                self?.view.layoutIfNeeded() // Ensure layout reflects new preferred size
            }

            if canAnimatePreferredContentSizeUpdates {
                UIView.animate(withDuration: sheetConfiguration.animation.duration,
                               animations: updateAction)
            } else {
                updateAction()
            }

            // Allow subsequent preferredContentSize changes to be animated.
            // This is often set to true after the initial presentation animation is complete.
            canAnimatePreferredContentSizeUpdates = true
        }

        // MARK: - Private Helper Methods

        /// Wraps navigation stack changes (push, pop, set) to manage `preferredContentSize` updates
        /// and animation states.
        /// - Parameters:
        ///   - animated: Whether the navigation change is animated.
        ///   - changes: A closure containing the actual navigation operation (e.g., `super.pushViewController`).
        private func performNavigationStackUpdate(animated: Bool, applyChanges: () -> Void) {
            isUpdatingNavigationStack = true

            applyChanges()

            if let coordinator = transitionCoordinator, animated, coordinator.isAnimated {
                // If the change is animated and a transition coordinator exists,
                // update preferredContentSize alongside the transition.
                coordinator.animate(
                    alongsideTransition: { [weak self] _ in
                        self?.updateSelfPreferredContentSize()
                    },
                    completion: { [weak self] context in
                        self?.isUpdatingNavigationStack = false
                        self?.updateSelfPreferredContentSize()
                        self?.canAnimatePreferredContentSizeUpdates = true
                    }
                )
            } else {
                // If not animated or no coordinator, update directly and reset state.
                isUpdatingNavigationStack = false
                updateSelfPreferredContentSize()
                // If not animated, likely means it's an immediate change or initial setup.
                // Allow animations for subsequent changes.
                canAnimatePreferredContentSizeUpdates = true
            }
        }

        /// Updates this navigation controller's `preferredContentSize` based on its `topViewController`.
        /// It includes `additionalSafeAreaInsets` to ensure content is not obscured.
        private func updateSelfPreferredContentSize() {
            guard let topVC = topViewController else {
                // If no topViewController, perhaps set to a minimal default or zero.
                // This depends on desired behavior for an empty navigation stack.
                // For now, let's assume it might result in zero or rely on system defaults.
                // A width of view.bounds.width and height of 0 is a safe bet if content should disappear.
                // However, a navigation controller usually has at least one VC.
                if view.bounds.width > .zero {
                    preferredContentSize = CGSize(width: view.bounds.width, height: .zero)
                }
                return
            }
            
            var newHeight = topVC.preferredContentSize.height
            // Add vertical safe area insets that this navigation controller itself contributes.
            // This ensures the child's preferredContentSize is correctly represented *within* this nav controller.
            newHeight += additionalSafeAreaInsets.top + additionalSafeAreaInsets.bottom

            let newWidth = view.bounds.width > 0 ? view.bounds.width : UIScreen.main.bounds.width
            
            // Only update if the size actually changes to avoid unnecessary layout passes.
            if preferredContentSize.width != newWidth || preferredContentSize.height != newHeight.pixelCeiled {
                 preferredContentSize = CGSize(
                     width: newWidth,
                     height: newHeight.pixelCeiled
                 )
            }
        }
    }
}

// MARK: - UINavigationControllerDelegate Conformance
extension BottomSheet.NavigationController: UINavigationControllerDelegate {
    public func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == .push {
            // Setup custom interactive pop transition for the view controller being pushed.
            toVC.setupCustomInteractivePopTransition()
        }

        lastTransitionFromViewController = fromVC
        
        return BottomSheetNavigationAnimatedTransitioning(
            operation: operation,
            configuration: sheetConfiguration
        )
    }

    public func navigationController(
        _ navigationController: UINavigationController,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        // Use the custom interactive pop transition from the 'from' view controller.
        // This relies on `setupCustomInteractivePopTransition()` having been called.
        return lastTransitionFromViewController?.customInteractivePopTransitioning
    }
}
