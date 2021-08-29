//
//  SwiftUIView11.swift
//  DemosSwiftUI
//
//  Created by Admin on 20/08/2021.
//

import Combine
import SwiftUI
struct DebounceTest: View {
    @State private var text: String = "lol"
    @State private var color: Color = .yellow
    var body: some View {
        HStack {
            Text(text)
            TextFieldWithDebounce(debouncedText: $text)
                .background(color)
                .onChange(of: text) { newValue in
                    color = .red
                }
        }
    }
}

struct TextFieldWithDebounce: View {
    @Binding var text: String
    @State private var internalText: String
    let textHasChanged = PassthroughSubject<Void, Never>()
    let debouncer: AnyPublisher<Void, Never>
    init(debouncedText: Binding<String>, dueTime seconds: Double = 1) {
        _text = debouncedText
        _internalText = State(initialValue: debouncedText.wrappedValue)
        debouncer = textHasChanged
            .debounce(for: .seconds(seconds), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    var body: some View {

            TextField("", text: $internalText, onEditingChanged: {
                isEditing in
                print(isEditing ? "isEditing" : "isNotEditing")
            }, onCommit: {
                print("onCommit")
            })
            .onChange(of: internalText) { newText in
                textHasChanged.send()
            }
            .onReceive(debouncer) { _ in
                text = internalText
            }
        }
    
}

struct SwiftUIView11_Previews: PreviewProvider {
    static var previews: some View {
        DebounceTest()
    }
}
