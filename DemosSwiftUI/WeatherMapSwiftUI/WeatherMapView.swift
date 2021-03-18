//
//  TestWeather.swift
//  NewFlowerApp
//
//  Created by Admin on 06/02/2021.
//

import SwiftUI
import Combine
import MapKit
let initialLatitude = 48.856614
let initialLongitude = 2.3522219
struct WeatherMapView: View {
    
    @State var cancellables: Set<AnyCancellable> = []
    @State var weatherResponse: WeatherListReponse? = nil
    @State var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: initialLatitude, longitude: initialLongitude),
        span: MKCoordinateSpan(latitudeDelta: 3, longitudeDelta: 3))

    @State var oldCoords: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: initialLatitude, longitude: initialLongitude)
    @State var weatherSelected: Weather? = nil
    func fetchWeather() {
        var components = URLComponents()
        components.queryItems = [
            //URLQueryItem(name: "q", value: "Lyon"),
            URLQueryItem(name: "bbox", value: "\(region.center.longitude - 2),\(region.center.latitude - 2),\(region.center.longitude + 2),\(region.center.latitude + 2),8"),
            URLQueryItem(name: "appid", value: "6da70abd3d54ca9edc1b057a18000dda")
        ]
        //api.openweathermap.org/data/2.5/box/city?bbox=12,32,15,37,10&appid={API key}
        let url = components.url(relativeTo: URL(string: "https://api.openweathermap.org/data/2.5/box/city"))
        
        URLSession.shared.dataTaskPublisher(for: url!)
            .map {response -> Data in
                print(String(data: response.data, encoding: .utf8)!)
                return response.data
            }
            //.replaceError(with: nil)
            .decode(type: WeatherListReponse.self, decoder: JSONDecoder())
            .map {dataDecoded -> WeatherListReponse? in
                return dataDecoded
            }
            .catch {error -> AnyPublisher<WeatherListReponse?, Never> in
                print(error)
                return Just(nil).eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink {weatherResponse in
                print("\(weatherResponse?.list) \nhahaha")
                    self.weatherResponse = weatherResponse
            }
            .store(in: &cancellables)
    }

    
    var body: some View {
        if let weatherResponse = weatherResponse {
            VStack {
//                List(weatherResponse.list) {weather in
//                    Text(weather.name)
//                    Text("Nuages : \(weather.clouds.today) %")
//                    Text("Température actuelle: \(weather.tempInCelsius) °C")
//                    Text("Température ressentie: \(weather.feelsLikeInCelsius) °C")
//                }
                Map(coordinateRegion: $region, annotationItems: weatherResponse.list) {weather in
                    MapAnnotation(coordinate: weather.coordinate) {
                        Image(systemName: weather.iconName)
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 20)
                            
                            .background(
                                Circle()
                                    .foregroundColor(.clear)
                                    .padding(20)
                                    .background(Color.blue)
                                    .opacity(0.8)

                                    .cornerRadius(50)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.green, lineWidth: 0.2)

                                    )
                            )
                            .onTapGesture {
                                weatherSelected = weather
                            }
                    }
                }
                .onChange(of: region.center.latitude) {latitude in
                    if abs(latitude - oldCoords.latitude) > 1 {
                        print("beaucoup bouge \(region.center.latitude) \(latitude)")
                        oldCoords = region.center
                        self.fetchWeather()

                    }
                }
                .onChange(of: region.center.longitude) {longitude in
                    if abs(longitude - oldCoords.longitude) > 1 {
                        print("beaucoup bouge \(region.center.longitude) \(longitude)")
                        oldCoords = region.center
                        self.fetchWeather()

                    }
                }
                .sheet(item: $weatherSelected) {weather in
                    ZStack {
                        Color.blue
                        VStack {
                            Text(weather.name)
                                .font(.title)
                            Image(systemName: weather.iconName)
                                .renderingMode(.original)
                                .font(.title)

                            
                            VStack {
                                Text("\(weather.tempInCelsius) °C")
                                    .font(.title)

                                Text("\(weather.feelsLikeInCelsius) °C ressentis")
                            }
                        }
                        .foregroundColor(.white)
                    }
                    .ignoresSafeArea()
                    
                }

            }
            .ignoresSafeArea()
            
        } else {
            Text("En attente")
                .onAppear {
                    print("lol")
                    self.fetchWeather()
                }
        }
    }
}



struct WeatherMapView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherMapView()
    }
}
