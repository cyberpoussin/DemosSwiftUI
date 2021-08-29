//
//  SwiftUIView55.swift
//  DemosSwiftUI
//
//  Created by Admin on 29/08/2021.
//

import SwiftUI

struct ProgramaticAndClassicNavigation: View {
    @State var entries = [10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25]
    @State var currentSelection: Int? = nil
    @State var linkIsActive = false
    var body: some View {
        NavigationView {
            Form {
                ForEach(entries.sorted(), id: \.self) { entry in
                    NavigationLink(
                        destination: DetailView(entry: entry),
                        label: { Text("The number \(entry)") })
                }
            }
            .background(
                NavigationLink("", destination: LazyView(DetailView(entry: currentSelection!)), isActive: Binding(get: {
                linkIsActive
            }, set: {value in
                if !value {
                    currentSelection = nil
                }
                linkIsActive = value
            }))
            )
//            .onChange(of: currentSelection, perform: { value in
//                if value != nil {
//                    linkIsActive = true
//                }
//            })
//            .onChange(of: linkIsActive, perform: { value in
//                if !value {
//                    currentSelection = nil
//                }
//            })
            
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) { Button("Add low") {
                    let newEntry = (entries.min() ?? 1) - 1
                    entries.insert(newEntry, at: 1)
                    currentSelection = newEntry
                    linkIsActive = true

                } }
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) { Button("Add high") {
                    let newEntry = (entries.max() ?? 50) + 1
                    entries.append(newEntry)
                    currentSelection = newEntry
                    linkIsActive = true
                } }
                ToolbarItem(placement: ToolbarItemPlacement.bottomBar) {
                    Text("The current selection is \(String(describing: currentSelection))")
                }
            }
        }
    }
}

struct DetailView: View {
    let entry: Int
    var body: some View {
        Text("It's a \(entry)!")
    }
}

public struct LazyView<Content: View>: View {
    private let build: () -> Content
    public init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    public var body: Content {
        build()
    }
}
struct SwiftUIView55_Previews: PreviewProvider {
    static var previews: some View {
        ProgramaticAndClassicNavigation()
    }
}
