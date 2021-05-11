//
//  PalettService.swift
//  NewFlowerApp
//
//  Created by Admin on 11/02/2021.
//

import Combine
import SwiftUI


protocol PaletteService {
    var apiSession: APIManager { get }
    func fetchPalette(from seedColor: Color?) -> AnyPublisher<AnyPalette?, Never>
    
}

protocol NetworkPaletteRequestBuilder: RequestBuilder {
    static func fetchPalette() -> RequestBuilder
    static func fetchPalette(from seedColors: [Color]) -> RequestBuilder
}


protocol NetworkPaletteService: PaletteService {
    associatedtype Response: Palette, Decodable
    associatedtype RequestBuilder: NetworkPaletteRequestBuilder
    
}

extension NetworkPaletteService {
    
    func fetchPalette(from seedColor: Color? = nil) -> AnyPublisher<AnyPalette?, Never> {
        var publisher: AnyPublisher<Response?, Never>
        
        var builder = RequestBuilder.fetchPalette()
        if let seed = seedColor {
            builder = RequestBuilder.fetchPalette(from: [seed])
        }
        
        publisher = apiSession.request(with: builder)
        
        return publisher
            .map { value -> AnyPalette? in
                guard let value = value else {return nil}
                return AnyPalette(from: value.colors)
            }
            .eraseToAnyPublisher()
    }

}

