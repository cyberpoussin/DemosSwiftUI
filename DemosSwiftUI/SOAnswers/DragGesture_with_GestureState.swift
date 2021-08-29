//
//  SwiftUIView22.swift
//  DemosSwiftUI
//
//  Created by Admin on 28/08/2021.
//

import SwiftUI

struct DragTestView: View {
    @GestureState private var startLocation: CGPoint? = nil
    @State private var location: CGPoint = .zero
    var body: some View {
        
        HStack {
            Text("lol")
            Button("Test") {
            print("click")
            }
        }
        .padding()
        .background(Color.red)
        .offset(x: location.x, y: location.y)
        .gesture(DragGesture()
            .onChanged { value in
                var newLocation = startLocation ?? location // 3
                newLocation.x += value.translation.width
                newLocation.y += value.translation.height
                self.location = newLocation
            }.updating($startLocation) { _, startLocation, _ in
                startLocation = startLocation ?? location // 2
            }
        )
    }
}

struct SwiftUIView22_Previews: PreviewProvider {
    static var previews: some View {
        DragTestView()
    }
}
