//
//  TestWeather.swift
//  NewFlowerApp
//
//  Created by Admin on 06/02/2021.
//

import SwiftUI
import Combine
import MapKit


let initialLat = 48.856614
let initialLong = 2.3522219


struct TestAirQualityMapView: View {
    
    @State var cancellables: Set<AnyCancellable> = []
    @State var weatherResponse: AQListResponse? = nil
    @State var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: initialLat, longitude: initialLong),
        span: MKCoordinateSpan(latitudeDelta: 3, longitudeDelta: 3))

    @State var oldCoords: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: initialLat, longitude: initialLong)
    @State var weatherSelected: Weather? = nil
    
    
    
    func fetchWeather() {
        var components = URLComponents()
        components.queryItems = [
            //URLQueryItem(name: "q", value: "Lyon"),
            //URLQueryItem(name: "bbox", value: "\(region.center.longitude - 2),\(region.center.latitude - 2),\(region.center.longitude + 2),\(region.center.latitude + 2),8"),
            URLQueryItem(name: "token", value: "e13d860656952916a075310029a9472bb2d26a6c"),
            URLQueryItem(name: "latlng", value: "\(region.center.latitude - region.span.latitudeDelta),\(region.center.longitude - region.span.longitudeDelta),\(region.center.latitude + region.span.latitudeDelta),\(region.center.longitude + region.span.longitudeDelta)")
        ]
        print("\(region.center.latitude - region.span.latitudeDelta),\(region.center.longitude - region.span.longitudeDelta),\(region.center.latitude + region.span.latitudeDelta),\(region.center.longitude + region.span.longitudeDelta)")
        //api.openweathermap.org/data/2.5/box/city?bbox=12,32,15,37,10&appid={API key}
        let url = components.url(relativeTo: URL(string: "https://api.waqi.info/map/bounds/"))
        // https://api.waqi.info/feed/beijing/?token=e13d860656952916a075310029a9472bb2d26a6c
        
        // /map/bounds/?token=:token&latlng=:latlng
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        URLSession.shared.dataTaskPublisher(for: url!)
            .map {response -> Data in
                print(String(data: response.data, encoding: .utf8)!)
                return response.data
            }
            //.replaceError(with: nil)
            .decode(type: AQListResponse.self, decoder: decoder)
            .map {dataDecoded -> AQListResponse? in
                return dataDecoded
            }
            .catch {error -> AnyPublisher<AQListResponse?, Never> in
                print(error)
                return Just(nil).eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink {weatherResponse in
                print("\(weatherResponse?.data) \nhahaha")
                    self.weatherResponse = weatherResponse
            }
            .store(in: &cancellables)
    }

    @State var selectedWeather: AQData? = nil
    var body: some View {
        if let weatherResponse = weatherResponse {
            VStack {
                
                Map(coordinateRegion: $region, annotationItems: weatherResponse.data) { data in
                    MapAnnotation(coordinate: data.coordinate) {
                        if selectedWeather == nil {
                            Image(systemName: "cloud.fill")
                                .font(.title)
                                .foregroundColor(data.color)
                                .onTapGesture {
                                    selectedWeather = data
                                }
                        } else {
                            Image(systemName: "cloud.fill")
                                .font(selectedWeather!.id == data.id ? .system(size: 50) : .title)
                                .foregroundColor(data.color)
                                .overlay(selectedWeather!.id == data.id ? Text(selectedWeather!.aqi) : Text(""))
                                .onTapGesture {
                                    if selectedWeather!.id == data.id {
                                        selectedWeather = nil
                                    } else {
                                        selectedWeather = data
                                    }
                                }
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
                List(weatherResponse.data.sorted(by: {Double($0.aqi) ?? 200 < Double($1.aqi) ?? 200})) { data in
                    Text(data.aqi.description)
                    Text(data.station.name)
                }
                
            }
            .ignoresSafeArea()
        } else {
            Text("Chargement")
                .onAppear {
                    fetchWeather()
                }
        }
    }
}



struct TestAirQualityMapView_Previews: PreviewProvider {
    static var previews: some View {
        TestAirQualityMapView()
    }
}
