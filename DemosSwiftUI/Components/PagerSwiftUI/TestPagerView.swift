//
//  TestHorizontalScroll.swift
//  NewFlowerApp
//
//  Created by Admin on 08/02/2021.
//

import SwiftUI



struct TestPagerView: View {
    @State private var currentPage = 0

    @State private var colorList: [Color] = [.blue, .red, .yellow, .pink, .orange, .purple]
    @State private var offset: CGFloat = 0
    @State private var indexOfColorDragged = 0
    var body: some View {
        PagerView(pageCount: colorList.count, currentIndex: $currentPage) {
            ForEach(colorList.indices, id: \.self) { index in
                colorList[index]
                    .cornerRadius(12)
                    .padding()
                    .offset(y: indexOfColorDragged == index ? offset : 0)
                    .onTapGesture {
                        withAnimation {
                            if index == colorList.count - 1 {
                                currentPage = colorList.count - 2
                            }
                            colorList.remove(at: index)
                        }
                    }
            }
        }
    }
}

struct TestPagerView_Previews: PreviewProvider {
    static var previews: some View {
        TestPagerView()
    }
}
