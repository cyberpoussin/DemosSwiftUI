//
//  MainView.swift
//  MyProduct
//
//  Created by Adrien on 03/11/2020.
//

import SwiftUI

struct MainView: View {
    @State private var sheet: Bool = false
    var body: some View {
        TabView {
            WizardListView()
                .tabItem {
                    Image(systemName: "pencil")
                    Text("Liste")
                }
            
            About()
                .tabItem {
                    Image(systemName: "drop")
                    Text("A propos")
                }
        }
        .sheet(isPresented: $sheet, content: {Text("jaja")})
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
