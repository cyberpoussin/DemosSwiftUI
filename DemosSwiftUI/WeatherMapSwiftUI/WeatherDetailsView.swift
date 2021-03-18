//
//  WeatherDetails.swift
//  NewFlowerApp
//
//  Created by Admin on 08/02/2021.
//

import Combine
import SwiftUI
import CoreLocation

struct WeatherDetailsView: View {
    @State var cancellables: Set<AnyCancellable> = []
    @State var weather: WeatherResponse? = nil
    func fetchWeather(of coordinate: CLLocationCoordinate2D) {
        var components = URLComponents()
        components.queryItems = [
            //URLQueryItem(name: "q", value: "Lyon"),
            URLQueryItem(name: "lat", value: "\(coordinate.latitude)"),
            URLQueryItem(name: "lon", value: "\(coordinate.longitude)"),
            URLQueryItem(name: "appid", value: "6da70abd3d54ca9edc1b057a18000dda")
        ]
        //api.openweathermap.org/data/2.5/box/city?bbox=12,32,15,37,10&appid={API key}
        // api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API key}
        let url = components.url(relativeTo: URL(string: "https://api.openweathermap.org/data/2.5/weather"))
        
        URLSession.shared.dataTaskPublisher(for: url!)
            .map {response -> Data in
                print(String(data: response.data, encoding: .utf8)!)
                return response.data
            }
            //.replaceError(with: nil)
            .decode(type: WeatherResponse.self, decoder: JSONDecoder())
            .map {dataDecoded -> WeatherResponse? in
                return dataDecoded
            }
            .catch {error -> AnyPublisher<WeatherResponse?, Never> in
                print(error)
                return Just(nil).eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink {weatherResponse in
                self.weather = weatherResponse
            }
            .store(in: &cancellables)
    }
    
    func getCoordinate( addressString : String,
            completionHandler: @escaping(CLLocationCoordinate2D, NSError?) -> Void ) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                        
                    completionHandler(location.coordinate, nil)
                    return
                }
            }
                
            completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
        }
    }
    
    @State private var city: String = ""
    private var privateCity: PassthroughSubject<String, Never>
    private var debouncedCity: AnyPublisher<String, Never>
    
    init() {
        privateCity = PassthroughSubject<String, Never>()
        debouncedCity = privateCity
            .debounce(for: 1, scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    var body: some View {
        VStack {
            TextField("Entrez votre ville", text: $city)
                .onChange(of: city) {city in
                    privateCity.send(city)
                }
                .onReceive(debouncedCity) {city in
                    getCoordinate(addressString: city) {coordinate,error in
                        print("haha")
                        if error == nil {
                            print("hoho")
                            fetchWeather(of: coordinate)
                        }
                    }
                }
            
            
            Button("rechercher") {
                getCoordinate(addressString: city) {coordinate,error in
                    print("haha")
                    if error == nil {
                        print("hoho")
                        fetchWeather(of: coordinate)
                    }
                }
            }
            if let weather = weather {
                Text("\(weather.name)")
                Text("\(weather.tempInCelsius)")
                Text("\(weather.tempInCelsius)")
                Image(systemName: weather.iconName)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 30)
                    .padding()
                    .background(Color.blue)
                    .clipShape(Circle())

            }
        }
        

    }
}

struct WeatherDetails_Previews: PreviewProvider {
    static var previews: some View {
        WeatherDetailsView()
    }
}
