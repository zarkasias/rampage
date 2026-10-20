//
//  ContentView.swift
//  rampage
//
//  Created by David Chambers on 10/20/26.
//

import SwiftUI
import Engine

struct ContentView: View {
 
    var body: some View {
        GameView()
            .background(SwiftUI.Color.black)
            .ignoresSafeArea()
        }
    }


#Preview {
    ContentView()
}
