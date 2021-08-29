//
//  SwiftUIView14.swift
//  DemosSwiftUI
//
//  Created by Admin on 24/08/2021.
//

import SwiftUI


@available(iOS 15.0, *)
struct DogCEOListView: View {
    var dm = DogManager()

    @State private var dogs: [DogCEO] = ["malamute", "chow", "husky", "samoyed"].map(DogCEO.init)

    var body: some View {
        List(dogs) { dog in
            HStack {
                Text(dog.breed)
                    .padding(.trailing, 40)
                Text(dog.imageInfos ?? "rien")
            }
        }
        .task {
            await dogs = dm.updateImagesOf(favoriteDogs: dogs)
        }
    }
}

struct DogCEO: Identifiable {
    let id = UUID()
    let breed: String
    var imageInfos: String?

    init(_ breed: String) {
        self.breed = breed
    }
}

class DogManager: ObservableObject {
    @available(iOS 15.0, *)
    func updateImageOf(dog: DogCEO) async -> DogCEO {
        var newDog = dog
        guard let url = URL(string: "https://dog.ceo/api/breed/\(dog.breed)/images/random"),
              let (data, response) = try? await URLSession.shared.data(from: url),
              (response as? HTTPURLResponse)?.statusCode == 200 else { return dog }
        newDog.imageInfos = String(data: data, encoding: .utf8)
        return newDog
    }

    @available(iOS 15.0, *)
    func updateImagesOf(favoriteDogs: [DogCEO]) async -> [DogCEO] {
        var results: [DogCEO] = []
        await withTaskGroup(of: DogCEO.self) { group in
            for dog in favoriteDogs {
                group.async {
                    await self.updateImageOf(dog: dog)
                }
            }
            for await result in group {
                results.append(result)
            }
        }
        return results
    }
}


struct SwiftUIView14_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            if #available(iOS 15.0, *) {
                DogCEOListView()
            } else {
                Text("lol")
            }
        }
    }
}
