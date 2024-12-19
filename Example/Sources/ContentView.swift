//
//  ContentView.swift
//  iOS Example
//
//  Created by Guilherme Prata Costa on Dec 19, 2024.
//

import SwiftUI
import Bricks

struct ContentView: View {
    
    let packageName = Core()
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Scaffolding \(packageName.getName())")
        }
    }
}

#Preview {
    ContentView()
}
