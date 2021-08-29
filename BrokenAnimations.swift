//
//  BrokenAnimations.swift
//  DemosSwiftUI
//
//  Created by Admin on 29/08/2021.
//

import SwiftUI

struct CounterView: View {
    @State private var counter: Int = 0
    var exceeded: Bool { counter >= 1 }
    func restart() {
        // do something
        withAnimation(.linear(duration: 2)) {
            counter = 0
        }
    }

    func increment() {
        counter += 1
    }

    var body: some View {
        VStack {
            Button(exceeded ? "Restart" : "Increment", action: exceeded ? restart : increment)
                .foregroundColor(.red)
                .scaleEffect(exceeded ? 2 : 1)
            if exceeded {
                Button("Restart", action: restart)
                .scaleEffect(exceeded ? 2 : 1)
            } else {
                Button("Increment", action: increment)
                .scaleEffect(exceeded ? 2 : 1)
            }
        }
    }
}

struct BrokenAnimations_Previews: PreviewProvider {
    static var previews: some View {
        CounterView()
    }
}
