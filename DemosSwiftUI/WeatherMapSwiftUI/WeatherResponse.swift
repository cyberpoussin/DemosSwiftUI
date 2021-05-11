//
//  WeatherDetails.swift
//  NewFlowerApp
//
//  Created by Admin on 18/03/2021.
//

import Foundation


struct WeatherResponse: Codable {
    let timezone, id, dt, cod: Int
    let weather: [Description]
    let base: String
    let main: WeatherInfos
    let wind: Wind
    let name: String
}

extension WeatherResponse {
    var tempInCelsius: String { main.tempInCelsius }
    var feelsLikeInCelsius: String { main.feelsLikeInCelsius }
    var iconName: String {
        if !weather.isEmpty {
            return weather[0].iconName
        }
        return ""
    }
}






