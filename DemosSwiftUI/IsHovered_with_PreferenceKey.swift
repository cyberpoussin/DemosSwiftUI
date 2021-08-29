//
//  SwiftUIView.swift
//  DemosSwiftUI
//
//  Created by Admin on 12/08/2021.
//


import SwiftUI


struct CardPreferenceData: Equatable {
    let index: Int
    let bounds: CGRect
}

struct CardPreferenceKey: PreferenceKey {
    typealias Value = [CardPreferenceData]
    
    static var defaultValue: [CardPreferenceData] = []
    
    static func reduce(value: inout [CardPreferenceData], nextValue: () -> [CardPreferenceData]) {
        value.append(contentsOf: nextValue())
    }
}

struct CardView: View {
    let index: Int
    
    var body: some View {
        Text(index.description)
            .padding(10)
            .frame(width: 60)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke())
            .background(
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.clear)
                        .preference(key: CardPreferenceKey.self,
                                    value: [CardPreferenceData(index: self.index, bounds: geometry.frame(in: .named("GameSpace")))])
                }
            )
    }
}

struct CardGrid: View {
    let columns = Array(repeating: GridItem(.fixed(60), spacing: 40), count: 3)
    @State private var selectedCardsIndices: [Int] = []
    @State private var cardsData: [CardPreferenceData] = []
    var body: some View {
        LazyVGrid(columns: columns, content: {
            ForEach((1...12), id: \.self) { index in
                CardView(index: index)
                    .foregroundColor(selectedCardsIndices.contains(index) ? .red : .blue)
            }
        })
        .onPreferenceChange(CardPreferenceKey.self){ value in
            if cardsData.isEmpty {
                cardsData = value
            }
        }
        .gesture(
            DragGesture()
                .onChanged {drag in
                    if let data = cardsData.first(where: {$0.bounds.contains(drag.location)}) {
                        selectedCardsIndices.append(data.index)
                    }
                }
        )
        .coordinateSpace(name: "GameSpace")
    }
}


struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        CardGrid()
    }
}
