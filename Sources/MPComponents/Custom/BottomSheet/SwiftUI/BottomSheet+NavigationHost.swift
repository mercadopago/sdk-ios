//
//  BottomSheet+NavigationHost.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 11/09/25.
//
import SwiftUI

extension BottomSheet {
    
    /// A specialized `BaseHostingController` designed to host SwiftUI views
    /// within the BottomSheet's navigation system, managed by a `BottomSheet.Router`.
    ///
    /// This controller links the `BottomSheet.Router` to the actual
    /// `BottomSheet.NavigationController` in the view hierarchy, enabling navigation
    /// actions like pushing new SwiftUI screens within the sheet. It inherits dynamic
    /// height capabilities from `BaseHostingController`.
    class NavigationHost<Content: View>: BaseHostingController<Content> {
        
        /// A weak reference to the `BottomSheet.Router` that manages navigation for this view.
        private weak var router: BottomSheet.Router?

        /// Initializes a new `BottomSheet.NavigationHost`.
        /// - Parameters:
        ///   - rootView: The SwiftUI `View` to be hosted.
        ///   - router: The `BottomSheet.Router` instance responsible for navigation.
        public init(rootView: Content, router: BottomSheet.Router) {
            self.router = router
            super.init(rootView: rootView)
        }

        @MainActor
        required dynamic public init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        /// Called when the view controller is added or removed from a container view controller.
        ///
        /// This method links the `BottomSheet.Router` to the
        /// `BottomSheet.NavigationController` instance in the view hierarchy.
        package override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            
            var potentialNavController: BottomSheet.NavigationController?

            if let bsnController = parent as? BottomSheet.NavigationController {
                potentialNavController = bsnController
            } else if let navController = parent?.navigationController as? BottomSheet.NavigationController { 
                potentialNavController = navController
            }

            if let navController = potentialNavController {
                if self.router?.navigationController !== navController {
                    self.router?.navigationController = navController
                    print("BottomSheet.NavigationHost: Router's navigationController linked to \(type(of: navController)).")
                }
            } else if parent != nil && self.router?.navigationController == nil {
                print("BottomSheet.NavigationHost: Warning - Could not link router to a BottomSheet.NavigationController in the hierarchy.")
            }
        }
    }
}
