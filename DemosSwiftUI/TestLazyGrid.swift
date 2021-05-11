//
//  TestColumn.swift
//  NewFlowerApp
//
//  Created by Admin on 05/02/2021.
//

import Combine
import SwiftUI

struct TestColumn: View {
    var smallWidth: CGFloat { (UIScreen.main.bounds.width - 60) / 3.0 }

    let gridItem = [GridItem(.adaptive(minimum: 100), spacing: 10, alignment: .leading)]
    @State private var cancellables: Set<AnyCancellable> = []

    func isADoubleRect(idx: Int) -> Bool {
        // return false
        return idx % 10 == 1 % 10 || idx % 10 == 5 % 10
    }

    func getColor(for idx: Int) -> Color {
        Color(red: min(255, Double(120 + idx * 10)) / 255.0, green: Double(1 + idx * 2) / 255.0, blue: Double(1 + idx * 1) / 255.0)
    }

    @State var placeSelected: VeganFoodPlace? = nil
    @State var isShowed: Bool = false
    @ObservedObject var viewModel: ViewModel = ViewModel()
    var body: some View {
        List {
            LazyVGrid(columns: gridItem, spacing: 10) {
                ForEach(Array(viewModel.store.enumerated()), id: \.1.id) { idx, element in
                    if let image = element.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: isADoubleRect(idx: idx) ? smallWidth * 2 + 10 : smallWidth, height: 120)
                            .clipped()
                            .contentShape(Rectangle())
                            .onTapGesture {
                                print(idx)
                                placeSelected = element
                            }
                    } else {
                        ZStack {
                            Rectangle()
                                .foregroundColor(getColor(for: idx))
                            Text("\(idx)")
                                .foregroundColor(.white)
                                .font(.largeTitle)
                        }
                        .frame(width: isADoubleRect(idx: idx) ? smallWidth * 2 + 10 : smallWidth, height: 120)
                    }
                    if isADoubleRect(idx: idx) { Color.clear }
                }
            }
        }
        .sheet(item: $placeSelected) { place in
            place.image ?? Image(systemName: "drop")
        }
    }
}

struct TestColumn_Previews: PreviewProvider {
    static var previews: some View {
        TestColumn()
    }
}
