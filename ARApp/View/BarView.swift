//
//  CounterButtonBarView.swift
//  ARCounter
//
//  Created by Andronick Martusheff on 6/25/22.
//

import SwiftUI

struct BarView: View {
    @State var selectedObject: SelectedObject
    
    var body: some View {
        HStack(alignment: .center, spacing: 50) {
            Button {
                selectedObject.name = "ball"
                print("Tap : \(selectedObject.name)")
            } label: {
                Image(systemName: "figure.archery")
            }
            
            Button {
                selectedObject.name = "text"
                print("Tap : \(selectedObject.name)")
            } label: {
                Image(systemName: "photo.artframe")
            }
            
            Button {
                selectedObject.name = "other"
                print("Tap : \(selectedObject.name)")
            } label: {
                Image(systemName: "folder.badge.plus")
            }
            Button {
                selectedObject.name = "setuppins"
                print("Tap : \(selectedObject.name)")
            } label: {
                Image(systemName: "square.grid.3x1.folder.fill.badge.plus")
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

struct PreviewBarView: PreviewProvider {
    static var previews: some View {
        BarView(selectedObject: SelectedObject())
    }
}
