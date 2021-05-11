//
//  WizardDetailView.swift
//  MyProduct
//
//  Created by Adrien on 03/11/2020.
//

import SwiftUI

struct WizardDetailView: View {
    var student: Wizard
    
    var body: some View {
        VStack {
            Image(systemName: student.icon)
                .padding()
                .foregroundColor(.white)
                .font(.largeTitle)
                .background(student.color)
                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
            Text(student.name)
                .font(.largeTitle)
        }
        .navigationTitle("Ce sorcier")
    }
}

struct WizardDetailView_Previews: PreviewProvider {
    static var previews: some View {
        WizardDetailView(student: Wizard(name: "Ron weasley", icon: "pencil", color: Color.red))
    }
}
