//
//  SwiftUIView17.swift
//  DemosSwiftUI
//
//  Created by Admin on 25/08/2021.
//

import SwiftUI

struct ListItem: Identifiable {
    let id = UUID()
    let name: String
}

struct ListWithPolyDestinations: View {
    @State private var filteredItems = ["John", "Bob", "Maria"].map(ListItem.init)
    
    @ViewBuilder func destination(for itemIndex: Int) -> some View {
        switch itemIndex {
        case 0: Text("John destination")
        case 1: Text("Bob destination").foregroundColor(.red)
        case 2: Rectangle()
        default: Text("error")
        }
    }
    
    var body: some View {
        ScrollView {
            ForEach(Array(filteredItems.enumerated()), id: \.1.id) { index, item in
                NavigationLink(destination: destination(for: index)){
                    Text(item.name)
                }
            }
        }
    }
}

struct SwiftUIView17_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ListWithPolyDestinations()
        }
    }
}
