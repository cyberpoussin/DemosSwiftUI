//
//  NewFlowerAppApp.swift
//  NewFlowerApp
//
//  Created by Admin on 03/02/2021.
//

import SwiftUI
import MapKit
import Combine

@main
struct DemosSwiftUI: App {
    @StateObject private var viewModel = ViewModel()
    var body: some Scene {
        WindowGroup {
//            TabView {
//                TestMap(viewModel: viewModel)
//                    .tabItem {
//                        Image(systemName: "map")
//                    }
//                TestColumn(viewModel: viewModel)
//                    .tabItem {
//                        Image(systemName: "drop")
//                    }
//                TestWeather()
//                    .tabItem {
//                        Image(systemName: "cloud.sun")
//                    }
//            }
            WeatherDetailsView()
        }
    }
}

class ViewModel: ObservableObject {
    @Published var store: [VeganFoodPlace]
    let initialLatitude = 48.856614
    let initialLongitude = 2.3522219
    var cancellables: Set<AnyCancellable> = []
    
    init() {
        store = []
        for i in 0...50 {
            let latitude = initialLatitude + Double.random(in: -0.2...0.2)
            let longitude = initialLongitude + Double.random(in: -0.2...0.2)
            store.append(.init(id: i, name: "", latitude: latitude, longitude: longitude))
        }
    }
    
    func fetchImage(for placeIndex: Int) {
        print("lol")
        URLSession.shared.dataTaskPublisher(for: URL(string: "https://picsum.photos/200/300")!)
            .map { result -> Data? in
                return result.data
            }
            .catch { error -> AnyPublisher<Data?, Never> in
                print(error)
                return Just(nil).eraseToAnyPublisher()
            }
            .sink { [weak self] value in
                guard let data = value else {
                    print("pas de data")
                    return
                }
                DispatchQueue.main.async {
                    self?.store[placeIndex].image = Image(uiImage: UIImage(data: data)!)
                }
            }
            .store(in: &cancellables)
    }
}


struct VeganFoodPlace: Identifiable {
    var id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    var image: Image? = nil
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
