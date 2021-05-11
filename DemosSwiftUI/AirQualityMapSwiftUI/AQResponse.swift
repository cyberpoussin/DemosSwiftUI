// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let aQResponse = try? newJSONDecoder().decode(AQResponse.self, from: jsonData)

import Foundation

// MARK: - AQResponse
struct AQResponse: Codable {
    let status: String
    let data: DataClass
}

// MARK: - DataClass
struct DataClass: Codable {
    let aqi, idx: Int
    let attributions: [Attribution]
    let city: City
    let dominentpol: String
    let iaqi: Iaqi
    let time: Time
    let forecast: Forecast
    let debug: Debug
}

// MARK: - Attribution
struct Attribution: Codable {
    let url: String
    let name: String
}

// MARK: - City
struct City: Codable {
    let geo: [Double]
    let name: String
    let url: String
}

// MARK: - Debug
struct Debug: Codable {
    let sync: Date
}

// MARK: - Forecast
struct Forecast: Codable {
    let daily: Daily
}

// MARK: - Daily
struct Daily: Codable {
    let o3, pm10, pm25, uvi: [O3]
}

// MARK: - O3
struct O3: Codable {
    let avg: Int
    let day: String
    let max, min: Int
}

// MARK: - Iaqi
struct Iaqi: Codable {
    let co, h, no2, o3: Co
    let p, pm10, pm25, so2: Co
    let t, w: Co
}

// MARK: - Co
struct Co: Codable {
    let v: Double
}

// MARK: - Time
struct Time: Codable {
    let s, tz: String
    let v: Int
    let iso: Date
}
