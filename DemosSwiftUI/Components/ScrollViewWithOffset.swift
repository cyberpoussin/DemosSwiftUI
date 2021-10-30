//
//  ScrollViewWithOffset.swift
//  ScrollViewWithOffset
//
//  Created by Admin on 31/08/2021.
//

import SwiftUI

struct ScrollViewWithOffset<Content: View>: View {
    let axes: Axis.Set
    let showsIndicators: Bool
    let offsetChanged: (CGPoint) -> Void
    let content: Content

    init(
        axes: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        offsetChanged: @escaping (CGPoint) -> Void = { _ in },
        @ViewBuilder content: () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.offsetChanged = offsetChanged
        self.content = content()
    }
    
    var body: some View {
            SwiftUI.ScrollView(axes, showsIndicators: showsIndicators) {
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: geometry.frame(in: .named("scrollView")).origin
                    )
                }.frame(width: 0, height: 0)
                content
            }
            .coordinateSpace(name: "scrollView")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self, perform: offsetChanged)
        }
}

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}

struct TestScrollViewWithOffset: View {
    @State private var offset: CGPoint = .zero
    
    var body: some View {
        ZStack(alignment: .top) {
            Text(offset.y.description)
            ScrollViewWithOffset(offsetChanged: {value in
                offset = value
            }) {
                VStack {
                    ForEach((1...100), id: \.self) {_ in
                        Text("lol")
                            .frame(maxWidth: .infinity)
                    }
                }
        }
        }
    }
}

struct ScrollViewWithOffset_Previews: PreviewProvider {
    static var previews: some View {
        TestScrollViewWithOffset()
    }
}
