//
//  SwiftUIView9.swift
//  DemosSwiftUI
//
//  Created by Admin on 19/08/2021.
//

import SwiftUI

struct Item: Identifiable {
    let id = UUID()
    var text: String
}

struct TestListWithIndex: View {
    @State private var data = (1 ... 20).map { _ in Item(text: String.random(length: 10)) }
    func getItemIndex(id: UUID) -> Int {
        data.firstIndex(where: { $0.id == id })!
    }

    var body: some View {
        let d = Binding(get: {
            Array(data.enumerated())
        }, set: {
            data = $0.map { $0.1 }
        })
        VStack {
            ListWithIndex($data) { i, $item in
                HStack {
                    Text("\(i)")
                    TextField("", text: $item.text)
                }
            }

            List(d, id: \.1.id) { $item in
                HStack {
                    Text("\(item.0)")
                    TextField("", text: $item.1.text)
                }
            }
        }
        .toolbar(content: {
            HStack {
                Button("add") {
                    data.append(Item(text: "Anonymous \(data.count)"))
                }
                Button("delete") {
                    data.removeLast()
                }
            }
        })
    }
}

struct ListWithIndex<Content: View>: View {
    let list: List<Never, Content>

    init<Data: MutableCollection & RandomAccessCollection, RowContent: View>(
        _ data: Binding<Data>,
        @ViewBuilder rowContent: @escaping (Data.Index, Binding<Data.Element>) -> RowContent
    ) where Content == ForEach<[(Data.Index, Data.Element)], Data.Element.ID, RowContent>,
        Data.Element: Identifiable,
        Data.Index: Hashable {
        let list = List {
            ForEach(
                Array(zip(data.wrappedValue.indices, data.wrappedValue)),
                id: \.1.id
            ) { i, _ in
                rowContent(i, Binding(
                    get: { data.wrappedValue[i] },
                    set: { data.wrappedValue[i] = $0 }
                ))
            }
        }
        self.list = list
    }

    var body: some View {
        list
    }
}

struct SwiftUIView9_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TestListWithIndex()
        }
    }
}
