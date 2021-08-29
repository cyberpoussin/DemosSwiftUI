//
//  View+backButton.swift
//  DemosSwiftUI
//
//  Created by Admin on 29/08/2021.
//

import SwiftUI

struct BackButton<Label: View>: ViewModifier {
    @Environment(\.presentationMode) var presentationMode
    var text: String?
    var label: Label?
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: { self.presentationMode.wrappedValue.dismiss() }, label: {
                if let text = text {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text(text)
                    }
                } else if let label = label {
                    label
                }

            }))
    }
}

extension View {
    func backButton(_ text: String) -> some View {
        modifier(BackButton<EmptyView>(text: text))
    }

    func backButton<Label: View>(@ViewBuilder label labelBuilder: () -> Label) -> some View {
        modifier(BackButton<Label>(label: labelBuilder()))
    }
}
