import SwiftUI

enum TextFieldFocusHelper {
    static func makeFocusHandler(
        focusState: Binding<Bool>,
        onFocusChanged: ((Bool) -> Void)?
    ) -> (Bool) -> Void {
        { focus in
            onFocusChanged?(focus)
            guard focusState.wrappedValue != focus else { return }
            DispatchQueue.main.async {
                focusState.wrappedValue = focus
            }
        }
    }

    static func syncFocus(
        _ uiView: PCITextField,
        shouldBeFocused: Bool
    ) {
        guard shouldBeFocused != uiView.isInputFocused else { return }
        DispatchQueue.main.async {
            if shouldBeFocused {
                uiView.focus()
            } else {
                uiView.resignFocus()
            }
        }
    }
}
