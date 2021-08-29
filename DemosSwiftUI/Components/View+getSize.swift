//
//  SwiftUIView8.swift
//  DemosSwiftUI
//
//  Created by Admin on 18/08/2021.
//

import SwiftUI



struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct SizeModifier: ViewModifier {
    private var sizeView: some View {
        GeometryReader { geometry in
            Color.clear.preference(key: SizePreferenceKey.self, value: geometry.size)
        }
    }

    func body(content: Content) -> some View {
        content.overlay(sizeView)
    }
}

extension View {
    func getSize(perform: @escaping (CGSize) -> ()) -> some View {
        self
            .modifier(SizeModifier())
            .onPreferenceChange(SizePreferenceKey.self) {
                perform($0)
            }
    }
}
