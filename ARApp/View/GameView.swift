//
//  ContentView.swift
//  ARCounter
//
//  Created by Andronick Martusheff on 6/25/22.
//

import SwiftUI
import RealityKit


struct GameView: View {
    var selectedObject = SelectedObject()
    var body: some View {
        ZStack() {
            ARViewContainer(selectedObject: selectedObject)
            VStack {
                Spacer()
                BarView(selectedObject: selectedObject)
                NewButtonBar("Test")
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct PreviewGameView: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
