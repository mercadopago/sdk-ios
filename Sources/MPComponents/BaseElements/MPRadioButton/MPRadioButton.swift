//
//  MPRadioButton.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 12/02/26.
//

import SwiftUI

package struct MPRadioButton: View {
    @Binding var isOn: Bool
    
    @Environment(\.mpRadioButtonStyle) var style: any MPRadioButtonStyle
    
    package var body: some View {
        let configuration = MPRadioButtonConfiguration(isOn: isOn)
        
        AnyView(style.resolve(configuration: configuration))
            .onTapGesture {
                isOn.toggle()
            }
    }
}

#if DEBUG

struct MPRadioViewer: View {
    
    @State var isOn: Bool = false
    
    var body: some View {
        MPRadioButton(isOn: $isOn)
    }
}
#Preview {
    MPRadioViewer()
}
#endif
