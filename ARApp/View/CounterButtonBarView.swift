//
//  CounterButtonBarView.swift
//  ARCounter
//
//  Created by Andronick Martusheff on 6/25/22.
//

import SwiftUI

struct CounterButtonBarView: View {
    @State var selectedObject: SelectedObject
    
    var body: some View {
        HStack(alignment: .center, spacing: 50) {
            Button { // Increment Button
                selectedObject.name = "bullet"
                print("Tap : \(selectedObject.name)")
            } label: {
                Image(systemName: "square.and.arrow.up.circle.fill")
            }
            
            Button { // Increment Button
                selectedObject.name = "ball"
                print("Tap : \(selectedObject.name)")
            } label: {
                Image(systemName: "square.and.arrow.down.fill")
            }
        }
        .padding(.bottom, 15)
        .font(.system(size: 32))
        .foregroundColor(.white)
        .frame(width: UIScreen.main.bounds.width, height: 80, alignment: .center)
        .background(Color.black)
        .opacity(0.87)
    }
}
