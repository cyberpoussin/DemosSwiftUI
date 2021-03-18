//
//  File.swift
//  NewFlowerApp
//
//  Created by Admin on 11/02/2021.
//

import SwiftUI

protocol Palette {
    var id: UUID { get }
    var colors: [Color] { get }
}

struct PaletteColor: Codable, Identifiable, Equatable {
    let id = UUID()
    var name: String? = nil
    var color: Color
    
    enum CodingKeys: CodingKey {
        case name, color
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(color.hexaRGBA!, forKey: .color)
        try container.encode(name, forKey:.name)
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String?.self, forKey: .name)
        let colorHex = try values.decode(String.self, forKey: .color)
        print("lala \(colorHex)")
        color = Color(hex: colorHex) ?? .white
    }
    
    init(_ color: Color) {
        self.color = color
    }
}

struct AnyPalette: Codable, Identifiable, Equatable {
    var id: UUID
    //var colors: [Color]
    var colors: [PaletteColor]
    
    init?<T: Palette>(palette: T?) {
        guard let palette = palette else { return nil }
        id = palette.id
        //self.colors = palette.colors
        colors = palette.colors.map{PaletteColor($0)}
    }
    
    init?(palette: AnyPalette?) {
        guard let palette = palette else { return nil }
        self = palette
    }

    init?(from colors: [Color]) {
        id = UUID()
        guard colors.count == 5 else { return nil }
        //self.colors = colors
        self.colors = colors.map{PaletteColor($0)}
    }

    init?(from colors: [PaletteColor]) {
        id = UUID()
        guard colors.count == 5 else { return nil }
        //self.colors = colors
        self.colors = colors
    }
}

struct Palett: Decodable, Identifiable, Palette {
    let id = UUID()
    var colors: [Color]
    init(from decoder: Decoder) throws {
        let values = try decoder.singleValueContainer()
        let arrayOfStrings = try values.decode([String].self)
        colors = []
        for colorString in arrayOfStrings {
            colors.append(Color(hex: colorString + "ff") ?? Color.white)
        }
    }
}

struct ColorMindPalette: Palette, Decodable, Identifiable {
    let id = UUID()
    var colors: [Color]
    
    enum CodingKeys: CodingKey {
        case result
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let arrayOfArrayOfInts = try values.decode([[Int]].self, forKey: .result)
        colors = []
        for rgb in arrayOfArrayOfInts {
            colors.append(Color(red: Double(rgb[0])/255.0, green: Double(rgb[1])/255.0, blue: Double(rgb[2])/255.0))
        }
    }
}


