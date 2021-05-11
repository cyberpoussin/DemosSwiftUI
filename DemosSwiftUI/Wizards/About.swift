//
//  About.swift
//  MyProduct
//
//  Created by Adrien on 03/11/2020.
//

import SwiftUI

struct About: View {
    var body: some View {
        VStack {
            Text("Cette application a été créée par Adrien")
            Text("Elle présente une liste de X sorciers")
        }
    }
}

struct About_Previews: PreviewProvider {
    static var previews: some View {
        About()
    }
}
