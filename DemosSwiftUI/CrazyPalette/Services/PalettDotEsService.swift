//
//  APIPaletteDotEsService.swift
//  NewFlowerApp
//
//  Created by Admin on 11/02/2021.
//

import Combine
import SwiftUI

class PalettDotEsService: NetworkPaletteService {
    typealias Response = Palett
    typealias RequestBuilder = Endpoint
    
    var apiSession: APIManager = APISession()

    enum Endpoint: NetworkPaletteRequestBuilder {
        case fetch, fetchFrom(seed: Color)
    }
}



extension PalettDotEsService.Endpoint: RequestBuilder {
    static func fetchPalette() -> RequestBuilder {
        return Self.fetch
    }
    static func fetchPalette(from seedColors: [Color]) -> RequestBuilder {
        return Self.fetchFrom(seed: seedColors[0])
    }
    
    func build() -> URLRequest? {
        guard var url = URL(string: "https://palett.es/API/v1/palette/") else { return nil }
        switch self {
        case let .fetchFrom(seed):
            if let color = seed.hexaRGB?.description.dropFirst() {
                url.appendPathComponent("from/" + color)
            }
        case .fetch:
            let end = Float.random(in: 0.15 ... 0.99)
            url.appendPathComponent("monochrome/over/\(end)")
        }
        return URLRequest(url: url)
    }
}


class ColorMindService: NetworkPaletteService {
    typealias Response = ColorMindPalette
    typealias RequestBuilder = Endpoint
    
    var apiSession: APIManager = APISession()

    enum Endpoint: NetworkPaletteRequestBuilder {
        case fetch, fetchFrom(seedColors: [Color])
    }

}

extension ColorMindService.Endpoint {
    static func fetchPalette() -> RequestBuilder {
        return Self.fetch
    }
    static func fetchPalette(from seedColors: [Color]) -> RequestBuilder {
        return Self.fetchFrom(seedColors: seedColors)
    }

    struct PostData: Encodable {
        var model: String
        var input: [AnyEncodable]? = nil
    }
    
    func build() -> URLRequest? {
        // prepare json data
//        var input: [Any] = []
//        input.append([124,216,218])
//        input += Array(repeating: "N", count: 4)
//        let jsonTest: [String: Any] = ["model": "default",
//                                   "input": input]
//        let jsonData = try? JSONSerialization.data(withJSONObject: jsonTest)
        
        guard let url = URL(string: "http://colormind.io/api/") else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        var json = PostData(model: "default")

        switch self {
        case let .fetchFrom(seedColors):
            json.input = []
            for color in seedColors {
                if let rgba = color.rgba {
                    json.input!.append(AnyEncodable(["\(Int(rgba.red*255))","\(Int(rgba.green*255))","\(Int(rgba.blue*255))"]))
                }
            }
            if json.input!.count < 5 {
                json.input!.append(contentsOf: Array(repeating: AnyEncodable("N"), count: 5 - json.input!.count))
            }
            print(json)
        case .fetch:
           break
        }
        let jsonData = try? JSONEncoder().encode(json)
        request.httpBody = jsonData
        return request
    }
    
}
