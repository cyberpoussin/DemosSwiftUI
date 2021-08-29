//
//  SwiftUIView21.swift
//  DemosSwiftUI
//
//  Created by Admin on 28/08/2021.
//

import Combine
import SwiftUI

struct FooBarView: View {
    @StateObject var fooBar = Foobar()
    var body: some View {
        VStack {
            HStack {
                Button("Change list") {
                    fooBar.foo = (1 ... Int.random(in: 5 ... 9)).map { _ in Int.random(in: 1 ... 9) }.map(Foo.init)
                }
                Text(fooBar.sum.description)
                Button("Change element") {
                    let idx = Int.random(in: 0 ..< fooBar.foo.count)
                    fooBar.foo[idx].bar = Int.random(in: 1 ... 9)
                }
            }
            List(fooBar.foo, id: \.bar) { foo in
                Text(foo.bar.description)
            }
            .onAppear {
                fooBar.foo = [1, 2, 3, 8].map(Foo.init)
            }
        }
    }
}

class Foo: ObservableObject {
    @Published var bar: Int
    init(bar: Int) {
        self.bar = bar
    }
}

class Foobar: ObservableObject {
    @Published var foo: [Foo] = []
    @Published var sum = 0
    var cancellable: AnyCancellable?
    init() {
        cancellable =
            sumPublisher
                .sink {
                    self.sum = $0
                    print("change")
                }
    }

    var sumPublisher: AnyPublisher<Int, Never> {
        let firstPublisher = $foo
            .flatMap { array in
                array.enumerated().publisher
                    .flatMap { index, value in
                        value.$bar
                            .map { (index, $0) }
                    }
                    .map { index, value -> [Foo] in
                        var newArray = array
                        newArray[index] = Foo(bar: value)
                        return newArray
                    }
            }
            .eraseToAnyPublisher()
        let secondPublisher = $foo
            .dropFirst(1)

        return Publishers.Merge(firstPublisher, secondPublisher)
            .map { barArray -> Int in
                barArray
                    .map { $0.bar }
                    .reduce(0, { $0 + $1 })
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}

struct SwiftUIView21_Previews: PreviewProvider {
    static var previews: some View {
        FooBarView()
    }
}
