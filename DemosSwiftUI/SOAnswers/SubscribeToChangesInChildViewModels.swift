//
//  SwiftUIView18.swift
//  DemosSwiftUI
//
//  Created by Admin on 25/08/2021.
//

import Combine
import SwiftUI
struct DogList: View {
    class ViewModel: ObservableObject {
        @Published var list: [DogDetail.ViewModel] {
            didSet {
                subscribeToChanges()
            }
        }
        func subscribeToChanges() {
            self.cancellable = list.publisher
                .flatMap { $0.dogDidChange }
                .sink { [weak self] _ in
                    self?.objectWillChange.send()
                    self?.save()
                }
        }
        var cancellable: AnyCancellable?
        init(dogs: [Dog]) {
            list = dogs.map { DogDetail.ViewModel(dog: $0) }
            subscribeToChanges()
        }

        func save() {
            print("list saved :")
            for dogVM in list {
                print(dogVM.dog.favorite)
            }
        }

        func addADog() {
            list.append(.init(dog: .init("Edgard")))
        }
    }

    @StateObject var vm = DogList.ViewModel(dogs: ["John", "Bob"].map(Dog.init))
    var body: some View {
        NavigationView {
            List(vm.list, id: \.dog.id) { detail in
                NavigationLink(destination: DogDetail(vm: detail)) {
                    DogRow(vm: detail)
                }
            }
            .navigationBarItems(leading: Button("Add") {
                vm.addADog()
            })
        }
    }
}

struct DogRow: View {
    @ObservedObject var vm: DogDetail.ViewModel
    var body: some View {
        Text(vm.dog.name)
        Image(systemName: "heart.fill")
            .foregroundColor(vm.dog.favorite ? .red : .gray)
    }
}

struct DogDetail: View {
    class ViewModel: ObservableObject {
        var dogDidChange = PassthroughSubject<Void, Never>()
        @Published var dog: Dog {
            didSet {
                print("a dog changed")
                dogDidChange.send()
            }
        }

        init(dog: Dog) {
            self.dog = dog
        }
    }

    @ObservedObject var vm: ViewModel
    var dog: Dog { vm.dog }
    var body: some View {
        VStack {
            Text(dog.name)
            Button {
                vm.dog.favorite.toggle()
            } label: {
                Image(systemName: "heart.fill")
                    .foregroundColor(dog.favorite ? .red : .gray)
            }
        }.font(.largeTitle)
    }
}

struct Dog: Identifiable {
    let id = UUID()
    var name: String
    var favorite = false
    init(_ name: String) {
        self.name = name
    }
}


struct SwiftUIView18_Previews: PreviewProvider {
    static var previews: some View {
        DogList()
    }
}


