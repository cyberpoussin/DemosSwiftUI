// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let aQListResponse = try? newJSONDecoder().decode(AQListResponse.self, from: jsonData)

import Foundation
import MapKit
import SwiftUI
extension AQData: Identifiable {
    enum Quality { case good, moderate, bad, unhealthy, veryunhealthy, hazardous, unknown}
    var id: Int { uid }
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    var aqiDouble: Double? {
        Double(aqi)
    }
    var airQuality: Quality {
        if let aqi = Double(aqi) {
            switch aqi {
            case 0...50: return .good
            case 50..<100: return .moderate
            case 100..<150: return .bad
            case 150..<200: return .unhealthy
            case 200..<300: return .veryunhealthy
            case 300...: return .hazardous
            default: return .unknown
            }
        }
        return .unknown
        
    }
    
    var color: Color {
        if let aqi = aqiDouble {
            let ladder: [UIColor] = [.green, .yellow, .orange, .red, .purple]
            let intermediate = ladder.intermediate(percentage: CGFloat(aqi/2))
            return Color(intermediate)
        }
        return .gray
    }
    
    var iconColor: Color {
        switch airQuality {
        case .good: return .green
        case .moderate: return .yellow
        case .bad: return .orange
        case .unhealthy: return .red
        case .veryunhealthy: return .purple
        case .hazardous: return .black
        case .unknown: return .gray
        }
    }
}
// MARK: - AQListResponse
struct AQListResponse: Codable {
    let status: String
    let data: [AQData]
}

// MARK: - Datum
struct AQData: Codable {
    let lat, lon: Double
    let uid: Int
    let aqi: String
    let station: Station
}

// MARK: - Station
struct Station: Codable {
    let name: String
    let time: Date
}




extension Array where Element: UIColor {
    func intermediate(percentage: CGFloat) -> UIColor {
        let percentage = Swift.max(Swift.min(percentage, 100), 0) / 100
        switch percentage {
        case 0: return first ?? .clear
        case 1: return last ?? .clear
        default:
            let approxIndex = percentage / (1 / CGFloat(count - 1))
            let firstIndex = Int(approxIndex.rounded(.down))
            let secondIndex = Int(approxIndex.rounded(.up))
            let fallbackIndex = Int(approxIndex.rounded())

            let firstColor = self[firstIndex]
            let secondColor = self[secondIndex]
            let fallbackColor = self[fallbackIndex]

            var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            guard firstColor.getRed(&r1, green: &g1, blue: &b1, alpha: &a1) else { return fallbackColor }
            guard secondColor.getRed(&r2, green: &g2, blue: &b2, alpha: &a2) else { return fallbackColor }

            let intermediatePercentage = approxIndex - CGFloat(firstIndex)
            return UIColor(red: CGFloat(r1 + (r2 - r1) * intermediatePercentage),
                           green: CGFloat(g1 + (g2 - g1) * intermediatePercentage),
                           blue: CGFloat(b1 + (b2 - b1) * intermediatePercentage),
                           alpha: CGFloat(a1 + (a2 - a1) * intermediatePercentage))
        }
    }
}
