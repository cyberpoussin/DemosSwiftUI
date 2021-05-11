//
//  Shared.swift
//  NewFlowerApp
//
//  Created by Admin on 18/03/2021.
//

import Foundation



// MARK: - MainClass
struct WeatherInfos: Codable {
    let temp, feelsLike, tempMin, tempMax: Double
    let pressure, humidity: Int
    let seaLevel, grndLevel: Int?

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure, humidity
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
    }
}

extension WeatherInfos {
    var tempInCelsius: String {
        String(Int((temp - 273.15).rounded()))
    }
    
    var feelsLikeInCelsius: String {
        String(Int((feelsLike - 273.15).rounded()))
        //String(format: "%0.2f", main.feelsLike - 273.15)
    }
}

// MARK: - Wind
struct Wind: Codable {
    let speed: Double
    let deg: Int
}


// MARK: - Weather
struct Description: Codable {
    let id: Int
    let main: WeatherDescription
    let weatherDescription: String

    enum CodingKeys: String, CodingKey {
        case id, main
        case weatherDescription = "description"
    }
}

extension Description {
    var iconName: String {
        switch main {
        case .clear: return "sun.max.fill"
        case .clouds: return "cloud.fill"
        case .rain: return "cloud.rain.fill"
        case .drizzle: return "cloud.drizzle.fill"
        case .snow: return "cloud.snow.fill"
        case .thunderstorm: return "cloud.bolt.fill"
        case .fog: return "cloud.fog"
        default: return "cloud.sun.fill"
        }
    }
}

enum WeatherDescription: String, Codable {
    case clear = "Clear"
    case clouds = "Clouds"
    case snow = "Snow"
    case mist = "Mist"
    case haze = "Haze"
    case smoke = "Smoke"
    case dust = "Dust"
    case fog = "Fog"
    case sand = "Sand"
    case ash = "Ash"
    case squall = "Squall"
    case tornado = "Tornado"
    case rain = "Rain"
    case drizzle = "Drizzle"
    case thunderstorm = "Thunderstorm"

}






