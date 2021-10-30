//
//  SwiftUIView.swift
//  NewFlowerApp
//
//  Created by Admin on 18/03/2021.
//
import SwiftUI

struct PagerView<Content: View>: View {
    let pageCount: Int
    @Binding var currentIndex: Int
    let content: Content
    @GestureState private var translation: CGFloat = 0

    init(pageCount: Int, currentIndex: Binding<Int>, @ViewBuilder content: () -> Content) {
        self.pageCount = pageCount
        _currentIndex = currentIndex
        self.content = content()
    }

    func getWidth(from width: CGFloat) -> CGFloat {
        return width * 3 / 5
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                self.content.frame(width: getWidth(from: geometry.size.width))
            }
            .offset(x: -CGFloat(self.currentIndex) * getWidth(from: geometry.size.width))
            .offset(x: self.translation + (geometry.size.width - getWidth(from: geometry.size.width)) / 2)
            .animation(.interactiveSpring(), value: currentIndex)
            .animation(.interactiveSpring(), value: translation)
            .gesture(
                DragGesture()
                    .updating(self.$translation) { value, state, _ in
                        state = value.translation.width
                    }
                    .onEnded { value in
                        let offset = value.predictedEndTranslation.width / getWidth(from: geometry.size.width)
                        let newIndex = (CGFloat(self.currentIndex) - offset).rounded()
                        self.currentIndex = min(max(Int(newIndex), 0), self.pageCount - 1)
                    }
            )
        }
    }
}
