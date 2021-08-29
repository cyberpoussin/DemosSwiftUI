//
//  SwiftUIView12.swift
//  DemosSwiftUI
//
//  Created by Admin on 21/08/2021.
//

import SwiftUI

struct ScrollViewThatFits: View {
    @State private var items: [String] = ["One", "Two", "Three"]
    @State private var scrollViewSize: CGSize = .zero
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .getSize {scrollViewSize = $0}
            }
            .frame(height: scrollViewSize.height < proxy.size.height ? scrollViewSize.height : .none )
            .background(Color.blue.opacity(0.2))
        }
        .navigationTitle("Test")
        .toolbar {
            Button("Many items") {
                items = (1 ... 30).map { _ in String.random(length: 10) }
            }
        }
    }
}

struct SwiftUIView12_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ScrollViewThatFits()
        }
    }
}
