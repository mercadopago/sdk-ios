//
//  MPRadioButton.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 12/02/26.
//

import SwiftUI

package struct MPRadioButton: View {
    @Binding var selected: Bool
    
    @Environment(\.mpRadioButtonStyle) var style
    
    package var body: some View {
        let configuration = MPRadioButtonConfiguration(isOn: selected)
        
        AnyView(style.resolve(configuration: configuration))
            .onTapGesture {
                selected.toggle()
            }
    }
}

#if DEBUG

struct MPRadioViewer: View {
    
    @State var isOn: Bool = false
    
    var body: some View {
        MPRadioButton(selected: $isOn)
    }
}
#Preview {
    MPRadioViewer()
}
#endif
