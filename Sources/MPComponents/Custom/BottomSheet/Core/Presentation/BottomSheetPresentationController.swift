//
//  BottomSheetPresentationController.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 11/09/25.
//

import Combine
import UIKit

/// Manages the presentation and transition of a view controller as a modal bottom sheet.
///
/// `BottomSheetPresentationController` is a subclass of `UIPresentationController`
/// responsible for:
/// - The visual appearance of the sheet, including corner radius, an optional pull bar,
///   and a dimming view behind the sheet.
/// - Animating the presentation and dismissal of the sheet.
/// - Handling interactive dismissal via pan gestures.
/// - Dynamically adjusting the sheet's height based on the `preferredContentSize`
///   of the presented view controller.
final class BottomSheetPresentationController: UIPresentationController {
    // MARK: - Nested Types

    /// Represents the different states of the bottom sheet presentation.
    private enum State {
        case dismissed
        case presenting
        case presented
        case dismissing
    }

    // MARK: - Public Properties

    /// The interactive transitioning object used for the sheet's dismissal,
    /// if an interactive dismissal gesture is currently in progress.
    var interactiveTransition: UIViewControllerInteractiveTransitioning? {
        interactionController
    }

    // MARK: - Private Properties

    private var state: State = .dismissed

    /// Indicates if an interactive transition (typically dismissal) can be handled.
    /// This is true if a drag is in progress and no navigation transition within the sheet is active.
    private var isInteractiveTransitionCanBeHandled: Bool {
        isDraggingSheetInProgress && !isNavigationTransitionInProgress
    }

    /// `true` if a pan gesture that could lead to sheet dismissal is actively being tracked.
    private var isDraggingSheetInProgress = false {
        didSet {
            if isDraggingSheetInProgress {
                // Ensure no interactive controller exists when dragging starts
                assert(interactionController == nil, "Interaction controller should be nil when sheet dragging starts.")
            }
        }
    }

    /// `true` if a push or pop navigation transition is occurring *within* the presented view controller
    /// (e.g., if the presented VC is a UINavigationController).
    private var isNavigationTransitionInProgress = false {
        didSet {
            // Ensure no interactive controller exists during navigation transitions
            assert(interactionController == nil, "Interaction controller should be nil during navigation transition.")
        }
    }

    /// The accumulated vertical translation from a pan gesture used for interactive dismissal.
    private var dismissalPanTranslation: CGFloat = 0

    /// The controller managing an interactive dismissal transition.
    private var interactionController: UIPercentDrivenInteractiveTransition?

    /// The view that dims the content behind the bottom sheet.
    /// Configured based on `BottomSheetConfiguration.ShadowConfiguration`.
    public var shadingView: UIView?
    
    /// The internally managed pull bar view, displayed at the top of the sheet if configured.
    /// This view is an instance of `BottomSheetPresentationController.PullBar`.
    private var pullBarView: BottomSheetPresentationController.PullBar?

    /// Cached safe area insets from the container view's window. Updated during layout.
    private var cachedSafeAreaInsets: UIEdgeInsets = .zero

    /// The handler responsible for dismissal logic and callbacks.
    private let dismissalHandler: BottomSheetModalDismissalHandler
    /// The configuration defining the appearance and behavior of the bottom sheet.
    private let configuration: BottomSheet.Configuration

    // MARK: - Initialization

    /// Initializes a new bottom sheet presentation controller.
    ///
    /// - Parameters:
    ///   - presentedViewController: The view controller being presented as a bottom sheet.
    ///   - presentingViewController: The view controller that is presenting the bottom sheet.
    ///   - dismissalHandler: A handler for managing dismissal actions and callbacks.
    ///   - configuration: The configuration settings for the bottom sheet's appearance and behavior.
    init(
        presentedViewController: UIViewController,
        presentingViewController: UIViewController?,
        dismissalHandler: BottomSheetModalDismissalHandler,
        configuration: BottomSheet.Configuration
    ) {
        self.dismissalHandler = dismissalHandler
        self.configuration = configuration
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }

