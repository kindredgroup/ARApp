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
        HStack(alignment: .center, spacing: 30) {
            Button {
                selectedObject.name = "ball"
                print("Tap : \(selectedObject.name)")
            } label: {
                Image(systemName: "figure.archery")
            }
            .background(selectedObject.name=="ball" ? Color.red : Color.black)
            
            Button {
                selectedObject.name = "text"
                print("Tap : \(selectedObject.name)")
            } label: {
                Image(systemName: "doc.text")
            }
            .background(selectedObject.name=="text" ? Color.red : Color.black)
            
            Button {
                selectedObject.name = "other"
                print("Tap : \(selectedObject.name)")
            } label: {
                Image(systemName: "note.text")
            }
            .background(selectedObject.name=="other" ? Color.red : Color.black)
            
            Button {
                selectedObject.name = "setuppins"
                print("Tap : \(selectedObject.name)")
            } label: {
                Image(systemName: "photo.artframe")
            }
            .background(selectedObject.name=="setuppins" ? Color.red : Color.black)
            
            Button {
                selectedObject.name = "scribble"
                print("Tap : \(selectedObject.name)")
            } label: {
                Image(systemName: "scribble")
            }
            .background(selectedObject.name=="scribble" ? Color.red : Color.black)
            
            Button {
                selectedObject.name = "clear"
                print("Tap : \(selectedObject.name)")
            } label: {
                Image(systemName: "clear")
            }
            .background(selectedObject.name=="clear" ? Color.red : Color.black)
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
