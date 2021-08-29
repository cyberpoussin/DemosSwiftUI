//
//  SwiftUIView3.swift
//  DemosSwiftUI
//
//  Created by Admin on 16/08/2021.
//

import SwiftUI

struct CustomChevronInList: View {
    let fruits = ["Apple", "Pear", "Peach", "Lemon"]
    var body: some View {
        NavigationView {
            List(fruits, id: \.self) { fruit in
                if fruit == "Apple" {
                    NavigationLink(destination:
                        Text(fruit)
                            .backButton {
                                HStack {
                                    Image(systemName: "chevron.left")
                                    Image(systemName: "applelogo")
                                }
                            }) {
                        Text(fruit)
                    }
                } else {
                    HStack {
                        HStack {
                            Text(fruit)
                            NavigationLink(destination: Text(fruit).backButton("Go back")) { EmptyView() }
                                .hidden()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .accentColor(.red)
            .navigationBarTitle("Fruits")
        }
    }
}



struct SwiftUIView3_Previews: PreviewProvider {
    static var previews: some View {
        CustomChevronInList()
    }
}