    // MARK: - Setup
    
    /// Sets up pan gesture recognizers for the presented view and the pull bar.
    private func setupGestureRecognizers() {
        setupPanGesture(for: presentedView)
        setupPanGesture(for: pullBarView)
    }

    /// Adds a pan gesture recognizer to the specified view for interactive sheet dismissal.
    /// - Parameter view: The view to which the pan gesture recognizer will be added.
    private func setupPanGesture(for view: UIView?) {
        guard let view = view else {
            return
        }

        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleSheetPanGesture(_:)))
        view.addGestureRecognizer(panRecognizer)
        panRecognizer.delegate = self
    }

    // MARK: - UIPresentationController Overrides

    public override func presentationTransitionWillBegin() {
        state = .presenting
        addContentDimmingView()
        applyStyleToPresentedView()
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        if completed {
            setupGestureRecognizers()
            state = .presented
            // Pull bar and safe area insets are configured in containerViewDidLayoutSubviews
            // as they depend on the final frame of the presented view.
        } else {
            removeContentDimmingViewAndPullBar() // Ensure cleanup if presentation was cancelled
            state = .dismissed
        }
    }

    override func dismissalTransitionWillBegin() {
        state = .dismissing
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            removeContentDimmingViewAndPullBar()
            state = .dismissed
            dismissalHandler.didEndDismissal()
        } else {
            // Dismissal was cancelled, restore to presented state
            state = .presented
        }
    }

    override var shouldPresentInFullscreen: Bool {
        // For custom modal presentations that don't necessarily cover the full screen,
        // `false` is typical. However, on iOS 17+, `true` might be needed for some behaviors
        // or to avoid system interference. This was `true` in the original for iOS 17+.
        // Needs testing for specific implications.
        if #available(iOS 17.0, *) {
            return true
        } else {
            return false
        }
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        calculateTargetFrameForPresentedView()
    }

    override func preferredContentSizeDidChange(
        forChildContentContainer container: UIContentContainer
    ) {
        guard
            let presentedView = presentedView,
            containerView != nil,
            container === presentedViewController,
            (state == .presented || state == .presenting)
        else {
            if container === presentedViewController {
                updatePresentedViewFrame()
            }
            return
        }

        if state == .presented {
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                options: .curveEaseInOut,
                animations: {
                    self.updatePresentedViewFrame()
                    presentedView.superview?.layoutIfNeeded()
                },
                completion: nil
            )
        } else {
            // If presenting, the main presentation animation will handle the final frame.
            // Update here to ensure calculations are correct if size changes mid-presentation.
            updatePresentedViewFrame()
        }
    }

    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()

        cachedSafeAreaInsets = presentedView?.window?.safeAreaInsets ?? .zero
        updatePresentedViewFrame()
        
        if state == .presented || state == .presenting {
            configurePullBarView()
            adjustPresentedControllerSafeAreaInsetsForPullBar()
        }
    }

    // MARK: - Interactive Dismissal Handling

    /// Handles pan gestures on the sheet or pull bar for interactive dismissal.
    /// - Parameter panGesture: The `UIPanGestureRecognizer` that triggered the action.
    @objc
    private func handleSheetPanGesture(_ panGesture: UIPanGestureRecognizer) {
        switch panGesture.state {
        case .began:
            processSheetPanBegan(panGesture)
        case .changed:
            processSheetPanChanged(panGesture)
        case .ended:
            processSheetPanEnded(panGesture)
        case .cancelled, .failed:
            processSheetPanCancelledOrFailed(panGesture)
        default:
            break
        }
    }

    /// Called when a pan gesture on the sheet begins.
    private func processSheetPanBegan(_ panGesture: UIPanGestureRecognizer) {
        guard dismissalHandler.canBeDismissed, interactionController == nil else { return }
        startInteractiveDismissal()
    }

    /// Starts an interactive dismissal transition.
    private func startInteractiveDismissal() {
        interactionController = UIPercentDrivenInteractiveTransition()
        // The `dismissalHandler` is responsible for the actual dismissal call if this is from a swipe.
        // However, initiating it via the VC is standard for interactive transitions.
        presentedViewController.dismiss(animated: true, completion: nil)
    }

    /// Called when a pan gesture on the sheet changes.
    private func processSheetPanChanged(_ panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translation(in: presentedView)
        updateDismissalProgress(verticalTranslation: translation.y)
    }

    /// Updates the progress of the interactive dismissal transition.
    /// - Parameter verticalTranslation: The vertical distance the user has panned.
    private func updateDismissalProgress(verticalTranslation: CGFloat) {
        guard let presentedView = presentedView, presentedView.bounds.height > 0 else {
            interactionController?.cancel()
            interactionController = nil
            return
        }
        let progress = max(0.0, min(1.0, verticalTranslation / presentedView.bounds.height))
        interactionController?.update(progress)
    }

    /// Called when a pan gesture on the sheet ends.
    private func processSheetPanEnded(_ panGesture: UIPanGestureRecognizer) {
        let velocity = panGesture.velocity(in: presentedView)
        let translation = panGesture.translation(in: presentedView)
        
        let isMovingDownwardsFast = velocity.y > configuration.dragDismissVelocityThreshold
        let hasTranslatedEnough = translation.y > (presentedView?.bounds.height ?? 0) * configuration.dragDismissTranslationThreshold

        if isMovingDownwardsFast || hasTranslatedEnough {
            completeInteractiveDismissal(cancelled: false)
        } else {
            completeInteractiveDismissal(cancelled: true)
        }
    }

    /// Called when a pan gesture on the sheet is cancelled or fails.
    private func processSheetPanCancelledOrFailed(_ panGesture: UIPanGestureRecognizer) {
        completeInteractiveDismissal(cancelled: true)
    }

    /// Completes (finishes or cancels) the interactive dismissal.
    /// - Parameter cancelled: `true` to cancel the dismissal, `false` to finish it.
    private func completeInteractiveDismissal(cancelled: Bool) {
        guard let currentInteractionController = interactionController else { return }

        if cancelled || !dismissalHandler.canBeDismissed {
            currentInteractionController.cancel()
        } else {
            currentInteractionController.finish()
        }
        self.interactionController = nil
    }

    // MARK: - Private Helper Methods

    /// Applies corner radius and masking to the presented view.
    private func applyStyleToPresentedView() {
        guard let presentedView = presentedViewController.viewIfLoaded else {
            assertionFailure("Presented view controller's view not loaded when applying style.")
            return
        }

        presentedView.clipsToBounds = true
        presentedView.layer.cornerRadius = configuration.cornerRadius
        presentedView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    /// Adds the dimming (shading) view to the container.
    private func addContentDimmingView() {
        guard let containerView = containerView else {
            assertionFailure("Container view is nil when adding dimming view.")
            return
        }
        
        let shadingEffectView: UIView
        if let blurStyle = configuration.shadow.blurEffect {
            shadingEffectView = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
        } else {
            shadingEffectView = UIView()
        }

        shadingEffectView.backgroundColor = configuration.shadow.backgroundColor
        shadingEffectView.frame = containerView.bounds
        shadingEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(shadingEffectView)

        let tapGesture = UITapGestureRecognizer(
            target: self, action: #selector(handleDimmingViewTap)
        )
        shadingEffectView.addGestureRecognizer(tapGesture)
        shadingEffectView.isUserInteractionEnabled = true

        self.shadingView = shadingEffectView
    }
    
    /// Configures and positions the `pullBarView`.
    /// This method creates the pull bar if it doesn't exist and is configured to be visible,
    /// and sets its frame at the top of the `presentedView`.
    private func configurePullBarView() {
        guard let presentedView = presentedView else {
            self.pullBarView?.removeFromSuperview()
            self.pullBarView = nil
            return
        }

        guard case .visible(let appearance) = configuration.pullBar else {
            self.pullBarView?.removeFromSuperview()
            self.pullBarView = nil
            return
        }

        if self.pullBarView == nil {
            let newPullBar = BottomSheetPresentationController.PullBar(appearance: appearance)
            self.pullBarView = newPullBar
            presentedView.addSubview(newPullBar)
            setupPanGesture(for: newPullBar)
        }
        
        if let currentPullBar = self.pullBarView {
            if currentPullBar.superview != presentedView {
                currentPullBar.removeFromSuperview()
                presentedView.addSubview(currentPullBar)
            }

            currentPullBar.frame = CGRect(
                x: 0,
                y: 0,
                width: presentedView.bounds.width,
                height: appearance.height
            )
            currentPullBar.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        }
    }

    /// Adjusts the `additionalSafeAreaInsets` of the presented view controller
    /// to account for the `pullBarView`, if it's visible.
    /// This ensures content within the presented view controller respects the space taken by the pull bar.
    private func adjustPresentedControllerSafeAreaInsetsForPullBar() {
        guard presentedView != nil else { return }

        var topInsetForPullBar: CGFloat = 0
        if case .visible(let appearance) = configuration.pullBar, pullBarView != nil {
            topInsetForPullBar = appearance.height
        }

        if presentedViewController.additionalSafeAreaInsets.top != topInsetForPullBar {
            presentedViewController.additionalSafeAreaInsets.top = topInsetForPullBar
        }
    }

    /// Handles tap gestures on the dimming view to dismiss the sheet.
    @objc
    private func handleDimmingViewTap() {
        guard state == .presented, dismissalHandler.canBeDismissed else { return }
        dismissalHandler.performDismissal(animated: true)
    }

    /// Removes the dimming view and the pull bar from their superviews.
    private func removeContentDimmingViewAndPullBar() {
        shadingView?.removeFromSuperview()
        shadingView = nil
        
        pullBarView?.removeFromSuperview()
        pullBarView = nil
    }

    /// Calculates the target frame for the presented view within the container view.
    /// The frame calculation considers the presented view controller's `preferredContentSize`,
    /// safe area insets of the window, and the height of the pull bar (if visible).
    ///
    /// - Returns: A `CGRect` representing the desired frame for the presented view.
    private func calculateTargetFrameForPresentedView() -> CGRect {
        guard let containerView = containerView else {
            return .zero
        }

        let windowSafeAreaInsets = cachedSafeAreaInsets

        var contentHeight = presentedViewController.preferredContentSize.height
        // This behavior might need adjustment if SwiftUI views calculate preferredContentSize differently.
        contentHeight += windowSafeAreaInsets.bottom

        var maxSheetHeight = containerView.bounds.height - windowSafeAreaInsets.top
        if case .visible(let appearance) = configuration.pullBar {
            maxSheetHeight -= appearance.height
        }
        
        // Ensure height is not negative if insets/pullbar are larger than container height
        maxSheetHeight = max(0, maxSheetHeight)
        let finalSheetHeight = min(contentHeight, maxSheetHeight)

        return CGRect(
            x: 0,
            y: (containerView.bounds.height - finalSheetHeight).pixelCeiled,
            width: containerView.bounds.width,
            height: finalSheetHeight.pixelCeiled
        )
    }

    /// Updates the presented view's frame to the calculated target frame.
    private func updatePresentedViewFrame() {
        guard let presentedView = presentedView else {
            return
        }
        let newFrame = calculateTargetFrameForPresentedView()
        if !presentedView.frame.isAlmostEqual(to: newFrame) {
            presentedView.frame = newFrame
        }
    }

    /// Attempts to dismiss the sheet if current conditions allow.
    /// - Returns: `true` if dismissal was initiated, `false` otherwise.
    @discardableResult
    private func dismissSheetIfPossible() -> Bool { // Renamed
        let canBeDismissed = state == .presented && dismissalHandler.canBeDismissed
        if canBeDismissed {
            dismissalHandler.performDismissal(animated: true)
        }
        return canBeDismissed
    }
}

