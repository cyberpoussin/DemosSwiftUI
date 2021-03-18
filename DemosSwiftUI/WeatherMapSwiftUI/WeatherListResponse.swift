//
//  Weather.swift
//  NewFlowerApp
//
//  Created by Admin on 06/02/2021.
//

import Foundation
import MapKit

// MARK: - List
struct WeatherListReponse: Codable {
    let list: [Weather]
}


// MARK: - Weather
struct Weather: Codable, Identifiable {
    let id, dt: Int
    let name: String
    let coord: Coord
    let main: WeatherInfos
    let visibility: Int
    let wind: Wind
    let rain: Rain?
    let snow: Snow?
    let clouds: Clouds
    let weather: [Description]
}

// MARK: - Clouds
struct Clouds: Codable {
    let today: Int
}

// MARK: - Coord
struct Coord: Codable {
    let lon, lat: Double

    enum CodingKeys: String, CodingKey {
        case lon = "Lon"
        case lat = "Lat"
    }
}


// MARK: - Rain
struct Rain: Codable {
    let the1H: Double

    enum CodingKeys: String, CodingKey {
        case the1H = "1h"
    }
}

// MARK: - Snow
struct Snow: Codable {
    let the1H: Double

    enum CodingKeys: String, CodingKey {
        case the1H = "1h"
    }
}





extension Weather {
    var tempInCelsius: String { main.tempInCelsius }
    var feelsLikeInCelsius: String { main.feelsLikeInCelsius }
    var iconName: String {
        if !weather.isEmpty {
            return weather[0].iconName
        }
        return ""
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: coord.lat, longitude: coord.lon)
    }
}

