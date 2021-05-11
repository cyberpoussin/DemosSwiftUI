//
//  Model.swift
//  MyProduct
//
//  Created by Adrien on 03/11/2020.
//

import SwiftUI


struct Wizard: Identifiable {
    let id = UUID()

    var name: String
    var icon: String
    var color: Color
    var description: String = ""
    var age: Int = 0
}




var harryPotter = Wizard(name: "HarryPotter", icon: "pencil", color: Color.pink)
var hermioneGranger = Wizard(name: "hermioneGranger", icon: "pencil", color: Color.purple)