// MARK: - UIGestureRecognizerDelegate Conformance
extension BottomSheetPresentationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }
        // Allow pan gesture to begin if the sheet is presented and the initial pan is generally downwards.
        let translationInPresentedView = panGesture.translation(in: presentedView)
        return state == .presented && translationInPresentedView.y >= 0
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return false
    }
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return false
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !isNavigationTransitionInProgress
    }
}

// MARK: - UINavigationControllerDelegate Conformance
// This conformance is for cases where the BottomSheetPresentationController itself might be
// set as a delegate to a UINavigationController it is presenting, or for observing
// navigation events within a presented UINavigationController if it's not self-delegating.
extension BottomSheetPresentationController: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        isNavigationTransitionInProgress = false
        
        // After navigation, the content and thus preferred size might change.
        // The presented navigation controller should update its preferredContentSize,
        // which will trigger `preferredContentSizeDidChange` on this presentation controller.
    }

    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        isNavigationTransitionInProgress = true
    }
}

// MARK: - UIViewControllerAnimatedTransitioning Conformance
extension BottomSheetPresentationController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return configuration.animationDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let sourceVC = transitionContext.viewController(forKey: .from),
            let destinationVC = transitionContext.viewController(forKey: .to)
        else {
            transitionContext.completeTransition(false)
            return
        }

        let isPresenting = (destinationVC.presentingViewController === sourceVC)
        
        // Get the view to be animated (either the 'to' view for presentation, or 'from' view for dismissal)
        let viewToAnimate = isPresenting ? transitionContext.view(forKey: .to)! : transitionContext.view(forKey: .from)!
        let containerView = transitionContext.containerView
        
        if isPresenting {
            containerView.addSubview(viewToAnimate)
            applyStyleToPresentedView()
        }

        sourceVC.view.layoutIfNeeded()
        destinationVC.view.layoutIfNeeded()
        
        let finalFrameForView = calculateTargetFrameForPresentedView()
        let initialFrameForPresentationAnimation = CGRect(
            origin: CGPoint(x: 0, y: containerView.bounds.height),
            size: finalFrameForView.size
        )

        viewToAnimate.frame = isPresenting ? initialFrameForPresentationAnimation : finalFrameForView
        shadingView?.alpha = isPresenting ? 0 : 1

        let animations = {
            viewToAnimate.frame = isPresenting ? finalFrameForView : initialFrameForPresentationAnimation
            self.shadingView?.alpha = isPresenting ? 1 : 0
        }

        let completion = { (finished: Bool) in
            let success = finished && !transitionContext.transitionWasCancelled
            if !success && isPresenting {
                viewToAnimate.removeFromSuperview()
            }
            transitionContext.completeTransition(success)

            if transitionContext.transitionWasCancelled {
                let sourceView = transitionContext.view(forKey: .from)
                let originalSourceFrame = sourceView?.frame
                sourceView?.frame = .zero
                sourceView?.frame = originalSourceFrame ?? .zero
            }
        }
        
        let animationOptions: UIView.AnimationOptions =
        transitionContext.isInteractive ? .curveLinear : configuration.animationCurve
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: animationOptions,
            animations: animations,
            completion: completion
        )
    }

    public func animationEnded(_ transitionCompleted: Bool) {
        // This method is called when a non-interactive transition animation finishes,
        // or when an interactive transition is completed or cancelled.
        // Can be used for final cleanup if needed, beyond what transitionContext.completeTransition offers.
    }
}
