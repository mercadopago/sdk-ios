//
//  BottomSheet+Router.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 11/09/25.
//
import SwiftUI
import UIKit

package extension BottomSheet {

    /// An `ObservableObject` that manages navigation between SwiftUI views
    /// presented within a `BottomSheet.NavigationController`.
    ///
    /// To enable navigation, inject an instance of `BottomSheet.Router` into your
    /// SwiftUI view hierarchy using the `.environmentObject()` modifier. The router's
    /// `navigationController` property is typically configured by an instance of
    /// `BottomSheet.NavigationHost` (or a similar hosting controller) when it's
    /// integrated into the view controller hierarchy.
    class Router: ObservableObject {

        /// A weak reference to the `UIViewController` that serves as the navigation backbone
        /// for the bottom sheet content. This is usually an instance of `BottomSheet.NavigationController`.
        ///
        /// This property is typically assigned by `BottomSheet.NavigationHost` (or a similar
        /// specialized hosting controller) when it's added to a parent navigation controller.
        weak var navigationController: BottomSheet.NavigationController?
        

        /// Initializes a new `BottomSheet.Router`.
        public init() {}

        /// Pushes a new SwiftUI view onto the bottom sheet's navigation stack.
        ///
        /// The method wraps the provided SwiftUI `content` in a `BottomSheet.NavigationHost`
        /// (which is a specialized `HeightAdaptiveHostingController`), injects this router
        /// instance into the view's environment, and then pushes the hosting controller
        /// onto the `navigationController`.
        ///
        /// - Parameters:
        ///   - content: A closure (`@ViewBuilder`) that returns the SwiftUI `View` to be pushed.
        ///   - animated: A Boolean value indicating whether the transition should be animated. Defaults to `true`.
        @MainActor
        package func push<Content: View>(
            @ViewBuilder content: @escaping () -> Content,
            animated: Bool = true
        ) {
            guard let navController = navigationController else {
                print("BottomSheet.Router ERROR: Navigation controller is not set. Cannot push new view.")
                return
            }

            let contentView = content().environmentObject(self)

            let destinationHost = BottomSheet.NavigationHost( 
                rootView: contentView,
                router: self
            )

            // Configure the onHeightDidChange callback. This allows the hosting controller
            // to update its preferredContentSize when its SwiftUI content's height changes,
            // which in turn signals the BottomSheet.NavigationController (and subsequently the
            // BottomSheet.PresentationController) to adjust the sheet's size.
            destinationHost.onHeightDidChange = { [weak destinationHost, weak navController] newHeight in
                guard let strongHost = destinationHost, let strongNavController = navController else { return }
                
                if abs(strongHost.preferredContentSize.height - newHeight) > 0.5 && newHeight > 0 {
                    let currentWidth = strongHost.view.bounds.width > 0 ?
                                       strongHost.view.bounds.width :
                                       strongNavController.view.bounds.width 
                    
                    strongHost.preferredContentSize = CGSize(
                        width: currentWidth,
                        height: newHeight
                    )
                }
            }
            
            navController.pushViewController(destinationHost, animated: animated)
        }
    }
}
