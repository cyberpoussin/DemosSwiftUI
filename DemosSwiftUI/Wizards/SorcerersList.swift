//
//  SorcerersList.swift
//  MyProduct
//
//  Created by Adrien on 29/10/2020.
//

import SwiftUI

struct Sorcerer: Identifiable {
    var id = UUID()
    
    var firstName: String = "Harry"
    var lastName: String = "Potter"
    var imageName: String = "bolt.fill"
    var color: Color = Color.yellow
    var isKind: Bool = true
}

struct SorcerersList: View {
    var sorcerers = [
        Sorcerer(firstName: "Harry", lastName: "Potter", imageName: "bolt.fill", color: Color.yellow),
        Sorcerer(firstName: "Hermione", lastName: "Granger", imageName: "pencil", color: Color.blue),
        Sorcerer(firstName: "Ron", lastName: "Weasley", imageName: "car", color: Color.purple),
        Sorcerer(firstName: "Drago", lastName: "Malefoy", imageName: "flame.fill", color: Color.red, isKind: false),
        Sorcerer(firstName: "Voldemort", lastName: "", imageName: "wand.and.rays", color: Color.black, isKind: false),
        Sorcerer(firstName: "Dumbledore", lastName: "", imageName: "wand.and.stars", color: Color.orange),
        Sorcerer(firstName: "Remus", lastName: "Lupin", imageName: "leaf.fill", color: Color.green)
    ]
    
    @State var onlyGoodKids = false
    
    var body: some View {
        
        
        SorcererView()
        
        
        VStack(alignment: .leading) {
            SorcererView(sorcerer: Sorcerer(firstName: "Harry", lastName: "Potter", imageName: "bolt.fill", color: Color.yellow))
            SorcererView(sorcerer: Sorcerer(firstName: "Hermione", lastName: "Granger", imageName: "pencil", color: Color.blue))
                .padding(.top, 10)
        }
        
        List(sorcerers) {sorcerer in
            SorcererView(sorcerer: sorcerer)
        }
        
        
        
        VStack {
            Toggle("Seulement les gentils", isOn: $onlyGoodKids)
                .padding()
            
            if onlyGoodKids {
                List(sorcerers.filter({$0.isKind })){sorcerer in
                    SorcererView(sorcerer: sorcerer)
                }
            } else {
                List(sorcerers){sorcerer in
                    SorcererView(sorcerer: sorcerer)
                }
            }
            
        }
        
        
        List() {
            Section(header: Text("Gentils")) {
                ForEach(sorcerers) {sorcerer in
                    if sorcerer.isKind {
                        SorcererView(sorcerer: sorcerer)
                    }
                }
            }
            
            Section(header: Text("Méchants")) {
                ForEach(sorcerers) {sorcerer in
                    if !sorcerer.isKind {
                        SorcererView(sorcerer: sorcerer)
                    }
                }
            }
        }
    }
}

struct SorcerersList_Previews: PreviewProvider {
    static var previews: some View {
        SorcerersList()
    }
}

struct SorcererView: View {
    var sorcerer: Sorcerer = Sorcerer()
    
    var body: some View {
        HStack {
            Image(systemName: sorcerer.imageName)
                .foregroundColor(sorcerer.color)
                .frame(width: 20, height: 20, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            Text(sorcerer.firstName)
            Text(sorcerer.lastName)
        }
    }
}
