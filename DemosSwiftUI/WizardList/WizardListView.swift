//
//  WizardListView.swift
//  MyProduct
//
//  Created by Adrien on 30/10/2020.
//

import SwiftUI



// NE PAS TOUCHER-----
struct WizardListView_Previews: PreviewProvider {
    static var previews: some View {
        WizardListView()
    }
}
// ------------------









struct WizardRowView: View {
    var sorcier: Wizard
    
    var body: some View {
        HStack {
            Image(systemName: sorcier.icon)
                .foregroundColor(sorcier.color)
            Text(sorcier.name)
        }
    }
}

struct WizardListView: View {
    
    @State var editMode: EditMode = EditMode.inactive
    @State var sorciers = [
        Wizard(name: "Harry Potter", icon: "bolt.fill", color: Color.yellow),
        Wizard(name: "Hermione Granger", icon: "pencil", color: Color.green)
    ]
    
    @State private var selectedItems = Set<UUID>()
    
    func getSelectedNames() -> String {
        var result: String = ""
        for name in selectedItems {
            result += "\(name) "
        }
        return result
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List(selection: $selectedItems) {
                    ForEach(sorciers, id: \.id) {sorcier in
                        
                        NavigationLink(
                        destination: WizardDetailView(student: sorcier)) {
                        WizardRowView(sorcier: sorcier)
                        }
                        
                    }
                    .onDelete(perform: { indexSet in
                        print(indexSet)
                        
                        sorciers.remove(atOffsets: indexSet)
                    })
                    
                    
                }
                .listStyle(InsetGroupedListStyle())
                
                //.navigationBarItems(trailing: EditButton())
                .navigationBarTitle(Text("Mes Sorciers"))
                .toolbar {
                    HStack {
                        EditButton()
                        Button(editMode == .active ? "Fini" : "Editer") {
                            withAnimation {
                                editMode = editMode == .active ? .inactive : .active
                            }
                        }
                    }
                }
                
                Text(getSelectedNames())
            }.environment(\.editMode, $editMode)
        }
        
    }
    
}

